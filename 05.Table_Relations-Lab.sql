# 1.	 Mountains and Peaks
CREATE TABLE `mountains` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL
);
CREATE TABLE `peaks` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `mountain_id` INT,
    CONSTRAINT fk_peaks_mountains FOREIGN KEY (`mountain_id`)
        REFERENCES mountains (`id`)
);

# 2.	 Trip Organization
SELECT driver_id, vehicle_type,
  CONCAT(first_name, ' ', last_name) AS driver_name
  FROM vehicles AS v
  JOIN campers AS c 
  ON v.driver_id = c.id;

# 3.	SoftUni Hiking
SELECT 
`starting_point` AS 'route_starting_point', 
`end_point` AS 'route_ending_point', 
`leader_id`, 
concat(`first_name`, ' ', `last_name`) AS 'leader_name'
FROM `routes` AS r
JOIN `campers` AS c
ON r.`leader_id` = c.`id`;

# 4.	Delete Mountains
CREATE TABLE `mountains`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL
);
CREATE TABLE `peaks`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL,
`mountain_id` INT,
CONSTRAINT `fk_mountain_id` 
FOREIGN KEY(`mountain_id`)
REFERENCES `mountains`(`id`)
ON DELETE CASCADE
);