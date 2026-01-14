DROP PROCEDURE IF EXISTS addUser;
DELIMITER //

CREATE PROCEDURE addUser (
    IN p_first_name      VARCHAR(100),
    IN p_last_name       VARCHAR(100),
    IN p_user_id         VARCHAR(50),
    IN p_email           VARCHAR(255),
    IN p_user_password   VARCHAR(255),
    IN p_plant_name      VARCHAR(100),
    IN p_group_name      VARCHAR(100)
)
BEGIN
    DECLARE v_plant_id INT DEFAULT NULL;
    DECLARE v_group_id INT DEFAULT NULL;

    -- ============= Error handlers =============

    -- Handle duplicate key (user_id/email unique)
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        ROLLBACK;
        SELECT 409 AS status_code,
               'User with same ID or email already exists' AS message;
    END;

    -- Generic SQL error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 500 AS status_code, 'Unexpected DB error' AS message;
    END;

    START TRANSACTION;

    main_block: BEGIN

        -- Optional: normalize email (lowercase + trim) – uncomment if you want this behavior
        -- SET p_email = LOWER(TRIM(p_email));

        -- Find plant_id
        SELECT entry_id
          INTO v_plant_id
          FROM Plants
         WHERE plant_name = p_plant_name
         LIMIT 1;

        IF v_plant_id IS NULL THEN
            ROLLBACK;
            SELECT 404 AS status_code,
                   CONCAT('Plant not found: ', p_plant_name) AS message;
            LEAVE main_block;
        END IF;

        -- Find group_id for that plant
        SELECT g.entry_id
          INTO v_group_id
          FROM user_groups g
         WHERE g.group_name = p_group_name
           AND g.plant_id   = v_plant_id
         LIMIT 1;

        IF v_group_id IS NULL THEN
            ROLLBACK;
            SELECT 404 AS status_code,
                   CONCAT('Group not found: ', p_group_name,
                          ' for plant ', p_plant_name) AS message;
            LEAVE main_block;
        END IF;

        -- (Optional) pre-check duplicates to give nicer messages
        -- Check duplicate user_id
        IF EXISTS (SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
            ROLLBACK;
            SELECT 409 AS status_code,
                   CONCAT('User ID already exists: ', p_user_id) AS message;
            LEAVE main_block;
        END IF;

        -- Check duplicate email
        IF EXISTS (SELECT 1 FROM Users WHERE email = p_email) THEN
            ROLLBACK;
            SELECT 409 AS status_code,
                   CONCAT('Email already exists: ', p_email) AS message;
            LEAVE main_block;
        END IF;

        -- Insert user
        INSERT INTO Users (
            first_name,
            last_name,
            user_id,
            email,
            user_password,
            user_group,
            plant_id,
            group_id
        ) VALUES (
            p_first_name,
            p_last_name,
            p_user_id,
            p_email,
            p_user_password,   -- ideally already hashed before calling proc
            p_group_name,
            v_plant_id,
            v_group_id
        );

        COMMIT;

        SELECT 200 AS status_code,
               'User added successfully' AS message,
               LAST_INSERT_ID() AS new_user_id;

    END main_block;

END;
//
DELIMITER ;
