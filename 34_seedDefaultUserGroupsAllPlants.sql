DROP PROCEDURE IF EXISTS seedDefaultUserGroupsAllPlants;
DELIMITER //

CREATE PROCEDURE seedDefaultUserGroupsAllPlants()
proc_main: BEGIN
  DECLARE v_inserted INT DEFAULT 0;

  /* Error handler */
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT 500 AS status_code,
           'Unexpected database error' AS message,
           v_inserted AS inserted;
  END;

  START TRANSACTION;

  INSERT INTO user_groups (plant_id, group_name)
  SELECT p.entry_id, g.group_name
  FROM Plants p
  CROSS JOIN (
    SELECT 'admin' AS group_name
    UNION ALL SELECT 'IE'
    UNION ALL SELECT 'maintenance'
  ) AS g
  LEFT JOIN user_groups ug
    ON ug.plant_id = p.entry_id
   AND ug.group_name = g.group_name
  WHERE ug.entry_id IS NULL;

  SET v_inserted = ROW_COUNT();  -- rows inserted by the INSERT above

  COMMIT;

  SELECT 200 AS status_code,
         'Seeding completed (all plants)' AS message,
         v_inserted AS inserted;
END;
//
DELIMITER ;

-- Usage:
-- CALL seedDefaultUserGroupsAllPlants();
