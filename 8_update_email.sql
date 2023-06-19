drop procedure if exists updateEmail;

delimiter //
CREATE PROCEDURE updateEmail(adapter_codeParam varchar(50), fixture_typeParam VARCHAR(30), owner_emailParam TEXT, modified_byParam VARCHAR(50))
BEGIN
if (select exists(select * from Projects where adapter_code=adapter_codeParam and fixture_type=fixture_typeParam)) then
update Projects 
set owner_email = owner_emailParam,
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

#call updateEmail(91, "FCT", "somaivlad@gmail.com", "vladsomai@continental.com");