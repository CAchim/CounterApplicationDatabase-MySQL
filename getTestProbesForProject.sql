DROP PROCEDURE IF EXISTS getTestProbesForProject;
DELIMITER //
CREATE PROCEDURE getTestProbesForProject(
  IN adapter_codeParam  VARCHAR(50),
  IN fixture_typeParam  VARCHAR(30),
  IN fixture_plantParam VARCHAR(100)
)
BEGIN
  SELECT part_number, qty
    FROM tp_description
   WHERE adapter_code  = adapter_codeParam
     AND fixture_type  = fixture_typeParam
     AND fixture_plant = fixture_plantParam
   ORDER BY part_number;
END;
//
DELIMITER ;