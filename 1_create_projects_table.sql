DROP TABLE IF EXISTS Projects;
CREATE TABLE Projects (
    entry_id       INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    project_name   VARCHAR(100) NOT NULL,
    adapter_code   VARCHAR(50)  NOT NULL,
    fixture_type   VARCHAR(30)  NOT NULL,
    fixture_plant  VARCHAR(100) NOT NULL,
    owner_email    TEXT         NOT NULL,
    contacts       INT          NOT NULL DEFAULT 0,
    contacts_limit INT          NOT NULL,
    warning_at     INT          NOT NULL,
    resets         INT          NOT NULL DEFAULT 0,
    testprobes     TEXT         NULL,
    modified_by    VARCHAR(100) NOT NULL DEFAULT 'ROOT',
    last_update    DATETIME NULL,
    CONSTRAINT CheckWarningLessThanLimit CHECK (
        contacts_limit > 0 AND warning_at < contacts_limit
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE UNIQUE INDEX uniq_proj_per_plant
  ON Projects(fixture_plant, adapter_code, fixture_type);
