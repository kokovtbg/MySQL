CREATE DATABASE `minions`;

# 1. Create Tables
CREATE TABLE `minions` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50),
`age` VARCHAR(50)
);
CREATE TABLE `towns` (
`town_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50)
);

# 2. Alter Minions Table
ALTER TABLE `minions`
ADD COLUMN `town_id` INT,
ADD CONSTRAINT fk_minions_towns
FOREIGN KEY `minions`(`town_id`)
REFERENCES `towns`(`id`);

# 3. Insert Records in Both Tables
INSERT INTO `towns`(`id`, `name`)
VALUES
(1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna');
INSERT INTO `minions`(`id`, `name`, `age`, `town_id`)
VALUES 
(1, 'Kevin', 22, 1),
(2, 'Bob', 15, 3),
(3, 'Steward', NULL, 2);

# 4. Truncate Table Minions
TRUNCATE TABLE `minions`;

#5. Drop All Tables
DROP TABLE `minions`;
DROP TABLE `towns`;

# 6. Create Table People
CREATE TABLE `people` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(200) NOT NULL,
`picture` BLOB(2097152),
`height` DOUBLE(3,2),
`weight` DOUBLE(5,2),
`gender` CHAR(1) NOT NULL,
`birthdate` DATE NOT NULL,
`biography` TEXT
);
INSERT INTO `people`(`name`, `gender`, `birthdate`)
VALUES
('Ivan Ivanov', 'm', '1980-10-10'),
('Petar Petrov', 'm', '1981-05-13'),
('Petya Petkova', 'f', '1990-11-20'),
('Mariya Ivanova', 'f', '1999-08-11'),
('Georgi Georgiev', 'm', '1988-12-17');
 
 # 7. Create Table Users
 CREATE TABLE `users` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `username` VARCHAR(30) UNIQUE NOT NULL,
 `password` VARCHAR(26) NOT NULL,
 `profile_picture` BLOB,
 `last_login_time` DATETIME,
 `is_deleted` VARCHAR(5)
 );
 INSERT INTO `users`(`username`, `password`)
 VALUES
('abc', 'abc'),
('abcd', 'abcd'),
('abcde', 'abcde'),
('abcdef', 'abcdef'),
('abcdefg', 'abcdefg');

# 8. Change Primary Key
ALTER TABLE `users`
DROP PRIMARY KEY,
ADD CONSTRAINT pk_users
PRIMARY KEY `users`(`id`, `username`);

# 9. Set Default Value of a Field
ALTER TABLE `users`
MODIFY `last_login_time` DATETIME DEFAULT CURRENT_TIMESTAMP;

# 10. Set Unique Field
ALTER TABLE `users`
DROP PRIMARY KEY,
ADD CONSTRAINT pk_users
PRIMARY KEY `users`(`id`),
ADD CONSTRAINT uq_username
UNIQUE (`username`);

# 11. Movies Database
CREATE DATABASE movies;
CREATE TABLE directors (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`director_name` VARCHAR(50) NOT NULL,
`notes` TEXT
);
CREATE TABLE genres (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`genre_name` VARCHAR(50) NOT NULL,
`notes` TEXT
);
CREATE TABLE categories (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`category_name` VARCHAR(50) NOT NULL,
`notes` TEXT
);
CREATE TABLE movies (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`title` VARCHAR(50) NOT NULL,
`director_id` INT NOT NULL,
`copyright_year` YEAR,
`length` TIME NOT NULL,
`genre_id` INT NOT NULL,
`category_id` INT NOT NULL,
`rating` DOUBLE(4,2),
`notes` TEXT
);
INSERT INTO `directors`(`director_name`)
VALUES
('TestDirector1'),
('TestDirector2'),
('TestDirector3'),
('TestDirector4'),
('TestDirector5');
INSERT INTO `genres`(`genre_name`)
VALUES
('TestGenre1'),
('TestGenre2'),
('TestGenre3'),
('TestGenre4'),
('TestGenre5');
INSERT INTO `categories`(`category_name`)
VALUES
('TestCategory1'),
('TestCategory2'),
('TestCategory3'),
('TestCategory4'),
('TestCategory5');
INSERT INTO `movies`(`title`, `director_id`, `length`, `genre_id`, `category_id`)
VALUES
('TestTitle1', 1, '02:10:10', 1, 1),
('TestTitle2', 2, '02:10:10', 2, 2),
('TestTitle3', 3, '02:10:10', 3, 3),
('TestTitle4', 4, '02:10:10', 4, 4),
('TestTitle5', 5, '02:10:10', 5, 5);

# 12. Car Rental Database
CREATE DATABASE `car_rental`;
CREATE TABLE `categories` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`category` CHAR(1) NOT NULL,
`daily_rate` DOUBLE(5,2) NOT NULL,
`weekly_rate` DOUBLE(5,2),
`monthly_rate` DOUBLE(5,2),
`weekend_rate` DOUBLE(5,2)
);
CREATE TABLE `cars` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`plate_number` VARCHAR(20) NOT NULL,
`make` VARCHAR(20),
`model` VARCHAR(20),
`car_year` YEAR,
`category_id` INT NOT NULL,
`doors` INT(1),
`picture` BLOB,
`car_condition` TEXT,
`available` VARCHAR(3)
);
CREATE TABLE `employees` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(20) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`title` VARCHAR(50) NOT NULL,
`notes` TEXT
);
CREATE TABLE `customers` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`driver_licence_number` INT NOT NULL,
`full_name` VARCHAR(50),
`address` VARCHAR(50),
`city` VARCHAR(50),
`zip code` INT(4),
`notes` TEXT
);
CREATE TABLE `rental_orders` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`employee_id` INT NOT NULL,
`customer_id` INT NOT NULL,
`car_id` INT NOT NULL,
`car_condition` VARCHAR(50),
`tank_level` INT(3),
`kilometrage_start` INT,
`kilometrage_end` INT,
`total_kilometrage` INT,
`start_date` DATE NOT NULL,
`end_date` DATE NOT NULL,
`total_days` INT,
`rate_applied` DOUBLE(5,2) NOT NULL,
`tax_rate` DOUBLE(5,2),
`order_status` VARCHAR(20) NOT NULL,
`notes` TEXT
);
INSERT INTO `categories`(`category`, `daily_rate`)
VALUES
('A', 20),
('B', 30),
('C', 50);
INSERT INTO `cars`(`plate_number`, `category_id`)
VALUES
('CA1010BT', 1),
('BT1010BT', 2),
('PA1010PA', 3);
INSERT INTO `employees`(`first_name`, `last_name`, `title`)
VALUES
('Georgi', 'Georgiev', 'sales'),
('Ivan', 'Ivanov', 'manager'),
('Nikola', 'Nikolov', 'director');
INSERT INTO `customers`(`driver_licence_number`)
VALUES
(12345),
(56789),
(34567);
INSERT INTO `rental_orders`(`employee_id`, `customer_id`, `car_id`, `start_date`, `end_date`, `rate_applied`, `order_status`)
VALUES
(1, 1, 1, '2022-01-03', '2022-01-05', 20, 'completed'),
(2, 2, 2, '2022-01-03', '2022-01-05', 30, 'completed'),
(3, 3, 3, '2022-01-03', '2022-01-10', 20, 'uncompleted');

# 13. Basic Insert
CREATE DATABASE `soft_uni`;
CREATE TABLE `towns` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL
);
CREATE TABLE `addresses` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`address_text` TEXT,
`town_id` INT NOT NULL
);
CREATE TABLE `departments` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL
);
CREATE TABLE `employees` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(20) NOT NULL,
`middle_name` VARCHAR(20) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`job_title` VARCHAR(20) NOT NULL,
`department_id` INT NOT NULL,
`hire_date` DATE NOT NULL,
`salary` DOUBLE(7,2) NOT NULL,
`address_id` INT
);
ALTER TABLE `addresses`
ADD CONSTRAINT fk_addresses_towns
FOREIGN KEY `addresses`(`town_id`)
REFERENCES `towns`(`id`);
ALTER TABLE `employees`
ADD CONSTRAINT fk_employees_department
FOREIGN KEY `employees`(`department_id`)
REFERENCES `departments`(`id`),
ADD CONSTRAINT fk_employees_addresses
FOREIGN KEY `employees`(`address_id`)
REFERENCES `address`(`id`);
INSERT INTO `towns`(`name`)
VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas');
INSERT INTO `departments`(`name`)
VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance');
INSERT INTO `employees`(`first_name`, `middle_name`, `last_name`, `job_title`, `department_id`, `hire_date`, `salary`)
VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013-02-01', 3500),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004-03-02', 4000),
('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '2016-08-28', 525.25),
('Georgi', 'Terziev', 'Ivanov', 'CEO', 2, '2007-12-09', 3000),
('Peter', 'Pan', 'Pan', 'Intern', 3, '2016-08-28', 599.88);

# 14. Basic Select All Fields
SELECT * FROM `towns`;
SELECT * FROM  `departments`;
SELECT * FROM `employees`;

# 15. Basic Select All Fields and Order Them
SELECT * FROM `towns`
ORDER BY `name` ASC;
SELECT * FROM `departments`
ORDER BY `name` ASC;
SELECT * FROM `employees`
ORDER BY `salary` DESC;

# 16. Basic Select Some Fields
SELECT `name` FROM `towns`
ORDER BY `name` ASC;
SELECT `name` FROM `departments`
ORDER BY `name` ASC;
SELECT `first_name`, `last_name`, `job_title`, `salary` FROM `employees`
ORDER BY `salary` DESC;

 # 17. Increase Employees Salary
 UPDATE `employees` 
 SET `salary` = `salary` * 1.1;
 SELECT `salary` FROM `employees`;
 
 # 18. Delete All Records
 DELETE FROM `occupancies`;