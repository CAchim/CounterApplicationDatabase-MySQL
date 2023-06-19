drop table if exists Projects;

CREATE TABLE Projects (
    entry_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    project_name VARCHAR(100) NOT NULL,
    adapter_code VARCHAR(50) NOT NULL,
    fixture_type VARCHAR(30) NOT NULL,
    owner_email TEXT NOT NULL,
    contacts INT DEFAULT 0,
    contacts_limit INT NOT NULL,
    warning_at INT NOT NULL,
    resets INT DEFAULT 0,
    testprobes TEXT,
    modified_by VARCHAR(100) NOT NULL default "ROOT",
    last_update DATETIME,
    CONSTRAINT CheckWarningLessThanLimit CHECK (
        contacts_limit > 0
        and (warning_at < contacts_limit)
    )
);