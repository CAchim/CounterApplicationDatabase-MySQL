DROP PROCEDURE IF EXISTS deleteProjectForPlant;
DELIMITER //

CREATE PROCEDURE deleteProjectForPlant(
  IN adapter_codeParam  VARCHAR(50),
  IN fixture_typeParam  VARCHAR(30),
  IN fixture_plantParam VARCHAR(100),
  IN modified_byParam   VARCHAR(100)
)
proc_main: BEGIN
  DECLARE v_project_name VARCHAR(100);

  IF NOT EXISTS (
    SELECT 1 FROM Projects
     WHERE adapter_code = adapter_codeParam
       AND fixture_type = fixture_typeParam
       AND fixture_plant = fixture_plantParam
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Project not found for this plant', MYSQL_ERRNO = 1001;
  END IF;

  SELECT project_name INTO v_project_name
    FROM Projects
   WHERE adapter_code = adapter_codeParam
     AND fixture_type = fixture_typeParam
     AND fixture_plant = fixture_plantParam
   LIMIT 1;

  INSERT INTO db_logs(project_name, adapter_code, fixture_type, db_action, modified_by, last_update, fixture_plant)
  VALUES (v_project_name, adapter_codeParam, fixture_typeParam, 'Equipment deleted', modified_byParam, NOW(), fixture_plantParam);

  DELETE FROM Projects
   WHERE adapter_code = adapter_codeParam
     AND fixture_type = fixture_typeParam
     AND fixture_plant = fixture_plantParam;
END;
//
DELIMITER ;
