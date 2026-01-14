DROP TABLE IF EXISTS Plants;

CREATE TABLE Plants (
    entry_id   INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    plant_name VARCHAR(25)     NOT NULL,
    UNIQUE KEY uniq_plant_name (plant_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
