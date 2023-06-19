drop procedure if exists addTPs;

delimiter //
CREATE procedure addTPs(adapter_codeParam varchar(50), fixture_typeParam VARCHAR(30), modified_byParam VARCHAR(100), testprobesParam TEXT)
BEGIN
DECLARE inputParam text;
SELECT GROUP_CONCAT(part_number, ': ', quantity, 'pcs' separator'; ') as nails INTO inputParam FROM tp_description WHERE project_id = adapter_codeParam;
if (select exists(select * from Projects where adapter_code=adapter_codeParam and fixture_type = fixture_typeParam)) then
	update Projects 
	set testprobes = inputParam,
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