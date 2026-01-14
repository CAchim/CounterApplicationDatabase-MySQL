DROP TABLE IF EXISTS user_groups;

CREATE TABLE user_groups (
    entry_id   INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    plant_id   INT          NOT NULL,
    group_name VARCHAR(25)  NOT NULL,
    CONSTRAINT fk_user_groups_plant
        FOREIGN KEY (plant_id) REFERENCES Plants(entry_id)
        ON DELETE CASCADE,
    UNIQUE KEY uniq_group_per_plant (plant_id, group_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
