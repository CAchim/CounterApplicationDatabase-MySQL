DROP PROCEDURE IF EXISTS editUser;
DELIMITER //
CREATE PROCEDURE editUser(
    IN p_entry_id INT,
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_user_id VARCHAR(50),
    IN p_email VARCHAR(255),
    IN p_user_group VARCHAR(100)
)
BEGIN
  DECLARE v_exists INT;

  -- Check if user exists
  SELECT COUNT(*) INTO v_exists
  FROM Users
  WHERE entry_id = p_entry_id;

  IF v_exists = 0 THEN
    -- User not found
    SELECT 404 AS status_code, 'User does not exist!' AS message;

  ELSE
    -- Try update
    UPDATE Users
    SET 
      first_name = p_first_name,
      last_name  = p_last_name,
      user_id    = p_user_id,
      email      = p_email,
      user_group = p_user_group
    WHERE entry_id = p_entry_id;

    IF ROW_COUNT() = 0 THEN
      -- User exists, but values were identical
      SELECT 304 AS status_code, 'No changes made (values identical)' AS message;
    ELSE
      -- Update actually changed something
      SELECT 200 AS status_code, 'User updated successfully' AS message;
    END IF;
  END IF;
END//
DELIMITER ;
