# 1.	Find Names of All Employees by First Name
SELECT `first_name`, `last_name` FROM `employees`
WHERE `first_name` LIKE 'Sa%';

# 2.	Find Names of All Employees by Last Name
SELECT `first_name`, `last_name` FROM `employees`
WHERE `last_name` LIKE '%ei%';

# 3.	Find First Names of All Employees
SELECT `first_name` FROM `employees`
WHERE `department_id` IN(3,10)
AND year(`hire_date`) >= 1995 
AND year(`hire_date`) <= 2005
ORDER BY `employee_id`;

# 4.	Find All Employees Except Engineers
SELECT `first_name`, `last_name` FROM `employees`
WHERE locate('engineer', `job_title`) = 0;

# 5.	Find Towns with Name Length
SELECT `name` FROM `towns`
WHERE length(`name`) = 5 OR length(`name`) = 6
ORDER BY `name`;

# 6.	 Find Towns Starting With
SELECT * FROM `towns`
WHERE `name` REGEXP '^[MKBE][a-z]*'
ORDER BY `name`;

# 7.	 Find Towns Not Starting With
SELECT * FROM `towns`
WHERE `name` REGEXP '^[^RBD][a-z]*'
ORDER BY `name`;

# 8.	Create View Employees Hired After 2000 Year
CREATE VIEW v_employees_hired_after_2000 AS
SELECT `first_name`, `last_name` FROM `employees`
WHERE year(`hire_date`) > 2000;
SELECT * FROM v_employees_hired_after_2000;

# 9.	Length of Last Name
SELECT `first_name`, `last_name` FROM `employees`
WHERE length(`last_name`) = 5;

# 10.	Countries Holding 'A' 3 or More Times
SELECT `country_name`, `iso_code` FROM `countries`
WHERE `country_name` LIKE '%a%a%a%'
ORDER BY `iso_code`;

# 11.	 Mix of Peak and River Names
SELECT `peak_name`, `river_name`, 
concat(lower(`peak_name`), substring(lower(`river_name`), 2)) 
AS `mix`
FROM `peaks`, `rivers`
WHERE substring(`peak_name`, length(`peak_name`), length(`peak_name`)) = 
substring(lower(`river_name`), 1, 1)
ORDER BY `mix`;

# 12.	Games from 2011 and 2012 Year
SELECT `name`, substring(`start`, 1, 10) FROM `games`
WHERE year(`start`) IN (2011, 2012)
ORDER BY `start`, `name`
LIMIT 50;

# 13.	 User Email Providers
SELECT `user_name`, 
substring(`email`, locate('@', `email`) + 1, length(`email`) - locate('@', `email`)) 
AS `email provider`
FROM `users`
ORDER BY `email provider`, `user_name`;

# 14.	 Get Users with IP Address Like Pattern
SELECT `user_name`, `ip_address` FROM `users`
WHERE `ip_address` LIKE "___.1%.%.___"
ORDER BY `user_name`;

# 15.	 Show All Games with Duration and Part of the Day
SELECT `name`, 
CASE
	WHEN substring(`start`, 12, 2) >= 0 AND substring(`start`, 12, 2) < 12 THEN 'Morning'
	WHEN substring(`start`, 12, 2) >= 12 AND substring(`start`, 12, 2) < 18 THEN 'Afternoon'
    WHEN substring(`start`, 12, 2) >= 18 AND substring(`start`, 12, 2) < 24 THEN 'Evening'
END,
CASE
	WHEN `duration` <= 3 THEN 'Extra Short'
    WHEN `duration` > 3 AND `duration` <= 6 THEN 'Short'
    WHEN `duration` > 6 AND `duration` <= 10 THEN 'Long'
    ELSE 'Extra Long'
END
FROM `games`;

# 16.	 Orders Table
SELECT `product_name`, `order_date`, 
date_add(`order_date`, INTERVAL 3 DAY),
date_add(`order_date`, INTERVAL 1 MONTH)
FROM `orders`;