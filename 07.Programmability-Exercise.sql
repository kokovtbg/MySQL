# 1.	Employees with Salary Above 35000
DELIMITER //
CREATE PROCEDURE usp_get_employees_salary_above_35000()
BEGIN
	SELECT `first_name`, `last_name`
    FROM `employees`
    WHERE `salary` > 35000
    ORDER BY `first_name`, `last_name`, `salary`;
END //
DELIMITER ;
CALL usp_get_employees_salary_above_35000();

# 2.	Employees with Salary Above Number
DELIMITER //
CREATE PROCEDURE usp_get_employees_salary_above(decimal_number DECIMAL(19,4))
BEGIN
	SELECT `first_name`, `last_name`
    FROM `employees`
    WHERE `salary` >= decimal_number
    ORDER BY `first_name`, `last_name`, `employee_id`;
END //
DELIMITER ;
CALL usp_get_employees_salary_above(45000);

# 3.	Town Names Starting With
DELIMITER //
CREATE PROCEDURE usp_get_towns_starting_with(town_name VARCHAR(50))
BEGIN
	SELECT `name` 
    FROM `towns`
    WHERE substring(lower(`name`), 1, char_length(town_name)) = town_name
    ORDER BY `name`;
END //
DELIMITER ;
CALL usp_get_towns_starting_with('b');

# 4.	Employees from Town
DELIMITER //
CREATE PROCEDURE usp_get_employees_from_town(town_name VARCHAR(50))
BEGIN
	SELECT first_name, last_name from addresses AS a
	JOIN towns AS t
	ON t.town_id = a.town_id
	JOIN employees AS e
	ON e.address_id = a.address_id
	WHERE t.`name` = town_name
	ORDER BY first_name, last_name, employee_id;
END //
DELIMITER ;
CALL usp_get_employees_from_town('Sofia');

# 5.	Salary Level Function
DELIMITER //
CREATE FUNCTION ufn_get_salary_level(salary DOUBLE)
RETURNS VARCHAR(7)
DETERMINISTIC
BEGIN
	DECLARE salary_level VARCHAR(7);
    IF(salary < 30000) THEN SET salary_level = 'Low';
    ELSEIF(salary >= 30000 AND salary <= 50000) THEN SET salary_level = 'Average';
    ELSE SET salary_level = 'High';
    END IF;
    RETURN salary_level;
END //
DELIMITER ;
SELECT ufn_get_salary_level(13500.00);
SELECT ufn_get_salary_level(43300.00);
SELECT ufn_get_salary_level(125500.00);

# 6.	Employees by Salary Level
DELIMITER //
CREATE PROCEDURE usp_get_employees_by_salary_level(salary_level VARCHAR(7))
BEGIN
	SELECT first_name, last_name
    FROM employees
    WHERE
		CASE 
			WHEN lower(salary_level) = 'low' THEN employees.salary < 30000
            WHEN lower(salary_level) = 'average' THEN employees.salary BETWEEN 30000 AND 50000
            WHEN lower(salary_level) = 'high' THEN employees.salary > 50000
		END
	ORDER BY first_name DESC, last_name DESC;
END //
DELIMITER ;
CALL usp_get_employees_by_salary_level('high');

# 7.	Define Function
DELIMITER //
CREATE FUNCTION ufn_is_word_comprised(set_of_letters VARCHAR(50), word VARCHAR(50))
RETURNS BIT
DETERMINISTIC
BEGIN
	DECLARE count_let INT DEFAULT 1;
	DECLARE length INT;
	DECLARE current_char VARCHAR(5);
	SET length = CHAR_LENGTH(word);
 
	iter_word: LOOP
	SET current_char = SUBSTR(word,count_let,1);
	IF LOCATE(current_char,set_of_letters)=0 THEN RETURN 0;
	ELSEIF count_let=length THEN RETURN 1;
	END IF;
	SET count_let = count_let + 1;
	END LOOP iter_word;
END //
DELIMITER ;
SELECT ufn_is_word_comprised('oistmiahf', 'Sofia');

-- SECOND SOLUTION
DELIMITER //
CREATE FUNCTION ufn_is_word_comprised(set_of_letters VARCHAR(50), word VARCHAR(50))
RETURNS BIT
DETERMINISTIC
BEGIN
	RETURN word REGEXP(concat('^[', set_of_letters, ']+$'));
END //
DELIMITER ;

# 8.	Find Full Name
DELIMITER //
CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
	SELECT concat(first_name, ' ', last_name) AS full_name
    FROM account_holders
    ORDER BY `full_name`, `id`;
END //
DELIMITER ;
CALL usp_get_holders_full_name;

# 9.	People with Balance Higher Than
DELIMITER //
CREATE PROCEDURE usp_get_holders_with_balance_higher_than(desired_balance DOUBLE)
BEGIN
	SELECT first_name, last_name
    FROM account_holders AS ah
    JOIN accounts AS a
    ON a.account_holder_id = ah.id
    GROUP BY ah.id
    HAVING sum(a.balance) >= desired_balance
    ORDER BY ah.id;
END //
DELIMITER ;
CALL usp_get_holders_with_balance_higher_than('7000');

# 10.	Future Value Function
DELIMITER //
CREATE FUNCTION ufn_calculate_future_value
(sum DECIMAL(19,4), interest_rate DOUBLE, years INT)
RETURNS DECIMAL(19,4)
DETERMINISTIC
BEGIN
	DECLARE future_value DECIMAL(19,4);
    SET future_value = sum * pow(1 + interest_rate, years);
    RETURN future_value;
END //
DELIMITER ;
SELECT ufn_calculate_future_value(1000, 0.5, 5);

# 11.	Calculating Interest
DELIMITER //
CREATE PROCEDURE usp_calculate_future_value_for_account
(account_id INT, interest_rate DECIMAL(19,4))
BEGIN
	SELECT 
    a.id AS 'account_id', ah.first_name, ah.last_name, a.balance AS 'current_balance', 
    ufn_calculate_future_value(a.balance, interest_rate, 5) AS 'balance_in_5_years'
    FROM account_holders AS ah
    JOIN accounts AS a
    ON ah.id = a.account_holder_id
    WHERE a.id = account_id;
END //
DELIMITER ;
CALL usp_calculate_future_value_for_account(1, 0.1);

# 12.	Deposit Money
DELIMITER //
CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL(19,4))
BEGIN
	START TRANSACTION;
    IF(money_amount < 0) THEN ROLLBACK;
    ELSE
    UPDATE accounts SET balance = balance + money_amount
    WHERE id = account_id;
    END IF;
END //
DELIMITER ;
CALL usp_deposit_money(1, 10);

# 13.	Withdraw Money
DELIMITER //
CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19,4))
BEGIN
	START TRANSACTION;
    IF(money_amount < 0 
    OR (SELECT balance FROM accounts WHERE id = account_id) - money_amount < 0)
    THEN ROLLBACK;
    ELSE
    UPDATE accounts SET balance = balance - money_amount
    WHERE id = account_id;
    END IF;
END //
DELIMITER ;
CALL usp_withdraw_money(1, 10);

# 14.	Money Transfer
DELIMITER //
CREATE PROCEDURE usp_transfer_money
(from_account_id INT, to_account_id INT, amount DECIMAL(19,4))
BEGIN
	START TRANSACTION;
    IF(from_account_id < 0 OR from_account_id > (SELECT max(id) FROM accounts)
    OR to_account_id < 0 OR to_account_id > (SELECT max(id) FROM accounts)
    OR amount < 0 OR (SELECT balance FROM accounts WHERE id = from_account_id) - amount < 0
    OR from_account_id = to_account_id)
    THEN ROLLBACK;
    ELSE
    UPDATE accounts SET balance = balance - amount
    WHERE id = from_account_id;
    UPDATE accounts SET balance = balance + amount
    WHERE id = to_account_id;
    END IF;
END //
DELIMITER ;
CALL usp_transfer_money(1, 2, 10);

# 15.	Log Accounts Trigger
CREATE TABLE `logs` (
log_id INT PRIMARY KEY AUTO_INCREMENT, 
account_id INT NOT NULL, 
old_sum DECIMAL(19,4) NOT NULL, 
new_sum DECIMAL(19,4) NOT NULL
);
DELIMITER //
CREATE TRIGGER tr_changed_balance
AFTER UPDATE ON accounts
FOR EACH ROW
BEGIN
	INSERT INTO `logs`(account_id, old_sum, new_sum)
    VALUES(OLD.id, OLD.balance, NEW.balance);
END //
DELIMITER ;

# 16.	Emails Trigger
CREATE TABLE notification_emails (
id INT PRIMARY KEY AUTO_INCREMENT, 
recipient INT NOT NULL, 
`subject` VARCHAR(50), 
body VARCHAR(150)
);
DELIMITER //
CREATE TRIGGER tr_notification_emails
AFTER INSERT ON `logs`
FOR EACH ROW
BEGIN
	INSERT INTO notification_emails(recipient, `subject`, body)
    VALUES
    (NEW.account_id, concat('Balance change for account: ', NEW.account_id), 
    concat('On ', now(), ' your balance was changed from ', NEW.old_sum, ' to ', NEW.new_sum, '.'));
END //
DELIMITER ;
    