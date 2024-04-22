drop procedure if exists changePassword;

delimiter //
CREATE PROCEDURE changePassword(emailParam text , user_passwordParam VARCHAR(30) , user_newpasswordParam VARCHAR(30) , user_passwordconfirmationParam VARCHAR(30))
BEGIN
if (select exists(select * from Users where email=emailParam and user_password=user_passwordParam)) then	
    if (user_newpasswordParam = user_passwordconfirmationParam ) then
		update Users
		set user_password = user_newpasswordParam
		where email=emailParam;
    else
		SIGNAL SQLSTATE '45010'
			SET MESSAGE_TEXT = 'The new passwords not match!', MYSQL_ERRNO = 1021;
	end if;    
else
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Password was not changed! Incorect credentials for current user!', MYSQL_ERRNO = 1020;
end if;
END;
//
delimiter ;