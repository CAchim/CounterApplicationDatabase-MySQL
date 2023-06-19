#RUN FIRST TIME YOU INSTALL DB
create database counterdb;
SET GLOBAL log_bin_trust_function_creators = 1;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '3ng1n33r';
flush privileges;

#USE THE BELOW COMMAND TO CREATE THE PROCEDURES AFTER FIRST TIME INSTALL
SET SQL_SAFE_UPDATES = 0;

#for changing mysql bind addresses(change the IP to 0.0.0.0 to allow all users to connect to the database)
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf

#allow all clients to connect to database with user root
CREATE USER 'root'@'%' IDENTIFIED BY 'PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

#command to be used when you want to execute a .sql file 
mysql -u root -p3ng1n33r counterdb < 2_insert_into_projects.sql

#open mysql cli:
mysql -u root -p3ng1n33r counterdb 

#close mysql cli:
exit