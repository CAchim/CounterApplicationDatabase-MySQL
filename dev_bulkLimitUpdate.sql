USE counterdb;

DROP PROCEDURE IF EXISTS bulkUpdateLimits;

DELIMITER //

CREATE PROCEDURE bulkUpdateLimits(
  IN fixture_plantParam  VARCHAR(100),
  IN contacts_limitParam INT,
  IN warning_atParam     INT)
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE v_adapter_code   VARCHAR(50);
  DECLARE v_fixture_type   VARCHAR(30);
  DECLARE v_adminUser      VARCHAR(100) DEFAULT 'catalin-gheorghe.achim@aumovio.com';

  -- Cursor over all Timisoara fixtures
  DECLARE cur CURSOR FOR
    SELECT DISTINCT adapter_code, fixture_type
      FROM Projects
     WHERE fixture_plant = fixture_plantParam;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO v_adapter_code, v_fixture_type;
    IF done = 1 THEN
      LEAVE read_loop;
    END IF;

    -- Call your existing procedure for each fixture
    CALL updateLimitAndWarning(
      v_adapter_code,        -- adapter_codeParam
      v_fixture_type,        -- fixture_typeParam
      fixture_plantParam,    -- fixture_plantParam
      contacts_limitParam,   -- contacts_limitParam
      warning_atParam,       -- warning_atParam
      v_adminUser            -- modified_byParam
    );
  END LOOP;

  CLOSE cur;
END;
//

DELIMITER ;

