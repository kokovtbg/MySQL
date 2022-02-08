CREATE SCHEMA ruk_database;
USE ruk_database;

# 01.	Table Design
CREATE TABLE branches (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30) NOT NULL UNIQUE
);
CREATE TABLE employees (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(20) NOT NULL,
last_name VARCHAR(20) NOT NULL,
salary DECIMAL(10,2) NOT NULL,
started_on DATE NOT NULL,
branch_id INT NOT NULL,
CONSTRAINT fk_employees_branches
FOREIGN KEY (branch_id)
REFERENCES branches(id)
);
CREATE TABLE clients (
id INT PRIMARY KEY AUTO_INCREMENT,
full_name VARCHAR(50) NOT NULL,
age INT NOT NULL
);
CREATE TABLE employees_clients (
employee_id INT NOT NULL,
client_id INT NOT NULL,
CONSTRAINT fk_employees_clients_employees
FOREIGN KEY (employee_id)
REFERENCES employees(id),
CONSTRAINT fk_employees_clients_clients
FOREIGN KEY (client_id)
REFERENCES clients(id)
);
CREATE TABLE bank_accounts (
id INT PRIMARY KEY AUTO_INCREMENT,
account_number VARCHAR(10) NOT NULL,
balance DECIMAL(10,2) NOT NULL,
client_id INT NOT NULL UNIQUE,
CONSTRAINT fk_bank_accounts_clients
FOREIGN KEY (client_id)
REFERENCES clients(id)
);
CREATE TABLE cards (
id INT PRIMARY KEY AUTO_INCREMENT,
card_number VARCHAR(19) NOT NULL,
card_status VARCHAR(7) NOT NULL,
bank_account_id INT NOT NULL,
CONSTRAINT fk_cards_bank_accounts
FOREIGN KEY (bank_account_id)
REFERENCES bank_accounts(id)
);

# 02.	Insert
INSERT INTO cards(card_number, card_status, bank_account_id)
SELECT reverse(full_name), 'Active', id
FROM clients
WHERE id BETWEEN 191 AND 200;

# 03.	Update
UPDATE employees_clients AS ec
SET ec.employee_id = (
	SELECT
		ecs.employee_id
	FROM (SELECT * FROM employees_clients) AS ecs
	GROUP BY ecs.employee_id
	ORDER BY
		COUNT(ecs.client_id) ASC,
		ecs.employee_id ASC
	LIMIT 1)
WHERE ec.employee_id = ec.client_id;

# 04.	Delete
DELETE e
FROM employees AS e
LEFT JOIN employees_clients AS ec
ON ec.employee_id = e.id
WHERE ec.client_id IS NULL;

# 05.	Clients
SELECT id, full_name FROM clients
ORDER BY id;

# 06.	Newbies
SELECT id, concat(first_name, ' ', last_name) AS 'full_name',
concat('$', salary), started_on
FROM employees
WHERE salary >= 100000
AND started_on >= '2018-01-01'
ORDER BY salary DESC, id;

# 07.	Cards against Humanity
SELECT ca.id, concat(ca.card_number, ' : ', cl.full_name) AS 'card_token'
FROM cards AS ca
JOIN bank_accounts AS ba
ON ba.id = ca.bank_account_id
JOIN clients AS cl
ON cl.id = ba.client_id
ORDER BY ca.id DESC;

# 08.	Top 5 Employees
SELECT concat(first_name, ' ', last_name) AS 'name',
started_on, count(c.id) AS 'count_of_clients'
FROM employees AS e
JOIN employees_clients AS ec
ON ec.employee_id = e.id
JOIN clients AS c
ON c.id = ec.client_id
GROUP BY e.id, started_on
ORDER BY count_of_clients DESC, e.id
LIMIT 5;

# 09.	Branch cards
SELECT b.`name`, count(c.id) AS 'count_of_cards'
FROM branches AS b
LEFT JOIN employees AS e
ON e.branch_id = b.id
LEFT JOIN employees_clients AS ec
ON ec.employee_id = e.id
LEFT JOIN clients AS cl
ON cl.id = ec.client_id
LEFT JOIN bank_accounts AS ba
ON ba.client_id = cl.id
LEFT JOIN cards AS c
ON c.bank_account_id = ba.id
GROUP BY b.`name`
ORDER BY count_of_cards DESC, b.`name`;

# 10.	Extract client cards count
DELIMITER //
CREATE FUNCTION udf_client_cards_count(name_client VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (
    SELECT count(c.id) 
    FROM clients AS cl
    JOIN bank_accounts AS ba
    ON ba.client_id = cl.id
    JOIN cards AS c
    ON c.bank_account_id = ba.id
    WHERE cl.full_name = name_client
    GROUP BY cl.full_name
    );
END //
DELIMITER ;

# 11.	Extract Client Info
DELIMITER //
CREATE PROCEDURE udp_clientinfo(client_full_name VARCHAR(50))
BEGIN
	SELECT full_name, age, account_number, concat('$', balance)
    FROM clients AS c
    JOIN bank_accounts AS ba
    ON ba.client_id = c.id
    WHERE full_name = client_full_name;
END //
DELIMITER ;