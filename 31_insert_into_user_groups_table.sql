DROP PROCEDURE IF EXISTS seedUserGroupsForPlant;
DELIMITER //

CREATE PROCEDURE seedUserGroupsForPlant(
  IN plant_nameParam VARCHAR(25),
  IN groups_csv TEXT
)
proc_main: BEGIN
  DECLARE v_plant_id INT;
  DECLARE v_str TEXT;
  DECLARE v_pos INT;
  DECLARE v_token VARCHAR(25);
  DECLARE v_inserted INT DEFAULT 0;
  DECLARE v_skipped INT DEFAULT 0;

  /* Error handler */
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT 500 AS status_code,
           'Unexpected database error' AS message,
           v_inserted AS inserted,
           v_skipped AS skipped;
  END;

  /* Validations */
  IF plant_nameParam IS NULL OR TRIM(plant_nameParam) = '' THEN
    SELECT 400 AS status_code, 'plant_name is required' AS message;
    LEAVE proc_main;
  END IF;

  IF groups_csv IS NULL OR TRIM(groups_csv) = '' THEN
    SELECT 400 AS status_code, 'groups_csv is required' AS message;
    LEAVE proc_main;
  END IF;

  START TRANSACTION;

  /* Find plant_id */
  SELECT p.entry_id
    INTO v_plant_id
    FROM Plants p
   WHERE p.plant_name = plant_nameParam
   LIMIT 1;

  IF v_plant_id IS NULL THEN
    ROLLBACK;
    SELECT 404 AS status_code,
           'Plant not found' AS message,
           0 AS inserted,
           0 AS skipped;
    LEAVE proc_main;
  END IF;

  /* Simple CSV split loop */
  SET v_str = CONCAT(groups_csv, ','); -- sentinel comma
  split_loop: LOOP
    SET v_pos = LOCATE(',', v_str);
    IF v_pos = 0 THEN
      LEAVE split_loop;
    END IF;

    SET v_token = TRIM(SUBSTRING(v_str, 1, v_pos - 1));
    SET v_str   = SUBSTRING(v_str, v_pos + 1);

    IF v_token IS NOT NULL AND v_token <> '' THEN
      INSERT IGNORE INTO user_groups (plant_id, group_name)
      VALUES (v_plant_id, v_token);

      IF ROW_COUNT() = 1 THEN
        SET v_inserted = v_inserted + 1;
      ELSE
        SET v_skipped  = v_skipped + 1;
      END IF;
    END IF;
  END LOOP;

  COMMIT;

  SELECT 200 AS status_code,
         'Seeding completed' AS message,
         v_inserted AS inserted,
         v_skipped  AS skipped;

END;
//
DELIMITER ;
#CALL seedUserGroupsForPlant('Timisoara', 'TDE, QA, OPS, Shift A, Shift B');
