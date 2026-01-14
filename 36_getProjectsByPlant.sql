DROP PROCEDURE IF EXISTS getProjectsByPlant;
DELIMITER //

CREATE PROCEDURE getProjectsByPlant(IN fixture_plantParam VARCHAR(100))
BEGIN
  IF fixture_plantParam IS NULL OR TRIM(fixture_plantParam) = '' THEN
    SELECT entry_id, project_name, adapter_code, fixture_type, owner_email,
           contacts, contacts_limit, warning_at, resets, testprobes,
           modified_by, last_update, fixture_plant
      FROM Projects
     ORDER BY project_name;
  ELSE
    SELECT entry_id, project_name, adapter_code, fixture_type, owner_email,
           contacts, contacts_limit, warning_at, resets, testprobes,
           modified_by, last_update, fixture_plant
      FROM Projects
     WHERE fixture_plant = fixture_plantParam
     ORDER BY project_name;
  END IF;
END;
//
DELIMITER ;
