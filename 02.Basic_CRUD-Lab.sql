# 1. Select Employee Information
ALTER TABLE `employees`
ORDER BY `id`;
SELECT `id`, `first_name`, `last_name`, `job_title` FROM `employees`;
 
 # 2. Select Employees with Filter
 SELECT `id`, concat(`first_name`, ' ', `last_name`), `job_title`, `salary`
 FROM `employees` WHERE `salary` > 1000
 ORDER BY `id`;
 
 # 3. Update Employees Salary
 UPDATE `employees` 
 SET `salary` = `salary` + 100
 WHERE `job_title` = 'Manager';
 SELECT `salary` FROM `employees`;
 
 # 4. Top Paid Employee
 CREATE VIEW `v_top_paid_employee` AS
 SELECT * FROM `employees`
 ORDER BY `salary` DESC LIMIT 1;
 SELECT * FROM `v_top_paid_employee`;
 
 # 5. Select Employees by Multiple Filters
 SELECT * FROM `employees` 
 WHERE `salary` >= 1000 AND `department_id` = 4
 ORDER BY `id`;
 
 # 6. Delete from Table
 DELETE FROM `employees`
 WHERE `department_id` = 1 OR `department_id` = 2;
 SELECT * FROM `employees`
 ORDER BY `id`;