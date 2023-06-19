drop table if exists TP_description;

CREATE TABLE TP_description (
    entry_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    project_id INT NOT NULL,
    ad_code VARCHAR(50) NOT NULL,
    part_number TEXT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY(project_id)
       REFERENCES Projects(entry_id)
);