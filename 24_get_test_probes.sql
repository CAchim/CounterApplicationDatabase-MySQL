drop procedure if exists get_test_probes;

DELIMITER //
CREATE PROCEDURE get_test_probes (
    IN p_adapter_code VARCHAR(50),
    IN p_fixture_type VARCHAR(30)
)

BEGIN
if (select exists(select * from tp_description WHERE project_id IN (SELECT project_id FROM projects WHERE ad_code = p_adapter_code AND fixture_type = p_fixture_type))) then
    SELECT part_number, quantity
    FROM tp_description
    WHERE project_id IN (SELECT project_id FROM projects WHERE ad_code = p_adapter_code AND fixture_type = p_fixture_type);

else
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Cannot find any test probes for the specified equipment!', MYSQL_ERRNO = 1001;
end if;    


END; //
DELIMITER //