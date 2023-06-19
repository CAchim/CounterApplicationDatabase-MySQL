drop procedure if exists removeTPs;

delimiter //
CREATE PROCEDURE removeTPs(adapter_codeParam VARCHAR(10), fixture_typeParam VARCHAR(30), modified_byParam VARCHAR(50))
BEGIN

DECLARE project_idParam int;

if (select exists(select * from Projects where adapter_code=adapter_codeParam and fixture_type=fixture_typeParam)) then
select entry_id into project_idParam from Projects where adapter_code=adapter_codeParam and fixture_type=fixture_typeParam;

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
