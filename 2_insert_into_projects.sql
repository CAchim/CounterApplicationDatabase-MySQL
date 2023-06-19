drop procedure if exists insertProject;

delimiter //
CREATE procedure insertProject(project_nameParam varchar(100), adapter_codeParam varchar(50), fixture_typeParam VARCHAR(30), owner_emailParam TEXT, contacts_limitParam int, warning_atParam int, modified_byParam VARCHAR(100))
BEGIN

if not(select exists(select* from Projects where adapter_code=adapter_codeParam and fixture_type=fixture_typeParam)) then

insert into Projects (project_name, adapter_code, fixture_type, owner_email, contacts_limit, warning_at, modified_by, last_update) values
(
project_nameParam,
adapter_codeParam,
fixture_typeParam,
owner_emailParam,
contacts_limitParam,
warning_atParam,
modified_byParam,
now()
);

else
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The adapter code already exists with the specified fixture type!', MYSQL_ERRNO = 1002;
end if;

END;
//
delimiter ;



######################### FCT PROJECT #########################
call insertProject("BR213 GFX",91,"FCT","root",80000,70000,"root");
call insertProject("BR222 Mopf KAF",92,"FCT","root",80000,70000,"root");
call insertProject("VS30 LOW MID",101,"FCT","root",80000,70000,"root");
call insertProject("FIAT 330 MCA",104,"FCT","root",80000,70000,"root");
call insertProject("VS30 HIGH",105,"FCT","root",80000,70000,"root");
call insertProject("BR213 GFX",110,"FCT","root",80000,70000,"root");
call insertProject("BR205 MY18 MPH",112,"FCT","root",80000,70000,"root");
call insertProject("BR213 GFX",113,"FCT","root",80000,70000,"root");
call insertProject("BR205 MY18",118,"FCT","root",80000,70000,"root");
call insertProject("BR205 MY18",121,"FCT","root",80000,70000,"root");
call insertProject("BR205 MY18",123,"FCT","root",80000,70000,"root");
call insertProject("BR205 MY18 MPH",124,"FCT","root",80000,70000,"root");
call insertProject("SILVERBOX JCP 2016",125,"FCT","root",80000,70000,"root");
call insertProject("BR 213 ILLUMINATION JCP 2016",126,"FCT","root",80000,70000,"root");
call insertProject("BR213 AUTOMOTIVE JCP 2016",128,"FCT","root",80000,70000,"root");
call insertProject("BR213 AUTOMOTIVE JCP 2016",129,"FCT","root",80000,70000,"root");
call insertProject("BR213 GFX",130,"FCT","root",80000,70000,"root");
call insertProject("BR213 GFX",131,"FCT","root",80000,70000,"root");
call insertProject("BR213 SD-MID JCP 2016",132,"FCT","root",80000,70000,"root");
call insertProject("VW FPK MEDIUM",133,"FCT","root",80000,70000,"root");
call insertProject("VW SEAT SATELITE",134,"FCT","root",80000,70000,"root");
call insertProject("AUDI SATELITE",135,"FCT","root",80000,70000,"root");
call insertProject("VW MQB HUD LHD ",136,"FCT","root",80000,70000,"root");
call insertProject("RENAULT M0",137,"FCT","root",80000,70000,"root");
call insertProject("VW BACKLIGHT",138,"FCT","root",80000,70000,"root");
call insertProject("RENAULT M0",139,"FCT","root",80000,70000,"root");
call insertProject("BR213 AUTOMOTIVE JCP 2016",140,"FCT","root",80000,70000,"root");
call insertProject("BR213 AUTOMOTIVE JCP 2016",141,"FCT","root",80000,70000,"root");
call insertProject("VW SKODA SATELITE",142,"FCT","root",80000,70000,"root");
call insertProject("VW FPK MAIN",143,"FCT","root",80000,70000,"root");
call insertProject("VW HUD RHD",144,"FCT","root",80000,70000,"root");
call insertProject("VW FPK MAIN",145,"FCT","root",80000,70000,"root");
call insertProject("SKODA SATELLITE AUX ",147,"FCT","root",80000,70000,"root");
call insertProject("BR206 LED",148,"FCT","root",80000,70000,"root");
call insertProject("VW FPK MAIN",151,"FCT","root",80000,70000,"root");
call insertProject("VW FPK MAIN",152,"FCT","root",80000,70000,"root");
call insertProject("VW FPK MAIN",153,"FCT","root",80000,70000,"root");
call insertProject("VW FPK MAIN",154,"FCT","root",80000,70000,"root");
call insertProject("PSA eHUD LHD",155,"FCT","root",80000,70000,"root");
call insertProject("PSA eHUD RHD",156,"FCT","root",80000,70000,"root");
call insertProject("FIAT 500 BEV",157,"FCT","root",80000,70000,"root");
call insertProject("PSA eHUD SENSOR",158,"FCT","root",80000,70000,"root");
call insertProject("BR206 HUD LHD",159,"FCT","root",80000,70000,"root");
call insertProject("VW FPK MAIN MY21",160,"FCT","root",80000,70000,"root");
call insertProject("BR206 HUD RHD",161,"FCT","root",80000,70000,"root");
call insertProject("Fiat 356MCA",162,"FCT","root",80000,70000,"root");
call insertProject("VW FPK MAIN",163,"FCT","root",80000,70000,"root");
call insertProject("BMW DCS IR LED'S Cassette 1",164,"FCT","root",80000,70000,"root");
call insertProject("BMW DCS IR LED'S Cassette 1",165,"FCT","root",80000,70000,"root");
call insertProject("BMW DCS IR LED'S Cassette 2",166,"FCT","root",80000,70000,"root");
call insertProject("BMW DCS IR LED'S Cassette 3",167,"FCT","root",80000,70000,"root");
call insertProject("BMW DCS Interface",168,"FCT","root",80000,70000,"root");
call insertProject("BMW AZV CID LHD ",169,"FCT","root",80000,70000,"root");
call insertProject("BMW AZV DFE LHD",170,"FCT","root",80000,70000,"root");
call insertProject("BMW AZV ALS",171,"FCT","root",80000,70000,"root");
call insertProject("BMW AZV CID RHD",172,"FCT","root",80000,70000,"root");
call insertProject("BMW AZV DFE RHD",173,"FCT","root",80000,70000,"root");
call insertProject("BR206 HUD LHD",174,"FCT","root",80000,70000,"root");
call insertProject("BR206 HUD RHD",175,"FCT","root",80000,70000,"root");
call insertProject("BMW AZV DFE Backlight Cassette 1",177,"FCT","root",80000,70000,"root");
call insertProject("BMW AZV DFE Backlight Cassette 2",178,"FCT","root",80000,70000,"root");
call insertProject("VS11",179,"FCT","root",80000,70000,"root");
call insertProject("BMW AZV CID Backlight Cassette 1",181,"FCT","root",80000,70000,"root");
call insertProject("BMW AZV CID Backlight Cassette 2",182,"FCT","root",80000,70000,"root");
call insertProject("VW C-HUD",183,"FCT","root",80000,70000,"root");

######################### ICT PROJECT #########################
call insertProject("W222",1021,"ICT","root",80000,70000,"root");
call insertProject("FORD M0",1030,"ICT","root",80000,70000,"root");
call insertProject("FORD M1 ",1031,"ICT","root",80000,70000,"root");
call insertProject("HUD 205 LEFT 2",1117,"ICT","root",80000,70000,"root");
call insertProject("HUD 205 RIGHT",1118,"ICT","root",80000,70000,"root");
call insertProject("FORD M1 NOU",1287,"ICT","root",80000,70000,"root");
call insertProject("LANCIA\FIAT",1410,"ICT","root",80000,70000,"root");
call insertProject("RENAULT ILLUMINATION",1502,"ICT","root",80000,70000,"root");
call insertProject("HUD LEFT BR213/1",1504,"ICT","root",80000,70000,"root");
call insertProject("HUD RIGHT BR213",1505,"ICT","root",80000,70000,"root");
call insertProject("FIAT 330 MCA",1517,"ICT","root",80000,70000,"root");
call insertProject("HUD JCP 2016 LHD NR1",1522,"ICT","root",80000,70000,"root");
call insertProject("HUD JCP 2016 RHD",1523,"ICT","root",80000,70000,"root");
call insertProject("RENAULT C-HUD JCP 2016",1524,"ICT","root",80000,70000,"root");
call insertProject("HUD  JCP 2016 LHD NR2",1525,"ICT","root",80000,70000,"root");
call insertProject("HUD JCP 2016 RHD NR2",1526,"ICT","root",80000,70000,"root");
call insertProject("SILVERBOX JCP 2016",1528,"ICT","root",80000,70000,"root");
call insertProject("VW HUD LHD",1529,"ICT","root",80000,70000,"root");
call insertProject("VW HUD RHD",1530,"ICT","root",80000,70000,"root");
call insertProject("MOPF HUD LEFT",1532,"ICT","root",80000,70000,"root");
call insertProject("VW HUD LED",1531,"ICT","root",80000,70000,"root");
call insertProject("MOPF HUD RIGHT",1533,"ICT","root",80000,70000,"root");
call insertProject("BR213 AUTOMOTIVE JCP 2016",1606,"ICT","root",80000,70000,"root");
call insertProject("MFA 2 LED",1608,"ICT","root",80000,70000,"root");
call insertProject("MFA 2 HUD RH",1613,"ICT","root",80000,70000,"root");
call insertProject("BR213 AUTOMOTIVE JCP 2016",1616,"ICT","root",80000,70000,"root");
call insertProject("BR213 AUTOMOTIVE JCP 2016",1617,"ICT","root",80000,70000,"root");
call insertProject("AUDI SATELITE",1618,"ICT","root",80000,70000,"root");
call insertProject("VW SEAT SATELITE",1619,"ICT","root",80000,70000,"root");
call insertProject("VW SKODA SATELITE",1620,"ICT","root",80000,70000,"root");
call insertProject("SKODA SATELLITE AUX MY 21",1622,"ICT","root",80000,70000,"root");
call insertProject("VW FPK MAIN MY21",1623,"ICT","root",80000,70000,"root");
call insertProject("FIAT 500 BEV",1624,"ICT","root",80000,70000,"root");
call insertProject("BMW DCS Interface",1625,"ICT","root",80000,70000,"root");
call insertProject("Fiat 356MCA",1626,"ICT","root",80000,70000,"root");
call insertProject("BMW AZV DFE LHD",1627,"ICT","root",80000,70000,"root");
call insertProject("BMW AZV DFE RHD",1628,"ICT","root",80000,70000,"root");
call insertProject("BMW AZV CID LHD ",1629,"ICT","root",80000,70000,"root");
call insertProject("BMW AZV CID RHD   ",1630,"ICT","root",80000,70000,"root");
call insertProject("BR213 HUD LEFT LHD",1700,"ICT","root",80000,70000,"root");
call insertProject("BR213 HUD Right RHD",1701,"ICT","root",80000,70000,"root");
call insertProject("BR206 HUD LHD",1702,"ICT","root",80000,70000,"root");
call insertProject("BR206 HUD RHD",1703,"ICT","root",80000,70000,"root");
call insertProject("PSA eHUD LHD",1704,"ICT","root",80000,70000,"root");
call insertProject("PSA eHUD RHD",1705,"ICT","root",80000,70000,"root");
call insertProject("VW C-HUD",1706,"ICT","root",80000,70000,"root");
call insertProject("FIAT 356 HIGH JCP 2016 NR.2(ICT2)",1990,"ICT","root",80000,70000,"root");
call insertProject("HUD 213 LED",2047,"ICT","root",80000,70000,"root");
call insertProject("RENAULT ILLUMINATION JCP 2016",2049,"ICT","root",80000,70000,"root");
call insertProject("FIAT 356 HIGH JCP 2016 (ICT5)",2175,"ICT","root",80000,70000,"root");
call insertProject("FIAT 356 BASE JCP 2016",2176,"ICT","root",80000,70000,"root");
call insertProject("BR213 SD-MID JCP 2016",2400,"ICT","root",80000,70000,"root");
call insertProject("BR213 GFX",3045,"ICT","root",80000,70000,"root");
call insertProject("BR213 GFX",3046,"ICT","root",80000,70000,"root");
call insertProject("HUD LEFT BR213/2",3218,"ICT","root",80000,70000,"root");
call insertProject("BR213 GFX",3047,"ICT","root",80000,70000,"root");
call insertProject("VS30 HIGH",4042,"ICT","root",80000,70000,"root");
call insertProject("VS30 LOW MID",4045,"ICT","root",80000,70000,"root");
call insertProject("FORD UP375 MY18",4054,"ICT","root",80000,70000,"root");
