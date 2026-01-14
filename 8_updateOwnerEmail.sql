DROP PROCEDURE IF EXISTS updateOwnerEmail;
DELIMITER //

CREATE PROCEDURE updateOwnerEmail(
  IN adapter_codeParam   VARCHAR(50),
  IN fixture_typeParam   VARCHAR(30),
  IN fixture_plantParam  VARCHAR(100),
  IN owner_emailParam    TEXT,
  IN modified_byParam    VARCHAR(100)
)
proc_main: BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Projects
     WHERE adapter_code = adapter_codeParam
       AND fixture_type = fixture_typeParam
       AND fixture_plant = fixture_plantParam
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Project not found for this plant', MYSQL_ERRNO = 1001;
  END IF;

  UPDATE Projects
     SET owner_email = owner_emailParam,
         modified_by = modified_byParam,
         last_update = NOW()
   WHERE adapter_code = adapter_codeParam
     AND fixture_type = fixture_typeParam
     AND fixture_plant = fixture_plantParam;

  INSERT INTO db_logs(project_name, adapter_code, fixture_type, db_action, modified_by, last_update, fixture_plant)
  SELECT project_name, adapter_code, fixture_type, 'Owner email updated', modified_byParam, NOW(), fixture_plant
    FROM Projects
   WHERE adapter_code = adapter_codeParam
     AND fixture_type = fixture_typeParam
     AND fixture_plant = fixture_plantParam
   LIMIT 1;
END;
//
DELIMITER ;
