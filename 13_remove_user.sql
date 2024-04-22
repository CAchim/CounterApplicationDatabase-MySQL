drop procedure if exists removeUser;

delimiter //
CREATE PROCEDURE removeUser(user_idParam VARCHAR(10))
BEGIN

DECLARE userParam int;

if (select exists(select * from Users where user_id = user_idParam)) then
select entry_id into userParam from Users where user_id = user_idParam;

#delete the actual row
delete from Users 
where user_id = user_idParam;
else
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The user does not exist!', MYSQL_ERRNO = 1010;
end if;
END;
//
delimiter ;

#call removeUser("uic12345");