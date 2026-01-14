DROP PROCEDURE IF EXISTS seedDefaultUserGroupsForPlant;
DELIMITER //

CREATE PROCEDURE seedDefaultUserGroupsForPlant(IN plant_nameParam VARCHAR(100))
proc_main: BEGIN
  DECLARE v_plant_id INT;
  DECLARE v_inserted INT DEFAULT 0;

  /* Error handler */
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT 500 AS status_code,
           'Unexpected database error' AS message,
           v_inserted AS inserted;
  END;

  IF plant_nameParam IS NULL OR TRIM(plant_nameParam) = '' THEN
    SELECT 400 AS status_code, 'plant_name is required' AS message;
    LEAVE proc_main;
  END IF;

  SELECT entry_id INTO v_plant_id
  FROM Plants
  WHERE plant_name = plant_nameParam
  LIMIT 1;

  IF v_plant_id IS NULL THEN
    SELECT 404 AS status_code, 'Plant not found' AS message, 0 AS inserted;
    LEAVE proc_main;
  END IF;

  START TRANSACTION;

  INSERT INTO user_groups (plant_id, group_name)
  SELECT v_plant_id, g.group_name
  FROM (
    SELECT 'admin' AS group_name
    UNION ALL SELECT 'IE'
    UNION ALL SELECT 'maintenance'
  ) AS g
  LEFT JOIN user_groups ug
    ON ug.plant_id = v_plant_id
   AND ug.group_name = g.group_name
  WHERE ug.entry_id IS NULL;

  SET v_inserted = ROW_COUNT();

  COMMIT;

  SELECT 200 AS status_code,
         CONCAT('Seeding completed for plant ', plant_nameParam) AS message,
         v_inserted AS inserted;
END;
//
DELIMITER ;

-- Usage:
-- CALL seedDefaultUserGroupsForPlant('Timisoara');
