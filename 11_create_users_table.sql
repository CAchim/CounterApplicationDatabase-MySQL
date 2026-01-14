DROP TABLE IF EXISTS Users;

CREATE TABLE Users (
    entry_id      INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    first_name    VARCHAR(100) NOT NULL,
    last_name     VARCHAR(100) NOT NULL,
    user_id       VARCHAR(50)  NOT NULL,
    email         VARCHAR(255) NOT NULL,
    user_password VARCHAR(255) NOT NULL,
    user_group    VARCHAR(100),
    plant_id      INT NOT NULL,  -- FK to Plants
    group_id      INT NOT NULL,  -- FK to user_groups
    user_token    VARCHAR(100) NOT NULL
                  DEFAULT '16d5c19d0c22059793de23406140e67dbdc1f8a5ae579b5185ae83d562cda7e6',
    CONSTRAINT fk_users_plant FOREIGN KEY (plant_id)
        REFERENCES Plants(entry_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_users_group FOREIGN KEY (group_id)
        REFERENCES user_groups(entry_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
