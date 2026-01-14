DROP PROCEDURE IF EXISTS addOrUpdateTestProbe;
DELIMITER //
CREATE PROCEDURE addOrUpdateTestProbe(
  IN adapter_codeParam  VARCHAR(50),
  IN fixture_typeParam  VARCHAR(30),
  IN fixture_plantParam VARCHAR(100),
  IN part_numberParam   VARCHAR(100),
  IN qtyParam           INT,
  IN modified_byParam   VARCHAR(100)
)
proc_main: BEGIN
  DECLARE v_exists INT DEFAULT 0;

  IF qtyParam IS NULL OR qtyParam <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'qty must be > 0', MYSQL_ERRNO = 1201;
  END IF;

  SELECT COUNT(*) INTO v_exists
    FROM tp_description
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam
     AND part_number   = part_numberParam;

  IF v_exists = 0 THEN
    INSERT INTO tp_description(adapter_code, fixture_type, fixture_plant, part_number, qty, last_update, modified_by)
    VALUES (adapter_codeParam, fixture_typeParam, fixture_plantParam, part_numberParam, qtyParam, NOW(), modified_byParam);
  ELSE
    UPDATE tp_description
       SET qty = qtyParam, last_update = NOW(), modified_by = modified_byParam
     WHERE adapter_code  = adapter_codeParam
       AND fixture_type  = fixture_typeParam
       AND fixture_plant = fixture_plantParam
       AND part_number   = part_numberParam;
  END IF;

  CALL regenerateProjectTestProbes(adapter_codeParam, fixture_typeParam, fixture_plantParam);

  INSERT INTO db_logs(project_name, adapter_code, fixture_type, db_action, modified_by, last_update, fixture_plant)
  SELECT p.project_name, p.adapter_code, p.fixture_type,
         CONCAT('Test probe ', part_numberParam, ' → qty ', qtyParam),
         modified_byParam, NOW(), p.fixture_plant
    FROM Projects p
   WHERE p.adapter_code  = adapter_codeParam
     AND p.fixture_type  = fixture_typeParam
     AND p.fixture_plant = fixture_plantParam
   LIMIT 1;
END;
//
DELIMITER ;