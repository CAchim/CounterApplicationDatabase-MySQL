drop table if exists Users;

CREATE TABLE Users (
    entry_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    user_id VARCHAR(10) NOT NULL,
    email TEXT NOT NULL,
    user_password VARCHAR(30) NOT NULL,
    user_group VARCHAR(20) NOT NULL,
    user_token TEXT NOT NULL
    
);