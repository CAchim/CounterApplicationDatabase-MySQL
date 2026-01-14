drop procedure if exists addTPs;

delimiter //
CREATE procedure addTPs(adapter_codeParam varchar(50), fixture_typeParam VARCHAR(30), modified_byParam VARCHAR(100), testprobesParam TEXT)
BEGIN
DECLARE inputParam text;
DECLARE project_nameParam varchar(100); 
SELECT GROUP_CONCAT(part_number, ': ', quantity, 'pcs' separator'; ') as nails INTO inputParam FROM tp_description WHERE project_id = adapter_codeParam;
if (select exists(select * from Projects where adapter_code=adapter_codeParam and fixture_type = fixture_typeParam)) then
	select project_name into project_nameParam from Projects where adapter_code=adapter_codeParam and fixture_type=fixture_typeParam;
	insert into db_logs(project_name, adapter_code, fixture_type, db_action, modified_by, last_update) values
	(
		project_nameParam,
		adapter_codeParam,
		fixture_typeParam,
		'Test probes were added for this equipment!',
		modified_byParam,
		now()
	);
	update Projects 
	set testprobes = inputParam,
		modified_by = modified_byParam,
		last_update = now()
	where adapter_code = adapter_codeParam and fixture_type = fixture_typeParam;
else
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The list of test probes was not added!', MYSQL_ERRNO = 1001;
end if;

END;
//
delimiter ;