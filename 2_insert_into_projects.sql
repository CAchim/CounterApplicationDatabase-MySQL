DROP PROCEDURE IF EXISTS insertProject;
DELIMITER //

CREATE PROCEDURE insertProject(
  IN project_nameParam   VARCHAR(100),
  IN adapter_codeParam   VARCHAR(50),
  IN fixture_typeParam   VARCHAR(30),
  IN owner_emailParam    TEXT,
  IN contacts_limitParam INT,
  IN warning_atParam     INT,
  IN modified_byParam    VARCHAR(100),
  IN fixture_plantParam  VARCHAR(100)     -- NEW: plant partition
)
proc_main: BEGIN
  -- Basic validations
  IF project_nameParam IS NULL OR TRIM(project_nameParam) = '' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'project_name is required', MYSQL_ERRNO = 1001;
  END IF;

  IF adapter_codeParam IS NULL OR TRIM(adapter_codeParam) = '' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'adapter_code is required', MYSQL_ERRNO = 1001;
  END IF;

  IF fixture_typeParam IS NULL OR TRIM(fixture_typeParam) = '' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'fixture_type is required', MYSQL_ERRNO = 1001;
  END IF;

  IF fixture_plantParam IS NULL OR TRIM(fixture_plantParam) = '' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'fixture_plant is required', MYSQL_ERRNO = 1001;
  END IF;

  IF contacts_limitParam IS NULL OR warning_atParam IS NULL
     OR contacts_limitParam <= warning_atParam THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'contacts_limit must be greater than warning_at', MYSQL_ERRNO = 1003;
  END IF;

  -- Uniqueness per plant + adapter + fixture
  IF EXISTS (
    SELECT 1 FROM Projects
     WHERE fixture_plant = fixture_plantParam
       AND adapter_code  = adapter_codeParam
       AND fixture_type  = fixture_typeParam
     LIMIT 1
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The adapter code already exists with the specified fixture type in this plant!',
          MYSQL_ERRNO = 1002;
  END IF;

  -- Insert
  INSERT INTO Projects (
    project_name, adapter_code, fixture_type,
    owner_email, contacts, contacts_limit, warning_at, resets,
    testprobes, modified_by, last_update, fixture_plant
  )
  VALUES (
    project_nameParam, adapter_codeParam, fixture_typeParam,
    owner_emailParam, 0, contacts_limitParam, warning_atParam, 0,
    '', modified_byParam, NOW(), fixture_plantParam
  );

  -- Log (adapt columns to your db_logs structure)
  INSERT INTO db_logs (project_name, adapter_code, fixture_type, db_action, modified_by, last_update)
  VALUES (
    project_nameParam, adapter_codeParam, fixture_typeParam,
    'Equipment added to the database!', modified_byParam, NOW()
  );
END;
//
DELIMITER ;
