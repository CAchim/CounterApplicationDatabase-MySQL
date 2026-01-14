drop procedure if exists addPlant;

delimiter //
CREATE procedure addPlant(plant_nameParam VARCHAR(25))
BEGIN

    IF NOT EXISTS (SELECT * FROM Plants WHERE plant_name = plant_nameParam) THEN
        INSERT INTO Plants (plant_name) VALUES (plant_nameParam);
    ELSE
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The plant is already in the table!', MYSQL_ERRNO = 1015;
    END IF;

END;
//
delimiter ;
