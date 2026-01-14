DROP PROCEDURE IF EXISTS fetchUsersByPlant;
DELIMITER //

CREATE PROCEDURE fetchUsersByPlant(IN p_plant_name VARCHAR(100))
main_block: BEGIN
  DECLARE v_plant_id INT;

  -- Error handler
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT 500 AS status_code, 'Unexpected DB error' AS message;
  END;

  -- Find the plant_id
  SELECT entry_id INTO v_plant_id
  FROM Plants
  WHERE plant_name = p_plant_name
  LIMIT 1;

  IF v_plant_id IS NULL THEN
    SELECT 404 AS status_code, CONCAT('Plant not found: ', p_plant_name) AS message;
    LEAVE main_block;
  END IF;

  -- Return users joined with groups
  SELECT
    u.entry_id,
    u.first_name,
    u.last_name,
    u.user_id,
    u.email,
    g.group_name AS user_group
  FROM Users u
  JOIN user_groups g ON g.entry_id = u.group_id
  WHERE u.plant_id = v_plant_id
  ORDER BY u.first_name, u.last_name;

END;
//
DELIMITER ;
