-- ================================
--  COUNTERDB MASTER SQL SCRIPT
--  Tables (with legacy patches)
-- ================================

USE counterdb;


SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;

SET @OLD_SQL_NOTES=@@sql_notes; 
SET sql_notes=0;

-- =========================
-- 1. TABLES
-- =========================

/*------------------------------------------------------------
  1.1 Plants
------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS Plants (
    entry_id   INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    plant_name VARCHAR(25)     NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ensure unique index on plant_name
SET @idx := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'Plants'
    AND index_name   = 'uniq_plant_name'
);
SET @sql := IF(@idx = 0,
    'CREATE UNIQUE INDEX uniq_plant_name ON Plants(plant_name);',
    'SELECT ''uniq_plant_name exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;


/*------------------------------------------------------------
  1.2 user_groups
------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS user_groups (
    entry_id   INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    plant_id   INT          NOT NULL,
    group_name VARCHAR(25)  NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- add FK to Plants if missing
SET @fk := (
  SELECT COUNT(*)
  FROM information_schema.TABLE_CONSTRAINTS
  WHERE table_schema = DATABASE()
    AND table_name   = 'user_groups'
    AND constraint_name = 'fk_user_groups_plant'
);
SET @sql := IF(@fk = 0,
    'ALTER TABLE user_groups ADD CONSTRAINT fk_user_groups_plant FOREIGN KEY (plant_id) REFERENCES Plants(entry_id) ON DELETE CASCADE;',
    'SELECT ''fk_user_groups_plant exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- unique index per plant+group
SET @idx := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'user_groups'
    AND index_name   = 'uniq_group_per_plant'
);
SET @sql := IF(@idx = 0,
    'CREATE UNIQUE INDEX uniq_group_per_plant ON user_groups(plant_id, group_name);',
    'SELECT ''uniq_group_per_plant exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;


/*------------------------------------------------------------
  1.3 Users (patch legacy structure)
------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS Users (
    entry_id      INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    first_name    VARCHAR(100) NOT NULL,
    last_name     VARCHAR(100) NOT NULL,
    user_id       VARCHAR(50)  NOT NULL,
    email         VARCHAR(255) NOT NULL,
    user_password VARCHAR(255) NOT NULL,
    user_group    VARCHAR(100),
    plant_id      INT,
    group_id      INT,
    user_token    VARCHAR(100) NOT NULL, 
    must_change_password TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- plant_id
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'Users'
    AND column_name  = 'plant_id'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE Users ADD COLUMN plant_id INT NULL;',
  'SELECT ''Users.plant_id exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- group_id
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'Users'
    AND column_name  = 'group_id'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE Users ADD COLUMN group_id INT NULL;',
  'SELECT ''Users.group_id exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- user_group
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'Users'
    AND column_name  = 'user_group'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE Users ADD COLUMN user_group VARCHAR(100) NULL;',
  'SELECT ''Users.user_group exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- user_token
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'Users'
    AND column_name  = 'user_token'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE Users ADD COLUMN user_token VARCHAR(100) NOT NULL DEFAULT ''16d5c19d0c22059793de23406140e67dbdc1f8a5ae579b5185ae83d562cda7e6'';',
  'SELECT ''Users.user_token exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- must_change_password
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'Users'
    AND column_name  = 'must_change_password'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE Users ADD COLUMN must_change_password TINYINT(1) NOT NULL DEFAULT 1;',
  'SELECT ''Users.must_change_password exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- FK: Users.plant_id → Plants.entry_id
SET @fk := (
  SELECT COUNT(*)
  FROM information_schema.TABLE_CONSTRAINTS
  WHERE table_schema = DATABASE()
    AND table_name   = 'Users'
    AND constraint_name = 'fk_users_plant'
);
SET @sql := IF(@fk = 0,
    'ALTER TABLE Users ADD CONSTRAINT fk_users_plant FOREIGN KEY (plant_id) REFERENCES Plants(entry_id) ON DELETE CASCADE;',
    'SELECT ''fk_users_plant exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- FK: Users.group_id → user_groups.entry_id
SET @fk := (
  SELECT COUNT(*)
  FROM information_schema.TABLE_CONSTRAINTS
  WHERE table_schema = DATABASE()
    AND table_name   = 'Users'
    AND constraint_name = 'fk_users_group'
);
SET @sql := IF(@fk = 0,
    'ALTER TABLE Users ADD CONSTRAINT fk_users_group FOREIGN KEY (group_id) REFERENCES user_groups(entry_id) ON DELETE CASCADE;',
    'SELECT ''fk_users_group exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Ensure unique user_id
SET @idx := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'Users'
    AND index_name   = 'uniq_user_id'
);
SET @sql := IF(
  @idx = 0,
  'CREATE UNIQUE INDEX uniq_user_id ON Users(user_id);',
  'SELECT ''uniq_user_id exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Ensure Users.email is VARCHAR (not TEXT/BLOB) so unique index works
SET @col_type := (
    SELECT DATA_TYPE
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'Users'
      AND column_name  = 'email'
);
SET @sql := IF(
    @col_type IN ('text','blob','mediumtext','longtext'),
    'ALTER TABLE Users MODIFY email VARCHAR(255) NOT NULL;',
    'SELECT ''Users.email already VARCHAR'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;


-- Ensure unique email
SET @idx := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'Users'
    AND index_name   = 'uniq_user_email'
);
SET @sql := IF(
  @idx = 0,
  'CREATE UNIQUE INDEX uniq_user_email ON Users(email);',
  'SELECT ''uniq_user_email exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;



/*------------------------------------------------------------
  1.4 Projects (add fixture_plant for multi-plant)
------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS Projects (
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
    last_update    DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ensure fixture_plant exists on legacy Projects
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'Projects'
    AND column_name  = 'fixture_plant'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE Projects ADD COLUMN fixture_plant VARCHAR(100) NOT NULL DEFAULT ''Timisoara'' AFTER fixture_type;',
  'SELECT ''Projects.fixture_plant exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- normalize NULL/empty fixture_plant -> Timisoara
UPDATE Projects
SET fixture_plant = 'Timisoara'
WHERE fixture_plant IS NULL OR fixture_plant = '';

-- unique index per plant + adapter + fixture
SET @idx := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'Projects'
    AND index_name   = 'uniq_proj_per_plant'
);
SET @sql := IF(
  @idx = 0,
  'CREATE UNIQUE INDEX uniq_proj_per_plant ON Projects(fixture_plant, adapter_code, fixture_type);',
  'SELECT ''uniq_proj_per_plant exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;


/*------------------------------------------------------------
  1.5 tp_description  (migrate legacy → multi-plant, dedup with MAX(qty))
------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS tp_description (
    entry_id      INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    adapter_code  VARCHAR(50)  NOT NULL,
    fixture_type  VARCHAR(30)  NOT NULL,
    fixture_plant VARCHAR(100) NOT NULL,
    part_number   VARCHAR(255) NOT NULL,
    qty           INT          NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Drop unique index temporarily if it exists to avoid 1062 during migration
SET @idx := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'tp_description'
    AND index_name   = 'uniq_tp_per_project_part'
);
SET @sql := IF(
  @idx > 0,
  'ALTER TABLE tp_description DROP INDEX `uniq_tp_per_project_part`;',
  'SELECT ''uniq_tp_per_project_part not present or already dropped'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Add new columns if this is legacy table
-- adapter_code
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'tp_description'
    AND column_name  = 'adapter_code'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE tp_description ADD COLUMN adapter_code VARCHAR(50) NULL;',
  'SELECT ''tp_description.adapter_code exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- fixture_type
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'tp_description'
    AND column_name  = 'fixture_type'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE tp_description ADD COLUMN fixture_type VARCHAR(30) NULL;',
  'SELECT ''tp_description.fixture_type exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- fixture_plant
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'tp_description'
    AND column_name  = 'fixture_plant'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE tp_description ADD COLUMN fixture_plant VARCHAR(100) NULL;',
  'SELECT ''tp_description.fixture_plant exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- qty
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'tp_description'
    AND column_name  = 'qty'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE tp_description ADD COLUMN qty INT NULL;',
  'SELECT ''tp_description.qty exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Detect legacy layout: project_id + quantity
SET @old_project_id_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'tp_description'
    AND column_name  = 'project_id'
);
SET @old_quantity_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'tp_description'
    AND column_name  = 'quantity'
);

-- If legacy columns exist, migrate into new columns using Projects
SET @sql := IF(
  @old_project_id_exists > 0 AND @old_quantity_exists > 0,
  'UPDATE tp_description t
     JOIN Projects p ON p.entry_id = t.project_id
     SET t.adapter_code  = p.adapter_code,
         t.fixture_type  = p.fixture_type,
         t.fixture_plant = p.fixture_plant,
         t.qty           = t.quantity;',
  'SELECT ''Legacy tp_description migration step not needed'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Drop legacy foreign key (if any) on project_id
SET @fk_name := (
  SELECT CONSTRAINT_NAME
  FROM information_schema.KEY_COLUMN_USAGE
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME   = 'tp_description'
    AND COLUMN_NAME  = 'project_id'
    AND REFERENCED_TABLE_NAME = 'Projects'
  LIMIT 1
);
SET @sql := IF(
  @fk_name IS NOT NULL,
  CONCAT('ALTER TABLE tp_description DROP FOREIGN KEY `', @fk_name, '`;'),
  'SELECT ''No legacy FK on tp_description.project_id'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Drop legacy columns if still present
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'tp_description'
    AND column_name  = 'project_id'
);
SET @sql := IF(
  @col_exists > 0,
  'ALTER TABLE tp_description DROP COLUMN project_id;',
  'SELECT ''tp_description.project_id already dropped'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'tp_description'
    AND column_name  = 'ad_code'
);
SET @sql := IF(
  @col_exists > 0,
  'ALTER TABLE tp_description DROP COLUMN ad_code;',
  'SELECT ''tp_description.ad_code already dropped'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'tp_description'
    AND column_name  = 'quantity'
);
SET @sql := IF(
  @col_exists > 0,
  'ALTER TABLE tp_description DROP COLUMN quantity;',
  'SELECT ''tp_description.quantity already dropped'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- DEDUP: merge duplicates using MAX(qty)
DROP TEMPORARY TABLE IF EXISTS tp_dedup;
CREATE TEMPORARY TABLE tp_dedup AS
SELECT
    adapter_code,
    fixture_type,
    fixture_plant,
    part_number,
    MAX(qty) AS qty
FROM tp_description
GROUP BY
    adapter_code,
    fixture_type,
    fixture_plant,
    part_number;

TRUNCATE TABLE tp_description;

INSERT INTO tp_description(adapter_code, fixture_type, fixture_plant, part_number, qty)
SELECT adapter_code, fixture_type, fixture_plant, part_number, qty
FROM tp_dedup;

DROP TEMPORARY TABLE IF EXISTS tp_dedup;

-- Tighten new columns (only if there are no NULLs)
SET @nulls := (SELECT COUNT(*) FROM tp_description WHERE adapter_code IS NULL);
SET @sql := IF(
  @nulls = 0,
  'ALTER TABLE tp_description MODIFY adapter_code VARCHAR(50) NOT NULL;',
  'SELECT ''Skip NOT NULL for adapter_code (NULL rows exist)'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @nulls := (SELECT COUNT(*) FROM tp_description WHERE fixture_type IS NULL);
SET @sql := IF(
  @nulls = 0,
  'ALTER TABLE tp_description MODIFY fixture_type VARCHAR(30) NOT NULL;',
  'SELECT ''Skip NOT NULL for fixture_type (NULL rows exist)'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @nulls := (SELECT COUNT(*) FROM tp_description WHERE fixture_plant IS NULL);
SET @sql := IF(
  @nulls = 0,
  'ALTER TABLE tp_description MODIFY fixture_plant VARCHAR(100) NOT NULL;',
  'SELECT ''Skip NOT NULL for fixture_plant (NULL rows exist)'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @nulls := (SELECT COUNT(*) FROM tp_description WHERE qty IS NULL);
SET @sql := IF(
  @nulls = 0,
  'ALTER TABLE tp_description MODIFY qty INT NOT NULL;',
  'SELECT ''Skip NOT NULL for qty (NULL rows exist)'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Ensure part_number is VARCHAR(255) (not TEXT) for unique index
SET @col_type := (
    SELECT DATA_TYPE
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'tp_description'
      AND column_name  = 'part_number'
);
SET @sql := IF(
    @col_type = 'text',
    'ALTER TABLE tp_description MODIFY part_number VARCHAR(255) NOT NULL;',
    'SELECT ''part_number already VARCHAR'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Recreate unique index after dedup: uniq_tp_per_project_part
SET @idx := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'tp_description'
    AND index_name   = 'uniq_tp_per_project_part'
);
SET @sql := IF(
  @idx = 0,
  'CREATE UNIQUE INDEX uniq_tp_per_project_part ON tp_description(adapter_code, fixture_type, fixture_plant, part_number);',
  'SELECT ''uniq_tp_per_project_part exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;


/*------------------------------------------------------------
  1.6 db_logs (add fixture_plant)
------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS db_logs (
    entry_id      INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    project_name  VARCHAR(100) NOT NULL,
    adapter_code  VARCHAR(50)  NOT NULL,
    fixture_type  VARCHAR(30)  NOT NULL,
    db_action     TEXT,
    modified_by   VARCHAR(100) NOT NULL DEFAULT 'ROOT',
    last_update   DATETIME,
    fixture_plant VARCHAR(100) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ensure fixture_plant exists on legacy db_logs
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'db_logs'
    AND column_name  = 'fixture_plant'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE db_logs ADD COLUMN fixture_plant VARCHAR(100) NULL AFTER last_update;',
  'SELECT ''db_logs.fixture_plant exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;


/*------------------------------------------------------------
  1.7 user_otps
------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS user_otps (
    id         INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    email      VARCHAR(255) NOT NULL,
    otp        VARCHAR(6)   NOT NULL,
    expires_at DATETIME     NOT NULL,
    created_at DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ensure 1 active OTP row per email (recommended)
SET @idx := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'user_otps'
    AND index_name   = 'uniq_user_otps_email'
);
SET @sql := IF(
  @idx = 0,
  'CREATE UNIQUE INDEX uniq_user_otps_email ON user_otps(email);',
  'SELECT ''uniq_user_otps_email exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;



/*------------------------------------------------------------
  1.8 email_logs  (with fixture_plant + monitor index)
------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS email_logs (
    id            INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    email_to      VARCHAR(255) NOT NULL,
    subject       VARCHAR(255) NOT NULL,
    adapter_code  VARCHAR(50)  NULL,
    fixture_type  VARCHAR(50)  NULL,
    fixture_plant VARCHAR(100) NULL,      -- ✅ NEW
    project_name  VARCHAR(255) NULL,
    issue_type    VARCHAR(50) NULL,
    sent_to_group ENUM('ADMIN','ENGINEER','OWNER','OTHER') NULL,
    status        ENUM('SENT','FAILED') NOT NULL DEFAULT 'SENT',
    error_message TEXT NULL,
    triggered_by  VARCHAR(255) NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- adapter_code
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'email_logs'
    AND column_name  = 'adapter_code'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE email_logs ADD COLUMN adapter_code VARCHAR(50) NULL AFTER subject;',
  'SELECT ''email_logs.adapter_code exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- fixture_type
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'email_logs'
    AND column_name  = 'fixture_type'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE email_logs ADD COLUMN fixture_type VARCHAR(50) NULL AFTER adapter_code;',
  'SELECT ''email_logs.fixture_type exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- fixture_plant (NEW)
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'email_logs'
    AND column_name  = 'fixture_plant'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE email_logs ADD COLUMN fixture_plant VARCHAR(100) NULL AFTER fixture_type;',
  'SELECT ''email_logs.fixture_plant exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- project_name
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'email_logs'
    AND column_name  = 'project_name'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE email_logs ADD COLUMN project_name VARCHAR(255) NULL AFTER fixture_plant;',
  'SELECT ''email_logs.project_name exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- issue_type
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'email_logs'
    AND column_name  = 'issue_type'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE email_logs ADD COLUMN issue_type VARCHAR(50) NULL AFTER project_name;',
  'SELECT ''email_logs.issue_type exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- sent_to_group
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'email_logs'
    AND column_name  = 'sent_to_group'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE email_logs ADD COLUMN sent_to_group ENUM(''ADMIN'',''ENGINEER'',''OWNER'',''OTHER'') NULL AFTER issue_type;',
  'SELECT ''email_logs.sent_to_group exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- status
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'email_logs'
    AND column_name  = 'status'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE email_logs ADD COLUMN status ENUM(''SENT'',''FAILED'') NOT NULL DEFAULT ''SENT'' AFTER sent_to_group;',
  'SELECT ''email_logs.status exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- error_message
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'email_logs'
    AND column_name  = 'error_message'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE email_logs ADD COLUMN error_message TEXT NULL AFTER status;',
  'SELECT ''email_logs.error_message exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- triggered_by
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'email_logs'
    AND column_name  = 'triggered_by'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE email_logs ADD COLUMN triggered_by VARCHAR(255) NULL AFTER error_message;',
  'SELECT ''email_logs.triggered_by exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- created_at
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'email_logs'
    AND column_name  = 'created_at'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE email_logs ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER triggered_by;',
  'SELECT ''email_logs.created_at exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Drop legacy email_type (replaced by issue_type)
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 'email_logs'
    AND column_name  = 'email_type'
);
SET @sql := IF(
  @col_exists > 0,
  'ALTER TABLE email_logs DROP COLUMN email_type;',
  'SELECT ''email_logs.email_type already dropped'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Recommended index for monitor cooldown lookups (idempotent)
SET @idx := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'email_logs'
    AND index_name   = 'idx_email_logs_monitor'
);
SET @sql := IF(
  @idx = 0,
  'CREATE INDEX idx_email_logs_monitor ON email_logs (adapter_code, fixture_type, fixture_plant, issue_type, created_at);',
  'SELECT ''idx_email_logs_monitor exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- =======================================================
-- 2. PROCEDURES
-- =======================================================

-- 2.1 Plants helpers: addPlant, fetchPlants, getPlantNameById

DROP PROCEDURE IF EXISTS addPlant;
DELIMITER //

CREATE PROCEDURE addPlant(
    IN p_plant_name VARCHAR(100)
)
BEGIN
    DECLARE v_plant_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 500 AS status_code,
               'Unexpected DB error in addPlant' AS message;
    END;

    START TRANSACTION;

    main_block: BEGIN

        -- Check duplicate plant name
        SELECT entry_id
          INTO v_plant_id
          FROM Plants
         WHERE plant_name = p_plant_name
         LIMIT 1;

        IF v_plant_id IS NOT NULL THEN
            ROLLBACK;
            SELECT 409 AS status_code,
                   CONCAT('Plant already exists: ', p_plant_name) AS message;
            LEAVE main_block;
        END IF;

        -- Insert plant
        INSERT INTO Plants (plant_name)
        VALUES (p_plant_name);

        SET v_plant_id = LAST_INSERT_ID();

        -- Create default user groups for this plant
        INSERT IGNORE INTO user_groups (group_name, plant_id)
		    VALUES
			    ('admin',      v_plant_id),
			    ('engineer',   v_plant_id),
			    ('technician', v_plant_id);

        COMMIT;

        SELECT 200 AS status_code,
               CONCAT('Plant added: ', p_plant_name) AS message;

    END main_block;
END;
//
DELIMITER ;


DROP PROCEDURE IF EXISTS fetchPlants;
DELIMITER //
CREATE PROCEDURE fetchPlants()
BEGIN
  SELECT entry_id, plant_name
    FROM Plants
   ORDER BY plant_name;
END;
//
DELIMITER ;

DROP PROCEDURE IF EXISTS getPlantNameById;
DELIMITER //
CREATE PROCEDURE getPlantNameById(IN plant_idParam INT)
BEGIN
  SELECT plant_name
    FROM Plants
   WHERE entry_id = plant_idParam
   LIMIT 1;
END;
//
DELIMITER ;

-- 2.2 Seed user groups for a plant (CSV)
DROP PROCEDURE IF EXISTS seedUserGroupsForPlant;
DELIMITER //
CREATE PROCEDURE seedUserGroupsForPlant(
  IN plant_nameParam VARCHAR(100),
  IN groups_csv TEXT
)
proc_main: BEGIN
  DECLARE v_plant_id INT;
  DECLARE v_str TEXT;
  DECLARE v_pos INT;
  DECLARE v_token VARCHAR(25);
  DECLARE v_inserted INT DEFAULT 0;
  DECLARE v_skipped INT DEFAULT 0;

  IF plant_nameParam IS NULL OR TRIM(plant_nameParam) = '' THEN
    SELECT 400 AS status_code, 'plant_name is required' AS message; LEAVE proc_main;
  END IF;

  SELECT entry_id INTO v_plant_id
    FROM Plants
   WHERE plant_name = plant_nameParam
   LIMIT 1;

  IF v_plant_id IS NULL THEN
    SELECT 404 AS status_code, CONCAT('Plant not found: ', plant_nameParam) AS message;
    LEAVE proc_main;
  END IF;

  IF groups_csv IS NULL OR TRIM(groups_csv) = '' THEN
    SELECT 400 AS status_code, 'groups_csv is empty' AS message; LEAVE proc_main;
  END IF;

  SET v_str = groups_csv;

  split_loop: LOOP
    SET v_pos = LOCATE(',', v_str);
    IF v_pos = 0 THEN
      SET v_token = TRIM(v_str);
      IF v_token IS NOT NULL AND v_token <> '' THEN
        INSERT IGNORE INTO user_groups(plant_id, group_name)
        VALUES (v_plant_id, v_token);
        IF ROW_COUNT() = 1 THEN SET v_inserted = v_inserted + 1; ELSE SET v_skipped = v_skipped + 1; END IF;
      END IF;
      LEAVE split_loop;
    END IF;

    SET v_token = TRIM(SUBSTRING(v_str, 1, v_pos - 1));
    SET v_str   = SUBSTRING(v_str, v_pos + 1);

    IF v_token IS NOT NULL AND v_token <> '' THEN
      INSERT IGNORE INTO user_groups(plant_id, group_name)
      VALUES (v_plant_id, v_token);
      IF ROW_COUNT() = 1 THEN SET v_inserted = v_inserted + 1; ELSE SET v_skipped = v_skipped + 1; END IF;
    END IF;
  END LOOP;

  SELECT 200 AS status_code, 'Seeding completed' AS message,
         v_inserted AS inserted, v_skipped AS skipped;
END;
//
DELIMITER ;

-- 2.3 User management procs
DROP PROCEDURE IF EXISTS requestPasswordResetOtp;
DELIMITER //

CREATE PROCEDURE requestPasswordResetOtp(
    IN p_email VARCHAR(255),
    IN p_otp VARCHAR(6),
    IN p_expires_at DATETIME
)
BEGIN
    DECLARE v_user_id INT;

    -- Check if user exists
    SELECT entry_id INTO v_user_id
    FROM Users
    WHERE email = p_email
    LIMIT 1;

    IF v_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User not found for this email address',
                MYSQL_ERRNO = 2001;
    END IF;

    -- Remove old OTPs
    DELETE FROM user_otps WHERE email = p_email;

    -- Insert new OTP
    INSERT INTO user_otps(email, otp, expires_at)
    VALUES (p_email, p_otp, p_expires_at);

    SELECT 200 AS status_code, 'OTP generated' AS message;
END;
//
DELIMITER ;

DROP PROCEDURE IF EXISTS verifyPasswordResetOtp;
DELIMITER //

CREATE PROCEDURE verifyPasswordResetOtp(
    IN p_email VARCHAR(255),
    IN p_otp   VARCHAR(6)
)
BEGIN
    DECLARE v_expires DATETIME;

    SELECT expires_at INTO v_expires
    FROM user_otps
    WHERE email = p_email AND otp = p_otp
    ORDER BY created_at DESC
    LIMIT 1;

    IF v_expires IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid OTP',
                MYSQL_ERRNO = 2002;
    END IF;

    IF v_expires < NOW() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'OTP has expired',
                MYSQL_ERRNO = 2003;
    END IF;

    SELECT 200 AS status_code, 'OTP verified' AS message;
END;
//
DELIMITER ;

DROP PROCEDURE IF EXISTS resetPasswordWithOtp;
DELIMITER //

CREATE PROCEDURE resetPasswordWithOtp(
    IN p_email VARCHAR(255),
    IN p_hashed_password VARCHAR(255),
    IN p_otp VARCHAR(6)
)
BEGIN
    DECLARE v_expires DATETIME;
    DECLARE v_user_id INT;

    -- Validate user
    SELECT entry_id INTO v_user_id
    FROM Users
    WHERE email = p_email
    LIMIT 1;

    IF v_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User not found',
                MYSQL_ERRNO = 2004;
    END IF;

    -- Validate OTP
    SELECT expires_at INTO v_expires
    FROM user_otps
    WHERE email = p_email AND otp = p_otp
    ORDER BY created_at DESC
    LIMIT 1;

    IF v_expires IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid OTP',
                MYSQL_ERRNO = 2005;
    END IF;

    IF v_expires < NOW() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'OTP expired',
                MYSQL_ERRNO = 2006;
    END IF;

    -- Update password
    UPDATE Users
       SET user_password = p_hashed_password
     WHERE email = p_email;

    -- Invalidate OTP
    DELETE FROM user_otps WHERE email = p_email;

    SELECT 200 AS status_code, 'Password updated' AS message;
END;
//
DELIMITER ;


DROP PROCEDURE IF EXISTS addUser;
DELIMITER //
CREATE PROCEDURE addUser (
    IN p_first_name VARCHAR(100),
    IN p_last_name  VARCHAR(100),
    IN p_user_id    VARCHAR(50),
    IN p_email      VARCHAR(255),
    IN p_user_password VARCHAR(255),
    IN p_plant_name VARCHAR(100),
    IN p_group_name VARCHAR(100)
)
BEGIN
    DECLARE v_plant_id INT;
    DECLARE v_group_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 500 AS status_code, 'Unexpected DB error' AS message;
    END;

    START TRANSACTION;

    main_block: BEGIN

        -- Find plant_id
        SELECT entry_id INTO v_plant_id
        FROM Plants
        WHERE plant_name = p_plant_name
        LIMIT 1;

        IF v_plant_id IS NULL THEN
            ROLLBACK;
            SELECT 404 AS status_code, CONCAT('Plant not found: ', p_plant_name) AS message;
            LEAVE main_block;
        END IF;

        -- Find group_id
        SELECT g.entry_id INTO v_group_id
        FROM user_groups g
        WHERE g.plant_id = v_plant_id
          AND g.group_name = p_group_name
        LIMIT 1;

        IF v_group_id IS NULL THEN
            ROLLBACK;
            SELECT 404 AS status_code, CONCAT('Group not found: ', p_group_name) AS message;
            LEAVE main_block;
        END IF;

        -- Check if user_id or email already exist
        IF EXISTS (SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
            ROLLBACK;
            SELECT 409 AS status_code, 'User ID already exists' AS message;
            LEAVE main_block;
        END IF;

        IF EXISTS (SELECT 1 FROM Users WHERE email = p_email) THEN
            ROLLBACK;
            SELECT 409 AS status_code, 'Email already exists' AS message;
            LEAVE main_block;
        END IF;

        -- Insert user
        INSERT INTO Users (
            first_name, last_name, user_id, email, user_password, user_group, plant_id, group_id, must_change_password
        ) VALUES (
            p_first_name, p_last_name, p_user_id, p_email, p_user_password, p_group_name, v_plant_id, v_group_id, 1
        );

        COMMIT;
        SELECT 200 AS status_code, 'User added successfully' AS message, LAST_INSERT_ID() AS new_user_id;

    END main_block;

END;
//
DELIMITER ;

DROP PROCEDURE IF EXISTS removeUser;
DELIMITER //
CREATE PROCEDURE removeUser(IN p_entry_id INT)
BEGIN
  IF (SELECT EXISTS(SELECT 1 FROM Users WHERE entry_id = p_entry_id)) THEN
    DELETE FROM Users
     WHERE entry_id = p_entry_id;

    SELECT 200 AS status_code, 'User removed successfully' AS message;
  ELSE
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The user does not exist!', MYSQL_ERRNO = 1010;
  END IF;
END;
//
DELIMITER ;

-- fetchGroups used by UI for group dropdown
DROP PROCEDURE IF EXISTS fetchGroups;
DELIMITER //
CREATE PROCEDURE fetchGroups(IN plant_nameParam VARCHAR(25))
BEGIN
  SELECT g.group_name
    FROM user_groups g
    JOIN Plants p ON p.entry_id = g.plant_id
   WHERE p.plant_name = plant_nameParam
   ORDER BY g.group_name;
END;
//
DELIMITER ;

DROP PROCEDURE IF EXISTS changePassword;
DELIMITER //

CREATE PROCEDURE changePassword(
    IN p_email              VARCHAR(255),
    IN p_current_password   VARCHAR(255),
    IN p_new_password       VARCHAR(255),
    IN p_confirm_password   VARCHAR(255)
)
BEGIN
    DECLARE v_entry_id INT;

    -- Error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 500 AS status_code, 'Unexpected DB error in changePassword' AS message;
    END;

    START TRANSACTION;

    main_block: BEGIN

        -- check confirmation
        IF p_new_password <> p_confirm_password THEN
            ROLLBACK;
            SELECT 400 AS status_code, 'New passwords do not match' AS message;
            LEAVE main_block;
        END IF;

        -- identify user
        SELECT entry_id
          INTO v_entry_id
          FROM Users
         WHERE email = p_email
           AND user_password = p_current_password
         LIMIT 1;

        IF v_entry_id IS NULL THEN
            ROLLBACK;
            SELECT 401 AS status_code, 'Invalid email or current password' AS message;
            LEAVE main_block;
        END IF;

        -- update password
        UPDATE Users
           SET user_password = p_new_password,
			   must_change_password = 0
         WHERE entry_id = v_entry_id;

        COMMIT;
        SELECT 200 AS status_code, 'Password changed successfully' AS message;

    END main_block;
END;
//
DELIMITER ;


DROP PROCEDURE IF EXISTS removePlant;
DELIMITER //

CREATE PROCEDURE removePlant(
    IN p_plant_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 500 AS status_code,
               'Unexpected DB error in removePlant' AS message;
    END;

    START TRANSACTION;

    main_block: BEGIN

        -- Optional: check if plant exists
        IF NOT EXISTS (SELECT 1 FROM Plants WHERE entry_id = p_plant_id) THEN
            ROLLBACK;
            SELECT 404 AS status_code,
                   CONCAT('Plant not found for id: ', p_plant_id) AS message;
            LEAVE main_block;
        END IF;

        -- First delete groups for this plant (or rely on ON DELETE CASCADE)
        DELETE FROM user_groups
         WHERE plant_id = p_plant_id;

        -- Then delete the plant
        DELETE FROM Plants
         WHERE entry_id = p_plant_id;

        COMMIT;

        SELECT 200 AS status_code,
               'Plant removed successfully' AS message;

    END main_block;
END;
//
DELIMITER ;

DROP PROCEDURE IF EXISTS getEmailsByPlantAndGroup;
DELIMITER //
CREATE PROCEDURE getEmailsByPlantAndGroup(
  IN p_plant_name VARCHAR(100),
  IN p_group_name VARCHAR(100)
)
BEGIN
  SELECT u.email
  FROM Users u
  JOIN Plants p      ON p.entry_id = u.plant_id
  JOIN user_groups g ON g.entry_id = u.group_id
  WHERE p.plant_name = p_plant_name
    AND g.group_name = p_group_name
    AND u.email IS NOT NULL
    AND TRIM(u.email) <> ''
  ORDER BY u.email;
END;
//
DELIMITER ;


-- fetchUsersByPlant for editUsers UI
DROP PROCEDURE IF EXISTS fetchUsersByPlant;
DELIMITER //
CREATE PROCEDURE fetchUsersByPlant(IN p_plant_name VARCHAR(100))
main_block: BEGIN
  DECLARE v_plant_id INT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT 500 AS status_code, 'Unexpected DB error' AS message;
  END;

  SELECT entry_id INTO v_plant_id
    FROM Plants
   WHERE plant_name = p_plant_name
   LIMIT 1;

  IF v_plant_id IS NULL THEN
    SELECT 404 AS status_code, CONCAT('Plant not found: ', p_plant_name) AS message;
    LEAVE main_block;
  END IF;

  SELECT
    u.entry_id,
    u.first_name,
    u.last_name,
    u.user_id,
    u.email,
    g.group_name AS user_group
  FROM Users u
  JOIN user_groups g ON g.entry_id = u.group_id
  WHERE u.plant_id = v_plant_id
  ORDER BY u.first_name, u.last_name;

END;
//
DELIMITER ;

-- 2.4 Project management

DROP PROCEDURE IF EXISTS insertProject;
DELIMITER //
CREATE PROCEDURE insertProject(
  IN project_nameParam   VARCHAR(100),
  IN adapter_codeParam   VARCHAR(50),
  IN fixture_typeParam   VARCHAR(30),
  IN owner_emailParam    TEXT,
  IN contacts_limitParam INT,
  IN warning_atParam     INT,
  IN modified_byParam    VARCHAR(100),
  IN fixture_plantParam  VARCHAR(100)
)
proc_main: BEGIN
  IF project_nameParam IS NULL OR TRIM(project_nameParam) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='project_name is required', MYSQL_ERRNO=1001;
  END IF;
  IF adapter_codeParam IS NULL OR TRIM(adapter_codeParam) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='adapter_code is required', MYSQL_ERRNO=1001;
  END IF;
  IF fixture_typeParam IS NULL OR TRIM(fixture_typeParam) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='fixture_type is required', MYSQL_ERRNO=1001;
  END IF;
  IF fixture_plantParam IS NULL OR TRIM(fixture_plantParam) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='fixture_plant is required', MYSQL_ERRNO=1001;
  END IF;
  IF contacts_limitParam IS NULL OR warning_atParam IS NULL
     OR contacts_limitParam <= warning_atParam THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='contacts_limit must be greater than warning_at', MYSQL_ERRNO=1003;
  END IF;

  IF EXISTS (
    SELECT 1 FROM Projects
     WHERE fixture_plant = fixture_plantParam
       AND adapter_code  = adapter_codeParam
       AND fixture_type  = fixture_typeParam
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='The adapter code already exists with the specified fixture type in this plant!', MYSQL_ERRNO=1002;
  END IF;

  INSERT INTO Projects(
    project_name, adapter_code, fixture_type, fixture_plant,
    owner_email, contacts, contacts_limit, warning_at, resets, testprobes, modified_by, last_update
  ) VALUES (
    project_nameParam, adapter_codeParam, fixture_typeParam, fixture_plantParam,
    owner_emailParam, 0, contacts_limitParam, warning_atParam, 0, NULL, modified_byParam, NOW()
  );
END;
//
DELIMITER ;

DROP PROCEDURE IF EXISTS updateOwnerEmail;
DELIMITER //
CREATE PROCEDURE updateOwnerEmail(
  IN adapter_codeParam   VARCHAR(50),
  IN fixture_typeParam   VARCHAR(30),
  IN fixture_plantParam  VARCHAR(100),
  IN owner_emailParam    TEXT,
  IN modified_byParam    VARCHAR(100)
)
proc_main: BEGIN
  DECLARE v_old_owner TEXT DEFAULT NULL;

  IF NOT EXISTS (
    SELECT 1 FROM Projects
     WHERE adapter_code = adapter_codeParam
       AND fixture_type = fixture_typeParam
       AND fixture_plant = fixture_plantParam
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Project not found for this plant', MYSQL_ERRNO=1001;
  END IF;

  -- old owner
  SELECT owner_email INTO v_old_owner
    FROM Projects
   WHERE adapter_code = adapter_codeParam
     AND fixture_type = fixture_typeParam
     AND fixture_plant = fixture_plantParam
   LIMIT 1;

  UPDATE Projects
     SET owner_email = owner_emailParam,
         modified_by = modified_byParam,
         last_update = NOW()
   WHERE adapter_code = adapter_codeParam
     AND fixture_type = fixture_typeParam
     AND fixture_plant = fixture_plantParam;

  INSERT INTO db_logs(project_name, adapter_code, fixture_type, db_action, modified_by, last_update, fixture_plant)
  SELECT project_name, adapter_code, fixture_type, 'Owner email updated',
         modified_byParam, NOW(), fixture_plant
    FROM Projects
   WHERE adapter_code = adapter_codeParam
     AND fixture_type = fixture_typeParam
     AND fixture_plant = fixture_plantParam
   LIMIT 1;

  -- analytics event
  CALL addFixtureEvent(
    fixture_plantParam,
    adapter_codeParam,
    fixture_typeParam,
    'OWNER_CHANGED',
    'Owner email updated',
    v_old_owner,
    owner_emailParam,
    modified_byParam
  );
END;
//
DELIMITER ;


DROP PROCEDURE IF EXISTS updateLimitAndWarning;
DELIMITER //
CREATE PROCEDURE updateLimitAndWarning(
  IN adapter_codeParam   VARCHAR(50),
  IN fixture_typeParam   VARCHAR(30),
  IN fixture_plantParam  VARCHAR(100),
  IN contacts_limitParam INT,
  IN warning_atParam     INT,
  IN modified_byParam    VARCHAR(100)
)
proc_main: BEGIN
  DECLARE v_old_limit INT DEFAULT 0;
  DECLARE v_old_warn  INT DEFAULT 0;

  IF contacts_limitParam IS NULL OR warning_atParam IS NULL
     OR contacts_limitParam <= warning_atParam THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='contacts_limit must be greater than warning_at', MYSQL_ERRNO=1003;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM Projects
     WHERE adapter_code  = adapter_codeParam
       AND fixture_type  = fixture_typeParam
       AND fixture_plant = fixture_plantParam
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Project not found for this plant', MYSQL_ERRNO=1001;
  END IF;

  -- old values
  SELECT contacts_limit, warning_at
    INTO v_old_limit, v_old_warn
    FROM Projects
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam
   LIMIT 1;

  UPDATE Projects
     SET contacts_limit = contacts_limitParam,
         warning_at     = warning_atParam,
         modified_by    = modified_byParam,
         last_update    = NOW()
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam;

  INSERT INTO db_logs(project_name, adapter_code, fixture_type, db_action, modified_by, last_update, fixture_plant)
  SELECT project_name, adapter_code, fixture_type, 'Limit & warning updated',
         modified_byParam, NOW(), fixture_plant
    FROM Projects
   WHERE adapter_code = adapter_codeParam
     AND fixture_type = fixture_typeParam
     AND fixture_plant = fixture_plantParam
   LIMIT 1;

  -- analytics event
  CALL addFixtureEvent(
    fixture_plantParam,
    adapter_codeParam,
    fixture_typeParam,
    'LIMIT_WARNING_CHANGED',
    'Limit/warning updated',
    CONCAT('limit=', v_old_limit, ';warning=', v_old_warn),
    CONCAT('limit=', contacts_limitParam, ';warning=', warning_atParam),
    modified_byParam
  );
END;
//
DELIMITER ;


DROP PROCEDURE IF EXISTS resetCounterForProject;
DELIMITER //
CREATE PROCEDURE resetCounterForProject(
  IN adapter_codeParam  VARCHAR(50),
  IN fixture_typeParam  VARCHAR(30),
  IN fixture_plantParam VARCHAR(100),
  IN modified_byParam   VARCHAR(100)
)
proc_main: BEGIN
  DECLARE prev_contacts INT DEFAULT 0;

  IF NOT EXISTS (
    SELECT 1 FROM Projects
     WHERE adapter_code  = adapter_codeParam
       AND fixture_type  = fixture_typeParam
       AND fixture_plant = fixture_plantParam
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Project not found for this plant',
          MYSQL_ERRNO  = 1001;
  END IF;

  SELECT contacts
    INTO prev_contacts
    FROM Projects
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam
   LIMIT 1;

  UPDATE Projects
     SET contacts    = 0,
         resets      = resets + 1,
         modified_by = modified_byParam,
         last_update = NOW()
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam;

  INSERT INTO db_logs (
    project_name, adapter_code, fixture_type,
    db_action, modified_by, last_update, fixture_plant
  )
  SELECT
    project_name,
    adapter_code,
    fixture_type,
    CONCAT('Counter reset (previous contacts: ', prev_contacts, ')') AS db_action,
    modified_byParam,
    NOW(),
    fixture_plant
  FROM Projects
  WHERE adapter_code  = adapter_codeParam
    AND fixture_type  = fixture_typeParam
    AND fixture_plant = fixture_plantParam
  LIMIT 1;

  -- analytics event
  CALL addFixtureEvent(
    fixture_plantParam,
    adapter_codeParam,
    fixture_typeParam,
    'RESET',
    'Counter reset',
    CAST(prev_contacts AS CHAR),
    '0',
    modified_byParam
  );
END;
//
DELIMITER ;


DROP PROCEDURE IF EXISTS deleteProjectForPlant;
DELIMITER //
CREATE PROCEDURE deleteProjectForPlant(
  IN adapter_codeParam  VARCHAR(50),
  IN fixture_typeParam  VARCHAR(30),
  IN fixture_plantParam VARCHAR(100),
  IN modified_byParam   VARCHAR(100)
)
proc_main: BEGIN
  DECLARE v_project_name VARCHAR(100);

  IF NOT EXISTS (
    SELECT 1 FROM Projects
     WHERE adapter_code  = adapter_codeParam
       AND fixture_type  = fixture_typeParam
       AND fixture_plant = fixture_plantParam
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Project not found for this plant', MYSQL_ERRNO=1001;
  END IF;

  SELECT project_name INTO v_project_name
    FROM Projects
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam
   LIMIT 1;

  INSERT INTO db_logs(project_name, adapter_code, fixture_type, db_action, modified_by, last_update, fixture_plant)
  VALUES (v_project_name, adapter_codeParam, fixture_typeParam, 'Equipment deleted', modified_byParam, NOW(), fixture_plantParam);

  -- analytics event (do BEFORE delete so project_name is available)
  CALL addFixtureEvent(
    fixture_plantParam,
    adapter_codeParam,
    fixture_typeParam,
    'DELETED',
    'Project deleted',
    v_project_name,
    NULL,
    modified_byParam
  );

  DELETE FROM Projects
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam;
END;
//
DELIMITER ;


DROP PROCEDURE IF EXISTS getProjectsByPlant;
DELIMITER //
CREATE PROCEDURE getProjectsByPlant(IN fixture_plantParam VARCHAR(100))
BEGIN
  IF fixture_plantParam IS NULL OR TRIM(fixture_plantParam) = '' THEN
    SELECT entry_id, project_name, adapter_code, fixture_type, fixture_plant,
           owner_email, contacts, contacts_limit, warning_at, resets, testprobes,
           modified_by, last_update
      FROM Projects
     ORDER BY project_name;
  ELSE
    SELECT entry_id, project_name, adapter_code, fixture_type, fixture_plant,
           owner_email, contacts, contacts_limit, warning_at, resets, testprobes,
           modified_by, last_update
      FROM Projects
     WHERE fixture_plant = fixture_plantParam
     ORDER BY project_name;
  END IF;
END;
//
DELIMITER ;

-- Counter value (used by getCounterInfo)
DROP PROCEDURE IF EXISTS getCounterValue;
DELIMITER //
CREATE PROCEDURE getCounterValue(
  IN adapter_codeParam VARCHAR(50),
  IN fixture_typeParam VARCHAR(30),
  IN fixture_plantParam VARCHAR(100)
)
BEGIN
  IF (SELECT EXISTS(SELECT 1 FROM Projects WHERE adapter_code=adapter_codeParam AND fixture_type=fixture_typeParam AND fixture_plant=fixture_plantParam)) THEN
    SELECT contacts
      FROM Projects
     WHERE adapter_code = adapter_codeParam
       AND fixture_type = fixture_typeParam
       AND fixture_plant = fixture_plantParam;
  ELSE
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The adapter code does not exist with the specified fixture type!', MYSQL_ERRNO = 1001;
  END IF;
END;
//
DELIMITER ;

-- 2.5 Test probe procedures (multi-plant)

DROP PROCEDURE IF EXISTS regenerateProjectTestProbes;
DELIMITER //
CREATE PROCEDURE regenerateProjectTestProbes(
  IN adapter_codeParam  VARCHAR(50),
  IN fixture_typeParam  VARCHAR(30),
  IN fixture_plantParam VARCHAR(100)
)
BEGIN
  -- Optional safety for long probe lists
  SET SESSION group_concat_max_len = 100000;

  UPDATE Projects p
     SET p.testprobes = (
       SELECT GROUP_CONCAT(
                CONCAT(tp.part_number, ' x', tp.qty)
                ORDER BY tp.qty DESC, tp.part_number ASC
                SEPARATOR '; '
              )
         FROM tp_description tp
        WHERE tp.adapter_code  = adapter_codeParam
          AND tp.fixture_type  = fixture_typeParam
          AND tp.fixture_plant = fixture_plantParam
     ),
         p.last_update = NOW()
   WHERE p.adapter_code  = adapter_codeParam
     AND p.fixture_type  = fixture_typeParam
     AND p.fixture_plant = fixture_plantParam;
END;
//
DELIMITER ;


DROP PROCEDURE IF EXISTS addOrUpdateTestProbe;
DELIMITER //
CREATE PROCEDURE addOrUpdateTestProbe(
  IN adapter_codeParam  VARCHAR(50),
  IN fixture_typeParam  VARCHAR(30),
  IN fixture_plantParam VARCHAR(100),
  IN part_numberParam   VARCHAR(100),
  IN qtyParam           INT,
  IN modified_byParam   VARCHAR(100)
)
proc_main: BEGIN
  DECLARE v_exists INT DEFAULT 0;
  DECLARE v_old_qty INT DEFAULT NULL;

  IF qtyParam IS NULL OR qtyParam <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'qty must be > 0', MYSQL_ERRNO = 1201;
  END IF;

  SELECT COUNT(*) INTO v_exists
    FROM tp_description
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam
     AND part_number   = part_numberParam;

  IF v_exists = 0 THEN
    INSERT INTO tp_description(adapter_code, fixture_type, fixture_plant, part_number, qty)
    VALUES(adapter_codeParam, fixture_typeParam, fixture_plantParam, part_numberParam, qtyParam);
  ELSE
    SELECT qty INTO v_old_qty
      FROM tp_description
     WHERE adapter_code  = adapter_codeParam
       AND fixture_type  = fixture_typeParam
       AND fixture_plant = fixture_plantParam
       AND part_number   = part_numberParam
     LIMIT 1;

    UPDATE tp_description
       SET qty = qtyParam
     WHERE adapter_code  = adapter_codeParam
       AND fixture_type  = fixture_typeParam
       AND fixture_plant = fixture_plantParam
       AND part_number   = part_numberParam;
  END IF;

  CALL regenerateProjectTestProbes(adapter_codeParam, fixture_typeParam, fixture_plantParam);

  INSERT INTO db_logs(project_name, adapter_code, fixture_type, db_action, modified_by, last_update, fixture_plant)
  SELECT p.project_name, p.adapter_code, p.fixture_type,
         CONCAT('Test probe ', part_numberParam, ' → qty ', qtyParam),
         modified_byParam, NOW(), p.fixture_plant
    FROM Projects p
   WHERE p.adapter_code  = adapter_codeParam
     AND p.fixture_type  = fixture_typeParam
     AND p.fixture_plant = fixture_plantParam
   LIMIT 1;

  -- ✅ analytics event
  CALL addFixtureEvent(
    fixture_plantParam,
    adapter_codeParam,
    fixture_typeParam,
    'TP_CHANGED',
    CONCAT('Probe ', part_numberParam, ' set qty=', qtyParam),
    IFNULL(CAST(v_old_qty AS CHAR), NULL),
    CONCAT(part_numberParam, ' x', qtyParam),
    modified_byParam
  );
END;
//
DELIMITER ;


DROP PROCEDURE IF EXISTS getTestProbesForProject;
DELIMITER //
CREATE PROCEDURE getTestProbesForProject(
  IN adapter_codeParam  VARCHAR(50),
  IN fixture_typeParam  VARCHAR(30),
  IN fixture_plantParam VARCHAR(100)
)
BEGIN
  SELECT part_number, qty AS quantity
    FROM tp_description
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam
   ORDER BY qty DESC, part_number ASC;
END;
//
DELIMITER ;

DROP PROCEDURE IF EXISTS deleteTestProbe;
DELIMITER //
CREATE PROCEDURE deleteTestProbe(
  IN adapter_codeParam  VARCHAR(50),
  IN fixture_typeParam  VARCHAR(30),
  IN fixture_plantParam VARCHAR(100),
  IN part_numberParam   VARCHAR(100),
  IN modified_byParam   VARCHAR(100)
)
BEGIN
  DECLARE v_old_qty INT DEFAULT NULL;

  SELECT qty INTO v_old_qty
    FROM tp_description
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam
     AND part_number   = part_numberParam
   LIMIT 1;

  DELETE FROM tp_description
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam
     AND part_number   = part_numberParam;

  CALL regenerateProjectTestProbes(adapter_codeParam, fixture_typeParam, fixture_plantParam);

  INSERT INTO db_logs(project_name, adapter_code, fixture_type, db_action, modified_by, last_update, fixture_plant)
  SELECT p.project_name, p.adapter_code, p.fixture_type,
         CONCAT('Test probe deleted: ', part_numberParam),
         modified_byParam, NOW(), p.fixture_plant
    FROM Projects p
   WHERE p.adapter_code  = adapter_codeParam
     AND p.fixture_type  = fixture_typeParam
     AND p.fixture_plant = fixture_plantParam
   LIMIT 1;

  -- analytics event
  CALL addFixtureEvent(
    fixture_plantParam,
    adapter_codeParam,
    fixture_typeParam,
    'TP_DELETED',
    CONCAT('Probe deleted: ', part_numberParam),
    IFNULL(CONCAT(part_numberParam, ' x', v_old_qty), part_numberParam),
    NULL,
    modified_byParam
  );
END;
//
DELIMITER ;


DROP PROCEDURE IF EXISTS removeAllTestProbes;
DELIMITER //
CREATE PROCEDURE removeAllTestProbes(
  IN adapter_codeParam  VARCHAR(50),
  IN fixture_typeParam  VARCHAR(30),
  IN fixture_plantParam VARCHAR(100),
  IN modified_byParam   VARCHAR(100)
)
BEGIN
  DECLARE v_prev_count INT DEFAULT 0;

  SELECT COUNT(*) INTO v_prev_count
    FROM tp_description
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam;

  DELETE FROM tp_description
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam;

  CALL regenerateProjectTestProbes(adapter_codeParam, fixture_typeParam, fixture_plantParam);

  INSERT INTO db_logs(project_name, adapter_code, fixture_type, db_action, modified_by, last_update, fixture_plant)
  SELECT p.project_name, p.adapter_code, p.fixture_type,
         'All test probes removed',
         modified_byParam, NOW(), p.fixture_plant
    FROM Projects p
   WHERE p.adapter_code  = adapter_codeParam
     AND p.fixture_type  = fixture_typeParam
     AND p.fixture_plant = fixture_plantParam
   LIMIT 1;

  -- analytics event
  CALL addFixtureEvent(
    fixture_plantParam,
    adapter_codeParam,
    fixture_typeParam,
    'TP_REMOVE_ALL',
    CONCAT('All test probes removed (count=', v_prev_count, ')'),
    CAST(v_prev_count AS CHAR),
    '0',
    modified_byParam
  );
END;
//
DELIMITER ;



DROP PROCEDURE IF EXISTS incrementCounter;
DELIMITER //

CREATE PROCEDURE incrementCounter(
  IN adapter_codeParam  VARCHAR(50),
  IN fixture_typeParam  VARCHAR(30),
  IN fixture_plantParam VARCHAR(100)
)
BEGIN
  -- Check if the project exists for this plant
  IF NOT EXISTS (
    SELECT 1
      FROM Projects
     WHERE adapter_code  = adapter_codeParam
       AND fixture_type  = fixture_typeParam
       AND fixture_plant = fixture_plantParam
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The adapter code does not exist with the specified fixture type for this plant!',
          MYSQL_ERRNO  = 1001;
  END IF;

  -- Increment contacts
  UPDATE Projects
     SET contacts = contacts + 1
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam;
END;
//
DELIMITER ;

-- Example call:
-- CALL incrementCounter('113', 'FCT', 'YourPlantName');

DROP PROCEDURE IF EXISTS updateContacts;
DELIMITER //

CREATE PROCEDURE updateContacts(
  IN adapter_codeParam  VARCHAR(50),
  IN fixture_typeParam  VARCHAR(30),
  IN fixture_plantParam VARCHAR(100),
  IN contactsParam      INT,
  IN modified_byParam   VARCHAR(100)
)
BEGIN
  -- Check if the project exists for this plant
  IF NOT EXISTS (
    SELECT 1
      FROM Projects
     WHERE adapter_code  = adapter_codeParam
       AND fixture_type  = fixture_typeParam
       AND fixture_plant = fixture_plantParam
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The adapter code does not exist with the specified fixture type for this plant!',
          MYSQL_ERRNO  = 1001;
  END IF;

  -- Update contacts and meta info
  UPDATE Projects
     SET contacts    = contactsParam,
         modified_by = modified_byParam,
         last_update = NOW()
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam;

  -- Log the update, including the new contacts value
  INSERT INTO db_logs (
    project_name,
    adapter_code,
    fixture_type,
    db_action,
    modified_by,
    last_update,
    fixture_plant
  )
  SELECT
    project_name,
    adapter_code,
    fixture_type,
    CONCAT('Contacts updated to ', contactsParam) AS db_action,
    modified_byParam,
    NOW(),
    fixture_plant
  FROM Projects
  WHERE adapter_code  = adapter_codeParam
    AND fixture_type  = fixture_typeParam
    AND fixture_plant = fixture_plantParam
  LIMIT 1;
END;
//
DELIMITER ;

-- Example call:
-- CALL updateContacts('101', 'FCT', 'YourPlantName', 524, 'admin@plant.com');


-- 2.7 Email logging

DROP PROCEDURE IF EXISTS log_email_event;
DELIMITER //

CREATE PROCEDURE log_email_event(
  IN p_email_to        VARCHAR(255),
  IN p_subject         VARCHAR(255),
  IN p_adapter_code    VARCHAR(50),
  IN p_fixture_type    VARCHAR(50),
  IN p_fixture_plant   VARCHAR(100),
  IN p_project_name    VARCHAR(255),
  IN p_issue_type      VARCHAR(50),
  IN p_sent_to_group   VARCHAR(20),
  IN p_status          VARCHAR(20),
  IN p_error_message   TEXT,
  IN p_triggered_by    VARCHAR(255)
)
BEGIN
  INSERT INTO email_logs (
    email_to,
    subject,
    issue_type,
    adapter_code,
    fixture_type,
    fixture_plant,
    project_name,
    sent_to_group,
    status,
    error_message,
    triggered_by,
    created_at
  )
  VALUES (
    p_email_to,
    p_subject,
    p_issue_type,
    p_adapter_code,
    p_fixture_type,
    p_fixture_plant,
    p_project_name,
    p_sent_to_group,
    p_status,
    p_error_message,
    p_triggered_by,
    NOW()
  );
END;
//
DELIMITER ;


/*------------------------------------------------------------
  1.x Ensure standard Plants and enforce ONLY 3 groups per plant
  - Add missing plants from the standard list
  - Delete all non-standard groups
  - For every plant, ensure groups: admin, engineer, technician
------------------------------------------------------------*/

-- 1) Ensure the standard plants exist (insert only missing ones)
INSERT INTO Plants (plant_name)
SELECT v.plant_name
FROM (
    SELECT 'Babenhausen' AS plant_name
    UNION ALL SELECT 'Bangalore'
    UNION ALL SELECT 'Brandys'
    UNION ALL SELECT 'Changsha'
    UNION ALL SELECT 'Guadalajara'
    UNION ALL SELECT 'Guarulhos'
    UNION ALL SELECT 'Karben'
    UNION ALL SELECT 'Novi Sad'
    UNION ALL SELECT 'Penang'
    UNION ALL SELECT 'Sejong'
    UNION ALL SELECT 'Timisoara'
    UNION ALL SELECT 'Wuhu'
) AS v
LEFT JOIN Plants p
  ON p.plant_name = v.plant_name
WHERE p.entry_id IS NULL;

-- 2) SAFE standardization: move users from non-standard groups to engineer,
--    then delete only unused non-standard groups.

-- Ensure target group exists per plant
INSERT IGNORE INTO user_groups (plant_id, group_name)
SELECT p.entry_id, 'engineer'
FROM Plants p;

-- Repoint users from non-standard groups to 'engineer' (within same plant)
UPDATE Users u
JOIN user_groups g_old ON g_old.entry_id = u.group_id
JOIN user_groups g_new ON g_new.plant_id = g_old.plant_id AND g_new.group_name = 'engineer'
SET u.group_id = g_new.entry_id,
    u.user_group = 'engineer'
WHERE g_old.group_name NOT IN ('admin','engineer','technician');

-- Now delete only unused non-standard groups (no users attached)
DELETE g
FROM user_groups g
LEFT JOIN Users u ON u.group_id = g.entry_id
WHERE g.group_name NOT IN ('admin','engineer','technician')
  AND u.entry_id IS NULL;

-- 3) Ensure default groups (admin, engineer, technician) exist for each plant
INSERT INTO user_groups (plant_id, group_name)
SELECT p.entry_id, g.group_name
FROM Plants p
CROSS JOIN (
    SELECT 'admin' AS group_name
    UNION ALL SELECT 'engineer'
    UNION ALL SELECT 'technician'
) AS g
LEFT JOIN user_groups ug
  ON ug.plant_id = p.entry_id
 AND ug.group_name = g.group_name
WHERE ug.entry_id IS NULL;

-- =============================
-- 3. ANALYTICS TABLES + PROCS
-- (separate storage; does not change existing behavior)
-- =============================

/*===========================================================
  3.1 HOURLY SAMPLES (new, separate table)
===========================================================*/

CREATE TABLE IF NOT EXISTS fixture_samples_hourly (
    entry_id       BIGINT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    fixture_plant  VARCHAR(100) NOT NULL,
    adapter_code   VARCHAR(50)  NOT NULL,
    fixture_type   VARCHAR(30)  NOT NULL,
    sample_ts      DATETIME     NOT NULL,  -- truncated to hour, e.g. 2025-12-18 12:00:00

    project_name   VARCHAR(100) NULL,
    owner_email    TEXT         NULL,
    contacts       INT          NOT NULL,
    warning_at     INT          NOT NULL,
    contacts_limit INT          NOT NULL,
    resets         INT          NOT NULL,

    modified_by    VARCHAR(100) NULL,
    captured_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Unique: one record per fixture per hour
SET @idx := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'fixture_samples_hourly'
    AND index_name   = 'uniq_fixture_hour'
);
SET @sql := IF(
  @idx = 0,
  'CREATE UNIQUE INDEX uniq_fixture_hour
     ON fixture_samples_hourly (fixture_plant, adapter_code, fixture_type, sample_ts);',
  'SELECT ''uniq_fixture_hour exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Lookup/range index
SET @idx := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'fixture_samples_hourly'
    AND index_name   = 'idx_fixture_samples_lookup'
);
SET @sql := IF(
  @idx = 0,
  'CREATE INDEX idx_fixture_samples_lookup
     ON fixture_samples_hourly (fixture_plant, adapter_code, fixture_type, sample_ts);',
  'SELECT ''idx_fixture_samples_lookup exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;


/*===========================================================
  3.2 FIXTURE EVENTS (new, separate table)
===========================================================*/

CREATE TABLE IF NOT EXISTS fixture_events (
    entry_id       BIGINT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    fixture_plant  VARCHAR(100) NOT NULL,
    adapter_code   VARCHAR(50)  NOT NULL,
    fixture_type   VARCHAR(30)  NOT NULL,
    project_name   VARCHAR(100) NULL,

    event_type     VARCHAR(50)  NOT NULL,
    event_details  TEXT         NULL,       -- free text or JSON string
    old_value      TEXT         NULL,
    new_value      TEXT         NULL,

    actor          VARCHAR(255) NULL,       -- email/user_id
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET @idx := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'fixture_events'
    AND index_name   = 'idx_fixture_events_lookup'
);
SET @sql := IF(
  @idx = 0,
  'CREATE INDEX idx_fixture_events_lookup
     ON fixture_events (fixture_plant, adapter_code, fixture_type, created_at);',
  'SELECT ''idx_fixture_events_lookup exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'fixture_events'
    AND index_name   = 'idx_fixture_events_type'
);
SET @sql := IF(
  @idx = 0,
  'CREATE INDEX idx_fixture_events_type
     ON fixture_events (event_type, created_at);',
  'SELECT ''idx_fixture_events_type exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'fixture_events'
    AND index_name   = 'idx_fixture_events_recent'
);
SET @sql := IF(
  @idx = 0,
  'CREATE INDEX idx_fixture_events_recent
     ON fixture_events (fixture_plant, adapter_code, fixture_type, created_at DESC);',
  'SELECT ''idx_fixture_events_recent exists'' AS info;'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

DROP PROCEDURE IF EXISTS addFixtureEvent;
DELIMITER //

CREATE PROCEDURE addFixtureEvent(
  IN p_fixture_plant VARCHAR(100),
  IN p_adapter_code  VARCHAR(50),
  IN p_fixture_type  VARCHAR(30),
  IN p_event_type    VARCHAR(50),
  IN p_event_details TEXT,
  IN p_old_value     TEXT,
  IN p_new_value     TEXT,
  IN p_actor         VARCHAR(255)
)
proc_main: BEGIN
  DECLARE v_project_name VARCHAR(100) DEFAULT NULL;

  /* ---- DEDUP GUARD (prevents accidental double inserts) ----
     If the same event is already logged in the last 2 seconds,
     skip inserting again.
  */
  IF EXISTS (
    SELECT 1
      FROM fixture_events fe
     WHERE fe.fixture_plant = p_fixture_plant
       AND fe.adapter_code  = p_adapter_code
       AND fe.fixture_type  = p_fixture_type
       AND fe.event_type    = p_event_type
       AND IFNULL(fe.event_details,'') = IFNULL(p_event_details,'')
       AND IFNULL(fe.old_value,'')     = IFNULL(p_old_value,'')
       AND IFNULL(fe.new_value,'')     = IFNULL(p_new_value,'')
       AND IFNULL(fe.actor,'')         = IFNULL(p_actor,'')
       AND fe.created_at >= (NOW() - INTERVAL 2 SECOND)
     LIMIT 1
  ) THEN
    LEAVE proc_main;
  END IF;

  -- If project exists, capture name; otherwise keep NULL and still log event
  SELECT project_name INTO v_project_name
    FROM Projects
   WHERE fixture_plant = p_fixture_plant
     AND adapter_code  = p_adapter_code
     AND fixture_type  = p_fixture_type
   LIMIT 1;

  INSERT INTO fixture_events(
    fixture_plant, adapter_code, fixture_type, project_name,
    event_type, event_details, old_value, new_value, actor, created_at
  ) VALUES (
    p_fixture_plant, p_adapter_code, p_fixture_type, v_project_name,
    p_event_type, p_event_details, p_old_value, p_new_value, p_actor, NOW()
  );
END;
//
DELIMITER ;



/*===========================================================
  3.3 PROCEDURE: captureHourlySamples
  - Safe to call many times per hour (UPSERT)
  - plant filter:
      CALL captureHourlySamples('');         -- all plants
      CALL captureHourlySamples('Timisoara') -- one plant
===========================================================*/

DROP PROCEDURE IF EXISTS captureHourlySamples;
DELIMITER //

CREATE PROCEDURE captureHourlySamples(IN fixture_plantParam VARCHAR(100))
BEGIN
  DECLARE v_hour_ts DATETIME;

  -- truncate to hour
  SET v_hour_ts = STR_TO_DATE(DATE_FORMAT(NOW(), '%Y-%m-%d %H:00:00'), '%Y-%m-%d %H:%i:%s');

  INSERT INTO fixture_samples_hourly (
    fixture_plant, adapter_code, fixture_type, sample_ts,
    project_name, owner_email,
    contacts, warning_at, contacts_limit, resets,
    modified_by
  )
  SELECT
    p.fixture_plant, p.adapter_code, p.fixture_type, v_hour_ts,
    p.project_name, p.owner_email,
    p.contacts, p.warning_at, p.contacts_limit, p.resets,
    p.modified_by
  FROM Projects p
  WHERE (fixture_plantParam IS NULL OR TRIM(fixture_plantParam) = '' OR p.fixture_plant = fixture_plantParam)
  ON DUPLICATE KEY UPDATE
    project_name   = VALUES(project_name),
    owner_email    = VALUES(owner_email),
    contacts       = VALUES(contacts),
    warning_at     = VALUES(warning_at),
    contacts_limit = VALUES(contacts_limit),
    resets         = VALUES(resets),
    modified_by    = VALUES(modified_by),
    captured_at    = CURRENT_TIMESTAMP;
END;
//
DELIMITER ;

DROP PROCEDURE IF EXISTS getFixtureForecast;
DELIMITER //

CREATE PROCEDURE getFixtureForecast(
  IN p_fixture_plant  VARCHAR(100),
  IN p_adapter_code   VARCHAR(50),
  IN p_fixture_type   VARCHAR(30),
  IN p_lookback_hours INT
)
proc_main: BEGIN
  DECLARE v_since DATETIME;
  DECLARE v_reset_ts DATETIME;
  DECLARE v_now DATETIME;
  DECLARE v_contacts INT;
  DECLARE v_warning INT;
  DECLARE v_limit INT;

  SET v_now = NOW();

  -- last reset time (if any)
  SELECT MAX(created_at) INTO v_reset_ts
    FROM fixture_events
   WHERE fixture_plant = p_fixture_plant
     AND adapter_code  = p_adapter_code
     AND fixture_type  = p_fixture_type
     AND event_type    = 'RESET';

  -- analysis window start = max(last reset, now-lookback)
  SET v_since = DATE_SUB(v_now, INTERVAL IFNULL(NULLIF(p_lookback_hours,0), 24) HOUR);
  IF v_reset_ts IS NOT NULL AND v_reset_ts > v_since THEN
    SET v_since = v_reset_ts;
  END IF;

  -- current project info
  SELECT contacts, warning_at, contacts_limit
    INTO v_contacts, v_warning, v_limit
    FROM Projects
   WHERE fixture_plant = p_fixture_plant
     AND adapter_code  = p_adapter_code
     AND fixture_type  = p_fixture_type
   LIMIT 1;

  -- Compute burn rate as avg positive delta per hour
  -- MySQL 8+ window function
  SELECT
    v_since AS window_start,
    v_now   AS window_end,
    v_contacts AS current_contacts,
    v_warning  AS warning_at,
    v_limit    AS contacts_limit,
    COALESCE(AVG(delta_pos), 0) AS avg_contacts_per_hour,
    CASE
      WHEN COALESCE(AVG(delta_pos), 0) <= 0 THEN NULL
      WHEN v_warning IS NULL OR v_warning <= 0 THEN NULL
      WHEN v_contacts >= v_warning THEN 0
      ELSE ROUND((v_warning - v_contacts) / AVG(delta_pos), 2)
    END AS eta_warning_hours,
    CASE
      WHEN COALESCE(AVG(delta_pos), 0) <= 0 THEN NULL
      WHEN v_limit IS NULL OR v_limit <= 0 THEN NULL
      WHEN v_contacts >= v_limit THEN 0
      ELSE ROUND((v_limit - v_contacts) / AVG(delta_pos), 2)
    END AS eta_limit_hours
  FROM (
    SELECT
      sample_ts,
      GREATEST(contacts - LAG(contacts) OVER (ORDER BY sample_ts), 0) AS delta_pos
    FROM fixture_samples_hourly
    WHERE fixture_plant = p_fixture_plant
      AND adapter_code  = p_adapter_code
      AND fixture_type  = p_fixture_type
      AND sample_ts >= v_since
      AND sample_ts <= v_now
  ) x;

END;
//
DELIMITER ;

DROP PROCEDURE IF EXISTS getFixtureHourlySeries;
DELIMITER //

CREATE PROCEDURE getFixtureHourlySeries(
  IN p_fixture_plant VARCHAR(100),
  IN p_adapter_code  VARCHAR(50),
  IN p_fixture_type  VARCHAR(30),
  IN p_hours_back    INT
)
BEGIN
  SELECT
    sample_ts,
    contacts,
    warning_at,
    contacts_limit,
    resets
  FROM fixture_samples_hourly
  WHERE fixture_plant = p_fixture_plant
    AND adapter_code  = p_adapter_code
    AND fixture_type  = p_fixture_type
    AND sample_ts >= DATE_SUB(NOW(), INTERVAL IFNULL(NULLIF(p_hours_back,0), 168) HOUR)
  ORDER BY sample_ts ASC;
END;
//
DELIMITER ;


-- =============================
-- Restore settings
-- =============================
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET sql_notes=@OLD_SQL_NOTES;



