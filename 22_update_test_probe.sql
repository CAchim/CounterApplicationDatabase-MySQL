drop procedure if exists update_test_probe;

DELIMITER //
CREATE PROCEDURE update_test_probe (
    IN p_adapter_code VARCHAR(50),
    IN p_fixture_type VARCHAR(30),
    IN p_original_part_number VARCHAR(255),
    IN p_new_name VARCHAR(255),
    IN p_new_quantity INT
)
BEGIN
  if (select exists(select * from tp_description WHERE project_id IN (SELECT project_id FROM projects WHERE ad_code = p_adapter_code AND fixture_type = p_fixture_type))) then
    -- Update tp_description
    UPDATE tp_description
    SET part_number = p_new_name, quantity = p_new_quantity
    WHERE project_id IN (SELECT project_id FROM projects WHERE ad_code = p_adapter_code AND fixture_type = p_fixture_type AND part_number = p_original_part_number);

    -- Rebuild testprobes string and update projects table
    UPDATE projects
    SET testprobes = (
        SELECT GROUP_CONCAT(CONCAT(part_number, ': ', quantity, 'pcs') separator'; ')
        FROM tp_description
        WHERE adapter_code = p_adapter_code AND fixture_type = p_fixture_type
    )
    WHERE adapter_code = p_adapter_code AND fixture_type = p_fixture_type;
  else
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Cannot find any test probes for the specified equipment!', MYSQL_ERRNO = 1001;
  end if;     
END //

DELIMITER ;
