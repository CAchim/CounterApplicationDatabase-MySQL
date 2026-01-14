DROP PROCEDURE IF EXISTS regenerateProjectTestProbes;
DELIMITER //
CREATE PROCEDURE regenerateProjectTestProbes(
  IN adapter_codeParam  VARCHAR(50),
  IN fixture_typeParam  VARCHAR(30),
  IN fixture_plantParam VARCHAR(100)
)
BEGIN
  UPDATE Projects p
     SET p.testprobes = (
       SELECT GROUP_CONCAT(CONCAT(tp.part_number, ' x', tp.qty) SEPARATOR '; ')
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