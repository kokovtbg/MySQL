CREATE SCHEMA stc;
USE stc;

# 1.	Table Design
CREATE TABLE addresses (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(100) NOT NULL
);
CREATE TABLE categories (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(10) NOT NULL
);
CREATE TABLE clients (
id INT PRIMARY KEY AUTO_INCREMENT,
full_name VARCHAR(50) NOT NULL,
phone_number VARCHAR(20) NOT NULL
);
CREATE TABLE drivers (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(30) NOT NULL,
last_name VARCHAR(30) NOT NULL,
age INT NOT NULL,
rating FLOAT DEFAULT 5.5
);
CREATE TABLE cars (
id INT PRIMARY KEY AUTO_INCREMENT,
make VARCHAR(20) NOT NULL,
model VARCHAR(20),
`year` INT NOT NULL,
mileage INT,
`condition` CHAR(1) NOT NULL,
category_id INT NOT NULL,
FOREIGN KEY (category_id)
REFERENCES categories(id) 
);
CREATE TABLE courses (
id INT PRIMARY KEY AUTO_INCREMENT,
from_address_id INT NOT NULL,
`start` DATETIME NOT NULL,
bill DECIMAL(10,2) DEFAULT 10,
car_id INT NOT NULL,
client_id INT NOT NULL,
FOREIGN KEY (from_address_id)
REFERENCES addresses(id),
FOREIGN KEY (car_id)
REFERENCES cars(id),
FOREIGN KEY (client_id)
REFERENCES clients(id)
);
CREATE TABLE cars_drivers (
car_id INT NOT NULL,
driver_id INT NOT NULL,
PRIMARY KEY (car_id, driver_id),
FOREIGN KEY (car_id)
REFERENCES cars(id),
FOREIGN KEY (driver_id)
REFERENCES drivers(id)
);

# 2.	Insert
INSERT INTO clients(full_name, phone_number)
SELECT concat(first_name, ' ', last_name), 
concat('(088) 9999', d.id * 2)
FROM drivers AS d
WHERE d.id BETWEEN 10 AND 20;

# 3.	Update
UPDATE cars SET `condition` = 'C'
WHERE (mileage >= 800000 OR mileage IS NULL)
AND `year` <= 2010;

# 4.	Delete
DELETE cl, cou
FROM `clients` AS cl
LEFT JOIN `courses` AS cou
ON cl.`id` = cou.`client_id`
WHERE cou.`client_id` IS NULL;

# 5.	Cars
SELECT make, model, `condition` FROM cars
ORDER BY id;

# 6.	Drivers and Cars
SELECT first_name, last_name, make, model, mileage 
FROM cars_drivers AS cd
JOIN cars AS c
ON c.id = cd.car_id
JOIN drivers AS d
ON d.id = cd.driver_id
WHERE c.mileage IS NOT NULL
ORDER BY mileage DESC, first_name;

# 7.	Number of courses for each car
SELECT c.id, make, mileage, 
count(co.id) AS 'count_of_courses', round(avg(bill), 2) AS 'avg_bill'
FROM cars AS c
LEFT JOIN courses AS co
ON co.car_id = c.id
GROUP BY c.id
HAVING count_of_courses != 2
ORDER BY count_of_courses DESC, c.id;

# 8.	Regular clients
SELECT full_name, count(co.id) AS 'count_of_cars', sum(bill) AS 'total_sum'
FROM clients AS c
JOIN courses AS co
ON co.client_id = c.id
WHERE full_name LIKE '_a%'
GROUP BY full_name
HAVING count_of_cars > 1
ORDER BY full_name;

# 9.	Full information of courses
SELECT 
a.`name`,
CASE
	WHEN substring(time(co.`start`), 1, 2) BETWEEN 6 AND 20 THEN 'Day'
    ELSE 'Night'
END AS 'day_time',
co.bill, c.full_name, cars.make, cars.model, cat.`name`
FROM courses AS co
JOIN addresses AS a
ON a.id = co.from_address_id
JOIN clients AS c
ON c.id = co.client_id
JOIN cars
ON cars.id = co.car_id
JOIN categories AS cat
ON cat.id = cars.category_id
ORDER BY co.id;

# 10.	Find all courses by client’s phone number
DELIMITER //
CREATE FUNCTION udf_courses_by_client(phone_num VARCHAR(20))
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN
    (SELECT count(co.id) FROM courses AS co
    JOIN clients 
    ON clients.id = co.client_id
    WHERE clients.phone_number = phone_num);
END //
DELIMITER ;

# 11.	Full info for address
DELIMITER //
CREATE PROCEDURE udp_courses_by_address(address_name VARCHAR(100))
BEGIN
	SELECT a.`name`, c.full_name, 
    CASE
		WHEN bill <= 20 THEN 'Low'
        WHEN bill <= 30 THEN 'Medium'
        ELSE 'High'
	END AS 'level_of_bill',
    cars.make, cars.`condition`, cat.`name`
    FROM courses AS co
    JOIN addresses AS a
    ON a.id = co.from_address_id
    JOIN clients AS c
    ON c.id = co.client_id
    JOIN cars
    ON cars.id = co.car_id
    JOIN categories AS cat
    ON cat.id = cars.category_id
    WHERE a.`name` = address_name
    ORDER BY cars.make, c.full_name;
END //
DELIMITER ;