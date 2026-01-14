DROP PROCEDURE IF EXISTS concatenateNails;
DELIMITER //

CREATE PROCEDURE concatenateNails(
  IN adapter_codeParam VARCHAR(50),
  IN fixture_typeParam VARCHAR(30),
  IN modified_byParam VARCHAR(50),
  IN probes_json JSON
)
BEGIN
  DECLARE project_idParam INT;
  DECLARE inputParam TEXT;
  DECLARE i INT DEFAULT 0;
  DECLARE total INT;

  -- Get the related project ID
  SELECT entry_id INTO project_idParam
  FROM Projects
  WHERE adapter_code = adapter_codeParam AND fixture_type = fixture_typeParam;

  -- Count how many items are in the JSON array
  SET total = JSON_LENGTH(probes_json);

  -- Loop through the JSON array
  WHILE i < total DO
    BEGIN
      DECLARE pn TEXT;
      DECLARE qty INT;

      SET pn = JSON_UNQUOTE(JSON_EXTRACT(probes_json, CONCAT('$[', i, '].part_number')));
      SET qty = JSON_EXTRACT(probes_json, CONCAT('$[', i, '].quantity'));

      -- Check if already exists
      IF NOT EXISTS (
        SELECT 1 FROM tp_description
        WHERE ad_code = adapter_codeParam AND part_number = pn
      ) THEN
        INSERT INTO tp_description(project_id, ad_code, part_number, quantity)
        VALUES (project_idParam, adapter_codeParam, pn, qty);
      END IF;
    END;
    SET i = i + 1;
  END WHILE;

  -- Rebuild testprobes string
  SELECT GROUP_CONCAT(part_number, ': ', quantity, 'pcs' SEPARATOR '; ') INTO inputParam
  FROM tp_description
  WHERE ad_code = adapter_codeParam;

  -- Update project info
  IF EXISTS (
    SELECT * FROM Projects WHERE adapter_code = adapter_codeParam AND fixture_type = fixture_typeParam
  ) THEN
    UPDATE Projects
    SET testprobes = inputParam,
        modified_by = modified_byParam,
        last_update = NOW()
    WHERE adapter_code = adapter_codeParam AND fixture_type = fixture_typeParam;
  ELSE
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'The adapter code does not exist with the specified fixture type!', MYSQL_ERRNO = 1001;
  END IF;
END;
//
DELIMITER ;
