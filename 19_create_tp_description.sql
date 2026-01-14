DROP TABLE IF EXISTS TP_description;

CREATE TABLE TP_description (
    entry_id      INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    adapter_code  VARCHAR(50)  NOT NULL,
    fixture_type  VARCHAR(30)  NOT NULL,
    fixture_plant VARCHAR(100) NOT NULL,
    part_number   VARCHAR(255) NOT NULL,
    qty           INT          NOT NULL,
    CONSTRAINT chk_tp_qty_positive CHECK (qty > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_tp_project
  ON TP_description(adapter_code, fixture_type, fixture_plant);
