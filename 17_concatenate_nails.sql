drop procedure if exists concatenateNails;

delimiter //
CREATE procedure concatenateNails
(
adapter_codeParam varchar(50), fixture_typeParam VARCHAR(30), modified_byParam VARCHAR(50), 
part_numberParam1 TEXT , quantityParam1 int, 
part_numberParam2 TEXT, quantityParam2 int, 
part_numberParam3 TEXT, quantityParam3 int, 
part_numberParam4 TEXT, quantityParam4 int, 
part_numberParam5 TEXT, quantityParam5 int, 
part_numberParam6 TEXT, quantityParam6 int, 
part_numberParam7 TEXT, quantityParam7 int, 
part_numberParam8 TEXT, quantityParam8 int, 
part_numberParam9 TEXT, quantityParam9 int, 
part_numberParam10 TEXT, quantityParam10 int)

BEGIN
DECLARE inputParam text;
DECLARE project_idParam int;
select entry_id into project_idParam from Projects where adapter_code = adapter_codeParam and fixture_type = fixture_typeParam;

if not(select exists(select* from tp_description where (part_number=part_numberParam1 or part_number=part_numberParam2 or part_number=part_numberParam3 or part_number=part_numberParam4 or part_number=part_numberParam5 or part_number=part_numberParam6 or part_number=part_numberParam7 or part_number=part_numberParam8 or part_number=part_numberParam9 or part_number=part_numberParam10) and ad_code=adapter_codeParam )) then
	insert into tp_description(project_id, ad_code, part_number, quantity) values
	(
		project_idParam,
		adapter_codeParam,
		part_numberParam1,
		quantityParam1
	);
    
    if part_numberParam2!='' then	
        insert into tp_description(project_id, ad_code, part_number, quantity) values
	(
		project_idParam,
		adapter_codeParam,
		part_numberParam2,
		quantityParam2
	);
    end if;
    
    if part_numberParam3!='' then
    	insert into tp_description(project_id, ad_code, part_number, quantity) values
	(
		project_idParam,
		adapter_codeParam,
		part_numberParam3,
		quantityParam3
	);
    end if;
    
    if part_numberParam4!='' then
    	insert into tp_description(project_id, ad_code, part_number, quantity) values
	(
		project_idParam,
		adapter_codeParam,
		part_numberParam4,
		quantityParam4
	);
    end if;
    
    if part_numberParam5!='' then
    	insert into tp_description(project_id, ad_code, part_number, quantity) values
	(
		project_idParam,
		adapter_codeParam,
		part_numberParam5,
		quantityParam5
	);
    end if;
    
    if part_numberParam6!='' then
    	insert into tp_description(project_id, ad_code, part_number, quantity) values
	(
		project_idParam,
		adapter_codeParam,
		part_numberParam6,
		quantityParam6
	);
    end if;
    
    if part_numberParam7!='' then
    	insert into tp_description(project_id, ad_code, part_number, quantity) values
	(
		project_idParam,
		adapter_codeParam,
		part_numberParam7,
		quantityParam7
	);
    end if;
    
    if part_numberParam8!='' then
    	insert into tp_description(project_id, ad_code, part_number, quantity) values
	(
		project_idParam,
		adapter_codeParam,
		part_numberParam8,
		quantityParam9
	);
    end if;
    
    if part_numberParam9!='' then
    	insert into tp_description(project_id, ad_code, part_number, quantity) values
	(
		project_idParam,
		adapter_codeParam,
		part_numberParam10,
		quantityParam10
	);
    end if;
    
    if part_numberParam10!='' then
    	insert into tp_description(project_id, ad_code, part_number, quantity) values
	(
		project_idParam,
		adapter_codeParam,
		part_numberParam1,
		quantityParam2
	);
    end if;
    
else
    SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'You already added this type of testprobes for the specified fixture!', MYSQL_ERRNO = 1001;
end if;

SELECT GROUP_CONCAT(part_number, ': ', quantity, 'pcs' separator'; ') as nails INTO inputParam FROM tp_description WHERE ad_code = adapter_codeParam;
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
