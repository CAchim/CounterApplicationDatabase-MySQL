drop procedure if exists findUser;

delimiter //
CREATE PROCEDURE findUser(emailParam text)
BEGIN
if (select exists(select * from Users where email=emailParam)) then
select user_id from Users 
where email=emailParam;
else
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The specified email address is not linked to any created account!', MYSQL_ERRNO = 1020;
end if;
END;
//
delimiter ;