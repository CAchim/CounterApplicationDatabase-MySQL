drop procedure if exists updateLimitWarning;

delimiter //
CREATE PROCEDURE updateLimitWarning(adapter_codeParam varchar(50), fixture_typeParam VARCHAR(30), contacts_limitParam int, warning_atParam int, modified_byParam VARCHAR(50))
BEGIN

if (select exists(select * from Projects where adapter_code=adapter_codeParam and fixture_type=fixture_typeParam)) then
update Projects 
set contacts_limit = contacts_limitParam,
	warning_at = warning_atParam,
    modified_by = modified_byParam,
    last_update = now()
where adapter_code = adapter_codeParam and fixture_type = fixture_typeParam;
else
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The adapter code does not exist with the specified fixture type!', MYSQL_ERRNO = 1001;
end if;

END;
//
delimiter ;

#call updateLimitWarning(1706, "ICT", 55000, 65000, "admin");

