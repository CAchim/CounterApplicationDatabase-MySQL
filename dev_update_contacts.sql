drop procedure if exists updateContacts;

delimiter //
CREATE PROCEDURE updateContacts(adapter_codeParam int, fixture_typeParam VARCHAR(30), contactsParam int)
BEGIN
if (select exists(select * from Projects where adapter_code=adapter_codeParam and fixture_type=fixture_typeParam)) then
update Projects 
set contacts = contactsParam
where adapter_code = adapter_codeParam and fixture_type = fixture_typeParam;
else
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The adapter code does not exist with the specified fixture type!', MYSQL_ERRNO = 1001;
end if;

END;
//
delimiter ;

#call updateContacts(101, "FCT", 0);