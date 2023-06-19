drop procedure if exists updateTemperature;

delimiter //
CREATE PROCEDURE updateTemperature(adapter_codeParam int, fixture_typeParam VARCHAR(30), temperatureParam int)
BEGIN
if (select exists(select * from Projects where adapter_code=adapter_codeParam and fixture_type=fixture_typeParam)) then
update Projects 
set temperature = temperatureParam
where adapter_code = adapter_codeParam and fixture_type = fixture_typeParam;
else
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The adapter code does not exist with the specified fixture type!', MYSQL_ERRNO = 1001;
end if;

END;
//
delimiter ;

#call updateTemperature(91, "FCT", 23);

