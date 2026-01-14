drop procedure if exists removeTPs;

delimiter //
CREATE PROCEDURE removeTPs(adapter_codeParam VARCHAR(10), fixture_typeParam VARCHAR(30), modified_byParam VARCHAR(50))
BEGIN

DECLARE project_idParam int;
DECLARE project_nameParam varchar(100); 
if (select exists(select * from Projects where adapter_code=adapter_codeParam and fixture_type=fixture_typeParam)) then
select entry_id into project_idParam from Projects where adapter_code=adapter_codeParam and fixture_type=fixture_typeParam;
	select project_name into project_nameParam from Projects where adapter_code=adapter_codeParam and fixture_type=fixture_typeParam;
	insert into db_logs(project_name, adapter_code, fixture_type, db_action, modified_by, last_update) values
	(
		project_nameParam,
		adapter_codeParam,
		fixture_typeParam,
		'Test probes were removed for this equipment!',
		modified_byParam,
		now()
	);
#delete the actual row
delete from tp_description 
where ad_code = adapter_codeParam;

update Projects 
set 
	testprobes = "",
    modified_by = modified_byParam,
	last_update = now()
where adapter_code = adapter_codeParam and fixture_type = fixture_typeParam;

else
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The user does not exist!', MYSQL_ERRNO = 1078;
end if;
END;
//
delimiter ;
