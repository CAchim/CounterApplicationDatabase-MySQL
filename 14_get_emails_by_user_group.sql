drop procedure if exists getEmailsByUserGroup;

delimiter //
CREATE PROCEDURE getEmailsByUserGroup(user_groupParam VARCHAR(20))
BEGIN
DECLARE receiversParam text;
if (select exists(select * from Users where user_group = user_groupParam)) then
select GROUP_CONCAT(email separator';') as receivers into receiversParam from Users 
where user_group = user_groupParam;
select receiversParam;
else
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'No email available with the specified user group!', MYSQL_ERRNO = 1011;
end if;
END;
//
delimiter ;
