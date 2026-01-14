DROP PROCEDURE IF EXISTS removeUser;
DELIMITER //
CREATE PROCEDURE removeUser(IN p_entry_id INT)
BEGIN
  IF (SELECT EXISTS(SELECT 1 FROM Users WHERE entry_id = p_entry_id)) THEN
    DELETE FROM Users 
    WHERE entry_id = p_entry_id;

    SELECT 200 AS status_code, 'User removed successfully' AS message;
  ELSE
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The user does not exist!', MYSQL_ERRNO = 1010;
  END IF;
END;
//
DELIMITER ;
