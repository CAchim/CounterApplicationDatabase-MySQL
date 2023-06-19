drop procedure if exists addUser;

delimiter //
CREATE procedure addUser(first_nameParam varchar(100), last_nameParam varchar(50), user_idParam varchar(10), emailParam text, user_passwordParam VARCHAR(30), user_groupParam VARCHAR(20))
BEGIN

if not(select exists(select* from Users where user_id = user_idParam)) then

insert into Users (first_name, last_name, user_id, email, user_password, user_group, user_token) values
(
first_nameParam, 
last_nameParam,
user_idParam, 
emailParam, 
user_passwordParam,
user_groupParam,
"16d5c19d0c22059793de23406140e67dbdc1f8a5ae579b5185ae83d562cda7e6"
);

else
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The user already exists!', MYSQL_ERRNO = 1005;
end if;

END;
//

call addUser("Catalin", "Achim", "uia57371", "catalin-gheorghe.achim@continental.com", "Test1234", "admin");