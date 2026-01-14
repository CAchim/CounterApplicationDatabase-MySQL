DROP PROCEDURE IF EXISTS fetchGroups;

DELIMITER //
CREATE PROCEDURE fetchGroups(IN plant_nameParam VARCHAR(100))
BEGIN
  SELECT g.group_name
  FROM user_groups g
  JOIN plants p ON p.entry_id = g.plant_id
  WHERE p.plant_name = plant_nameParam
  ORDER BY g.group_name;
END//
DELIMITER ;
