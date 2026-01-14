drop procedure if exists updateContactsLimit;

delimiter //
CREATE PROCEDURE updateContactsLimit(adapter_codeParam varchar(50), fixture_typeParam VARCHAR(30), contacts_limitParam int, modified_byParam VARCHAR(50))
BEGIN
DECLARE project_nameParam varchar(100); 
if (select exists(select * from Projects where adapter_code=adapter_codeParam and fixture_type=fixture_typeParam)) then
select project_name into project_nameParam from Projects where adapter_code=adapter_codeParam and fixture_type=fixture_typeParam;
	insert into db_logs(project_name, adapter_code, fixture_type, db_action, modified_by, last_update) values
	(
		project_nameParam,
		adapter_codeParam,
		fixture_typeParam,
		'The limits for the equipment have been modified!',
		modified_byParam,
		now()
	);
update Projects 
set contacts_limit = contacts_limitParam,
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

#call updateContactsLimit(1705, "FCT", 80001, "admin");