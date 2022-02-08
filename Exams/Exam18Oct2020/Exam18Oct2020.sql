CREATE SCHEMA softuni_stores_system;
USE softuni_stores_system;

# 1.	Table Design
CREATE TABLE pictures (
id INT PRIMARY KEY AUTO_INCREMENT,
url VARCHAR(100) NOT NULL,
added_on DATETIME NOT NULL
);
CREATE TABLE categories (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE
);
CREATE TABLE products (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE,
best_before DATE,
price DECIMAL(10,2) NOT NULL,
`description` TEXT,
category_id INT NOT NULL,
picture_id INT NOT NULL,
FOREIGN KEY (category_id)
REFERENCES categories(id),
FOREIGN KEY (picture_id)
REFERENCES pictures(id)
);
CREATE TABLE towns (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL UNIQUE
);
CREATE TABLE addresses (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL UNIQUE,
town_id INT NOT NULL,
FOREIGN KEY (town_id)
REFERENCES towns(id)
);
CREATE TABLE stores (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL UNIQUE,
rating FLOAT NOT NULL,
has_parking BOOLEAN DEFAULT FALSE,
address_id INT NOT NULL,
FOREIGN KEY (address_id)
REFERENCES addresses(id)
);
CREATE TABLE products_stores (
product_id INT NOT NULL,
store_id INT NOT NULL,
PRIMARY KEY (product_id, store_id),
FOREIGN KEY (product_id)
REFERENCES products(id),
FOREIGN KEY (store_id)
REFERENCES stores(id)
);
CREATE TABLE employees (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(15) NOT NULL,
middle_name CHAR(1),
last_name VARCHAR(20) NOT NULL,
salary DECIMAL(19,2) DEFAULT 0,
hire_date DATE NOT NULL,
manager_id INT,
store_id INT NOT NULL, 
FOREIGN KEY (manager_id)
REFERENCES employees(id),
FOREIGN KEY (store_id)
REFERENCES stores(id)
);

# 2.	Insert
INSERT INTO products_stores
SELECT p.id, 1 FROM products AS p
LEFT JOIN products_stores as ps
ON ps.product_id = p.id
WHERE ps.store_id IS NULL;

# 3.	Update
UPDATE employees 
SET manager_id = 3, salary = salary - 500
WHERE year(hire_date) >= 2003
AND store_id NOT IN (5, 14);

# 4.	Delete
DELETE FROM employees
WHERE manager_id IS NOT NULL
AND salary >= 6000;

# 5.	Employees 
SELECT first_name, middle_name, last_name, salary, hire_date
FROM employees
ORDER BY hire_date DESC;

# 6.	Products with old pictures
SELECT pr.`name` AS 'product_name', pr.price, pr.best_before,
concat(substring(`description`, 1, 10), '...') AS 'short_description',
pi.url
FROM products AS pr
JOIN pictures AS pi
ON pi.id = pr.picture_id
WHERE char_length(`description`) > 100
AND year(pi.added_on) < 2019
AND pr.price > 20
ORDER BY pr.price DESC;

# 7.	Counts of products in stores and their average 
SELECT s.`name`, count(p.id) AS 'product_count', round(avg(p.price), 2) AS 'avg' 
FROM stores AS s
LEFT JOIN products_stores AS ps
ON s.id = ps.store_id
LEFT JOIN products AS p
ON p.id = ps.product_id
GROUP BY s.`name`
ORDER BY `product_count` DESC, `avg` DESC, s.id;

# 8.	Specific employee
SELECT concat(first_name, ' ', last_name) AS 'full_name',
s.`name` AS 'Store_name', a.`name`, salary
FROM stores AS s
JOIN employees
ON s.id = employees.store_id
JOIN addresses AS a
ON a.id = s.address_id
WHERE salary < 4000
AND locate('5', a.`name`) != 0
AND char_length(s.`name`) > 8
AND right(last_name, 1) = 'n';

# 9.	Find all information of stores
SELECT reverse(s.`name`), concat(upper(t.`name`), '-', a.`name`) AS 'full_address',
count(e.id) AS 'employee_count'
FROM stores AS s
JOIN employees AS e
ON e.store_id = s.id
JOIN addresses AS a
ON a.id = s.address_id
JOIN towns AS t
ON t.id = a.town_id
GROUP BY s.id
HAVING employee_count >= 1
ORDER BY full_address;

# 10.	Find full name of top paid employee by store name
DELIMITER //
CREATE FUNCTION udf_top_paid_employee_by_store(store_name VARCHAR(50))
RETURNS VARCHAR(500)
DETERMINISTIC
BEGIN
	RETURN 
    (SELECT concat(first_name, ' ', middle_name, '. ', last_name, ' works in store for ', timestampdiff(YEAR, hire_date, '2020-10-18'), ' years')
    FROM employees AS e
    JOIN stores AS s
    ON s.id = e.store_id
    WHERE s.`name` = store_name
    ORDER BY salary DESC
    LIMIT 1);
END //
DELIMITER ;

# 11.	Update product price by address
DELIMITER //
CREATE PROCEDURE udp_update_product_price(address_name VARCHAR (50))
BEGIN
	UPDATE products AS p
    JOIN products_stores AS ps
    ON ps.product_id = p.id
    JOIN stores AS s
    ON s.id = ps.store_id
    JOIN addresses AS a
    ON s.address_id = a.id
    SET price = price + if(left(address_name, 1) = '0', 100, 200)
    WHERE a.`name` = address_name;
END //
DELIMITER ;