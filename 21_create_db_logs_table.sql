DROP TABLE IF EXISTS db_logs;
CREATE TABLE db_logs (
    entry_id      INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    project_name  VARCHAR(100) NOT NULL,
    adapter_code  VARCHAR(50)  NOT NULL,
    fixture_type  VARCHAR(30)  NOT NULL,
    db_action     TEXT,
    modified_by   VARCHAR(100) NOT NULL DEFAULT 'ROOT',
    last_update   DATETIME,
    fixture_plant VARCHAR(100) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
