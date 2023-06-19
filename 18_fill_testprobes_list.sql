drop procedure if exists fillTestprobeslist;

delimiter //
CREATE procedure fillTestprobeslist(part_numberParam TEXT, supplierParam VARCHAR(50))
BEGIN

if not(select exists(select* from TestProbes where part_number=part_numberParam )) then

insert into TestProbes (part_number, supplier, last_update) values
(
part_numberParam,
supplierParam,
now()
);

else
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The part number already exists!', MYSQL_ERRNO = 1089;
end if;

END;
//
delimiter ;

call fillTestprobeslist("100-PRG2599S", "INGUN");
call fillTestprobeslist("075-PRG2599H", "INGUN");
call fillTestprobeslist("GKS-100 307 150 A 2000", "INGUN");
call fillTestprobeslist("GKS-100 307 150 A 2000 LH", "INGUN");
call fillTestprobeslist("GKS-100 297 090 A 2000", "INGUN");
call fillTestprobeslist("GKS-075 297 090 A 2000", "INGUN");
call fillTestprobeslist("GKS-100 297 090 A 2000 LH", "INGUN");
call fillTestprobeslist("GKS-075 297 090 A 2000 LH", "INGUN");
call fillTestprobeslist("E-100 297 090 A 2000", "INGUN");
call fillTestprobeslist("GKS-051 303 090 A 1300", "INGUN");
call fillTestprobeslist("GKS-051 303 150 A 1300", "INGUN");
call fillTestprobeslist("GKS-100 306 150 A 2000", "INGUN");
call fillTestprobeslist("GKS-100 303 150 A 2000", "INGUN");
call fillTestprobeslist("GKS-938 307 180 A 1500", "INGUN");
call fillTestprobeslist("PKS-171 214 050 A 0302 A", "INGUN");
call fillTestprobeslist("HFS-819 303 090 A 12743 RV5", "INGUN");