# 1.	One-To-One Relationship
CREATE TABLE `passports` (
`passport_id` INT PRIMARY KEY,
`passport_number` CHAR(8) UNIQUE
);
CREATE TABLE `people` (
`person_id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(20),
`salary` DECIMAL(7,2),
`passport_id` INT NOT NULL UNIQUE,
CONSTRAINT fk_people_passports
FOREIGN KEY(`passport_id`)
REFERENCES `passports`(`passport_id`)
);
INSERT INTO `passports`
VALUES
(101, 'N34FG21B'),
(102, 'K65LO4R7'),
(103, 'ZE657QP2');
INSERT INTO `people`(`first_name`, `salary`, `passport_id`)
VALUES
('Roberto', 43300.00, 102),
('Tom', 56100.00, 103),
('Yana', 60200.00, 101);

# 2.	One-To-Many Relationship
CREATE TABLE `manufacturers` (
`manufacturer_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20),
`established_on` DATETIME
);
CREATE TABLE `models` (
`model_id` INT PRIMARY KEY,
`name` VARCHAR(20),
`manufacturer_id` INT NOT NULL,
CONSTRAINT fk_models_manufacturers
FOREIGN KEY (`manufacturer_id`)
REFERENCES `manufacturers`(`manufacturer_id`)
);
INSERT INTO `manufacturers` (`name`, `established_on`)
VALUES
('BMW', '1916-03-01'),
('Tesla', '2003-01-01'),
('Lada', '1966-05-01');
INSERT INTO `models`
VALUES
(101, 'X1', 1),
(102, 'i6', 1),
(103, 'Model S', 2),
(104, 'Model X', 2),
(105, 'Model 3', 2),
(106, 'Nova', 3);

# 3.	Many-To-Many Relationship
CREATE TABLE `students` (
`student_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30)
);
CREATE TABLE `exams` (
`exam_id` INT PRIMARY KEY,
`name` VARCHAR(30)
);
CREATE TABLE `students_exams` (
`student_id` INT NOT NULL,
`exam_id` INT NOT NULL,
PRIMARY KEY (`student_id`, `exam_id`),
CONSTRAINT fk_students_exams_students
FOREIGN KEY (`student_id`)
REFERENCES `students`(`student_id`),
CONSTRAINT fk_students_exams_exams
FOREIGN KEY (`exam_id`)
REFERENCES `exams`(`exam_id`)
);
INSERT INTO `students`(`name`)
VALUES
('Mila'),
('Toni'),
('Ron');
INSERT INTO `exams`(`exam_id`, `name`)
VALUES
(101, 'Spring MVC'),
(102, 'Neo4j'),
(103, 'Oracle 11g');
INSERT INTO `students_exams`
VALUES
(1, 101),
(1, 102),
(2, 101),
(3, 103),
(2, 102),
(2, 103);

# 4.	Self-Referencing
CREATE TABLE `teachers` (
`teacher_id` INT PRIMARY KEY,
`name` VARCHAR(20),
`manager_id` INT
);
INSERT INTO `teachers`(`teacher_id`, `name`)
VALUES
(101, 'John');
INSERT INTO `teachers`
VALUES
(102, 'Maya', 106),
(103, 'Silvia', 106),
(104, 'Ted', 105),
(105, 'Mark', 101),
(106, 'Greta', 101);
ALTER TABLE `teachers`
ADD FOREIGN KEY (`manager_id`)
REFERENCES `teachers` (`teacher_id`);

# 5.	Online Store Database
CREATE TABLE `item_types` (
`item_type_id` INT(11) PRIMARY KEY,
`name` VARCHAR(50)
);
CREATE TABLE `cities` (
`city_id` INT(11) PRIMARY KEY,
`name` VARCHAR(50)
);
CREATE TABLE `items` (
`item_id` INT(11) PRIMARY KEY,
`name` VARCHAR(50),
`item_type_id` INT(11) NOT NULL,
FOREIGN KEY (`item_type_id`)
REFERENCES `item_types`(`item_type_id`)
);
CREATE TABLE `customers` (
`customer_id` INT(11) PRIMARY KEY,
`name` VARCHAR(50),
`birthday` DATE,
`city_id` INT(11) NOT NULL,
FOREIGN KEY (`city_id`)
REFERENCES `cities`(`city_id`)
);
CREATE TABLE `orders` (
`order_id` INT(11) PRIMARY KEY,
`customer_id` INT(11) NOT NULL,
FOREIGN KEY (`customer_id`)
REFERENCES `customers`(`customer_id`)
);
CREATE TABLE `order_items` (
`order_id` INT(11) NOT NULL,
`item_id` INT(11) NOT NULL,
PRIMARY KEY (`order_id`, `item_id`),
FOREIGN KEY (`order_id`)
REFERENCES `orders`(`order_id`),
FOREIGN KEY (`item_id`)
REFERENCES `items`(`item_id`)
);

# 6.	University Database
CREATE TABLE `subjects` (
`subject_id` INT(11) PRIMARY KEY,
`subject_name` VARCHAR(50)
);
CREATE TABLE `majors` (
`major_id` INT(11) PRIMARY KEY,
`name` VARCHAR(50)
);
CREATE TABLE `students` (
`student_id` INT(11) PRIMARY KEY,
`student_number` VARCHAR(12),
`student_name` VARCHAR(50),
`major_id` INT(11) NOT NULL,
FOREIGN KEY (`major_id`)
REFERENCES `majors`(`major_id`)
);
CREATE TABLE `payments` (
`payment_id` INT(11) PRIMARY KEY,
`payment_date` DATE,
`payment_amount` DECIMAL(8, 2),
`student_id` INT(11) NOT NULL,
FOREIGN KEY (`student_id`)
REFERENCES `students`(`student_id`)
);
CREATE TABLE `agenda` (
`student_id` INT(11) NOT NULL,
`subject_id` INT(11) NOT NULL,
PRIMARY KEY (`student_id`, `subject_id`),
FOREIGN KEY (`student_id`)
REFERENCES `students`(`student_id`),
FOREIGN KEY (`subject_id`)
REFERENCES `subjects`(`subject_id`)
);

# 9.	Peaks in Rila
SELECT `mountain_range`, `peak_name`, `elevation` AS 'peak_elevation'
FROM `mountains` AS m
JOIN `peaks` AS p
ON p.`mountain_id` = m.`id`
WHERE `mountain_range` = 'Rila'
ORDER BY `elevation` DESC;