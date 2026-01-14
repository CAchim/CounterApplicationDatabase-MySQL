drop procedure if exists test;
delimiter //
CREATE PROCEDURE test(adapter_codeParam varchar(10), fixture_typeParam VARCHAR(30),modified_byParam VARCHAR(100))
begin
DECLARE project_nameParam varchar(100);
if (select exists(select * from Projects where adapter_code=adapter_codeParam and fixture_type=fixture_typeParam)) then
	select project_name into project_nameParam from Projects where adapter_code=adapter_codeParam and fixture_type=fixture_typeParam;
	insert into db_logs(project_name, adapter_code, fixture_type, db_action, modified_by, last_update) values
	(
		project_nameParam,
		adapter_codeParam,
		fixture_typeParam,
		'Equipment was removed from the database',
		modified_byParam,
		now()
	);
end if;
end;
//
delimiter ;

#call test(91,'FCT');