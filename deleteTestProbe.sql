DROP PROCEDURE IF EXISTS deleteTestProbe;
DELIMITER //
CREATE PROCEDURE deleteTestProbe(
  IN adapter_codeParam  VARCHAR(50),
  IN fixture_typeParam  VARCHAR(30),
  IN fixture_plantParam VARCHAR(100),
  IN part_numberParam   VARCHAR(100),
  IN modified_byParam   VARCHAR(100)
)
BEGIN
  DELETE FROM tp_description
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam
     AND part_number   = part_numberParam;

  CALL regenerateProjectTestProbes(adapter_codeParam, fixture_typeParam, fixture_plantParam);

  INSERT INTO db_logs(project_name, adapter_code, fixture_type, db_action, modified_by, last_update, fixture_plant)
  SELECT p.project_name, p.adapter_code, p.fixture_type,
         CONCAT('Test probe deleted: ', part_numberParam),
         modified_byParam, NOW(), p.fixture_plant
    FROM Projects p
   WHERE p.adapter_code  = adapter_codeParam
     AND p.fixture_type  = fixture_typeParam
     AND p.fixture_plant = fixture_plantParam
   LIMIT 1;
END;
//
DELIMITER ;