CREATE SCHEMA colonial_journey_management_system_db;
USE colonial_journey_management_system_db;

# 00. Table Design 
CREATE TABLE planets (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30) NOT NULL
);
CREATE TABLE spaceports (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
planet_id INT NOT NULL,
CONSTRAINT fk_spaceports_planets
FOREIGN KEY (planet_id)
REFERENCES planets(id)
);
CREATE TABLE spaceships (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
manufacturer VARCHAR(30) NOT NULL,
light_speed_rate INT DEFAULT 0
);
CREATE TABLE colonists (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(20) NOT NULL,
last_name VARCHAR(20) NOT NULL,
ucn CHAR(10) NOT NULL UNIQUE,
birth_date DATE NOT NULL
);
CREATE TABLE journeys (
id INT PRIMARY KEY AUTO_INCREMENT,
journey_start DATETIME NOT NULL,
journey_end DATETIME NOT NULL,
purpose ENUM('Medical', 'Technical', 'Educational', 'Military'),
destination_spaceport_id INT NOT NULL,
spaceship_id INT NOT NULL,
CONSTRAINT fk_journeys_spaceports
FOREIGN KEY (destination_spaceport_id)
REFERENCES spaceports(id),
CONSTRAINT fk_journeys_spaceships
FOREIGN KEY (spaceship_id)
REFERENCES spaceships(id)
);
CREATE TABLE travel_cards (
id INT PRIMARY KEY AUTO_INCREMENT,
card_number CHAR(10) NOT NULL UNIQUE,
job_during_journey ENUM('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook'),
colonist_id INT NOT NULL,
journey_id INT NOT NULL,
CONSTRAINT fk_travel_cards_colonists
FOREIGN KEY (colonist_id)
REFERENCES colonists(id),
CONSTRAINT fk_travel_cards_journeys
FOREIGN KEY (journey_id)
REFERENCES journeys(id)
);

# 01.	Data Insertion
INSERT INTO travel_cards(card_number, job_during_journey, colonist_id, journey_id)
SELECT if(birth_date > '1980-01-01', 
concat(year(birth_date), substring(birth_date, 9, 2), substring(ucn, 1, 4)), 
concat(year(birth_date), substring(birth_date, 9, 2), substring(ucn, 7))),
CASE
	WHEN id % 2 = 0 THEN 'Pilot'
    WHEN id % 3 = 0 THEN 'Cook'
    ELSE 'Engineer'
END,
id, left(ucn, 1)
FROM colonists
WHERE id BETWEEN 96 AND 100;

# 02.	Data Update
UPDATE journeys
SET purpose = CASE 
	WHEN id % 2 = 0 THEN 'Medical'
    WHEN id % 3 = 0 THEN 'Technical'
    WHEN id % 5 = 0 THEN 'Educational'
    WHEN id % 7 = 0 THEN 'Military'
    ELSE purpose
END;

# 03.	Data Deletion
CREATE TABLE colonists_to_delete AS
SELECT c.id
FROM colonists AS c
LEFT JOIN travel_cards AS tc
ON tc.colonist_id = c.id
WHERE tc.id IS NULL;
DELETE c, ctd
FROM colonists AS c, colonists_to_delete AS ctd
WHERE ctd.id = c.id;
DROP TABLE colonists_to_delete;

# 04.Extract all travel cards
SELECT card_number, job_during_journey 
FROM travel_cards
ORDER BY card_number;

# 05. Extract all colonists
SELECT id, concat(first_name, ' ', last_name) AS 'full_name', ucn
FROM colonists
ORDER BY first_name, last_name, id;

# 06.	Extract all military journeys
SELECT id, journey_start, journey_end FROM journeys
WHERE purpose = 'Military'
ORDER BY journey_start;

# 07.	Extract all pilots
SELECT c.id, concat(first_name, ' ', last_name) 
FROM colonists AS c
JOIN travel_cards AS tc
ON tc.colonist_id = c.id
WHERE job_during_journey = 'Pilot'
ORDER BY c.id;

# 08.	Count all colonists that are on technical journey
SELECT count(c.id) 
FROM colonists AS c
JOIN travel_cards AS tc
ON tc.colonist_id = c.id
JOIN journeys AS j
ON j.id = tc.journey_id
WHERE j.purpose = 'Technical';

# 09.Extract the fastest spaceship
SELECT ss.`name`, sp.`name` 
FROM spaceships AS ss
JOIN journeys AS j
ON j.spaceship_id = ss.id
JOIN spaceports AS sp
ON sp.id = j.destination_spaceport_id
ORDER BY light_speed_rate DESC
LIMIT 1;

# 10.Extract spaceships with pilots younger than 30 years
SELECT ss.`name`, ss.manufacturer 
FROM spaceships AS ss
JOIN journeys AS j
ON j.spaceship_id = ss.id
JOIN travel_cards AS tc
ON tc.journey_id = j.id
JOIN colonists AS c
ON c.id = tc.colonist_id
WHERE timestampdiff(YEAR, c.birth_date, '2019-01-01') < 30
AND tc.job_during_journey = 'Pilot'
ORDER BY ss.`name`;

# 11. Extract all educational mission planets and spaceports
SELECT p.`name`, sp.`name`
FROM planets AS p
JOIN spaceports AS sp
ON sp.planet_id = p.id
JOIN journeys AS j
ON j.destination_spaceport_id = sp.id
WHERE j.purpose = 'Educational'
ORDER BY sp.`name` DESC;

# 12. Extract all planets and their journey count
SELECT p.`name` AS 'planet_name', count(j.id) AS 'journeys_count'
FROM planets AS p
LEFT JOIN spaceports AS sp
ON sp.planet_id = p.id
LEFT JOIN journeys AS j
ON j.destination_spaceport_id = sp.id
GROUP BY planet_name
ORDER BY journeys_count DESC, planet_name;

# 13.Extract the shortest journey
SELECT j.id, p.`name` AS 'planet_name',
sp.`name` AS 'spaceport_name', j.purpose AS 'journey_purpose'
FROM journeys AS j
JOIN spaceports AS sp
ON sp.id = j.destination_spaceport_id
JOIN planets AS p
ON p.id = sp.planet_id
GROUP BY j.id
ORDER BY j.journey_end - j.journey_start
LIMIT 1;

# 14.Extract the less popular job
SELECT tc.job_during_journey FROM travel_cards AS tc
JOIN colonists AS c
ON c.id = tc.colonist_id
JOIN journeys AS j
ON j.id = tc.journey_id
WHERE (
SELECT j.id FROM journeys AS j
GROUP BY j.id
ORDER BY j.journey_end - j.journey_start DESC
LIMIT 1)
LIMIT 1;

# 15. Get colonists count
DELIMITER //
CREATE FUNCTION CREATE SCHEMA colonial_journey_management_system_db;
USE colonial_journey_management_system_db;

# 00. Table Design 
CREATE TABLE planets (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30) NOT NULL
);
CREATE TABLE spaceports (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
planet_id INT NOT NULL,
CONSTRAINT fk_spaceports_planets
FOREIGN KEY (planet_id)
REFERENCES planets(id)
);
CREATE TABLE spaceships (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
manufacturer VARCHAR(30) NOT NULL,
light_speed_rate INT DEFAULT 0
);
CREATE TABLE colonists (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(20) NOT NULL,
last_name VARCHAR(20) NOT NULL,
ucn CHAR(10) NOT NULL UNIQUE,
birth_date DATE NOT NULL
);
CREATE TABLE journeys (
id INT PRIMARY KEY AUTO_INCREMENT,
journey_start DATETIME NOT NULL,
journey_end DATETIME NOT NULL,
purpose ENUM('Medical', 'Technical', 'Educational', 'Military'),
destination_spaceport_id INT NOT NULL,
spaceship_id INT NOT NULL,
CONSTRAINT fk_journeys_spaceports
FOREIGN KEY (destination_spaceport_id)
REFERENCES spaceports(id),
CONSTRAINT fk_journeys_spaceships
FOREIGN KEY (spaceship_id)
REFERENCES spaceships(id)
);
CREATE TABLE travel_cards (
id INT PRIMARY KEY AUTO_INCREMENT,
card_number CHAR(10) NOT NULL UNIQUE,
job_during_journey ENUM('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook'),
colonist_id INT NOT NULL,
journey_id INT NOT NULL,
CONSTRAINT fk_travel_cards_colonists
FOREIGN KEY (colonist_id)
REFERENCES colonists(id),
CONSTRAINT fk_travel_cards_journeys
FOREIGN KEY (journey_id)
REFERENCES journeys(id)
);

# 01.	Data Insertion
INSERT INTO travel_cards(card_number, job_during_journey, colonist_id, journey_id)
SELECT if(birth_date > '1980-01-01', 
concat(year(birth_date), day(birth_date), substring(ucn, 1, 4)), 
concat(year(birth_date), month(birth_date), substring(ucn, 7))),
CASE
	WHEN id % 2 = 0 THEN 'Pilot'
    WHEN id % 3 = 0 THEN 'Cook'
    ELSE 'Engineer'
END,
id, left(ucn, 1)
FROM colonists
WHERE id BETWEEN 96 AND 100;

# 02.	Data Update
UPDATE journeys
SET purpose = CASE 
	WHEN id % 2 = 0 THEN 'Medical'
    WHEN id % 3 = 0 THEN 'Technical'
    WHEN id % 5 = 0 THEN 'Educational'
    WHEN id % 7 = 0 THEN 'Military'
    ELSE purpose
END;

# 03.	Data Deletion
CREATE TABLE colonists_to_delete AS
SELECT c.id
FROM colonists AS c
LEFT JOIN travel_cards AS tc
ON tc.colonist_id = c.id
WHERE tc.id IS NULL;
DELETE c, ctd
FROM colonists AS c, colonists_to_delete AS ctd
WHERE ctd.id = c.id;
DROP TABLE colonists_to_delete;

# 04.Extract all travel cards
SELECT card_number, job_during_journey 
FROM travel_cards
ORDER BY card_number;

# 05. Extract all colonists
SELECT id, concat(first_name, ' ', last_name) AS 'full_name', ucn
FROM colonists
ORDER BY first_name, last_name, id;

# 06.	Extract all military journeys
SELECT id, journey_start, journey_end FROM journeys
WHERE purpose = 'Military'
ORDER BY journey_start;

# 07.	Extract all pilots
SELECT c.id, concat(first_name, ' ', last_name) 
FROM colonists AS c
JOIN travel_cards AS tc
ON tc.colonist_id = c.id
WHERE job_during_journey = 'Pilot'
ORDER BY c.id;

# 08.	Count all colonists that are on technical journey
SELECT count(c.id) 
FROM colonists AS c
JOIN travel_cards AS tc
ON tc.colonist_id = c.id
JOIN journeys AS j
ON j.id = tc.journey_id
WHERE j.purpose = 'Technical';

# 09.Extract the fastest spaceship
SELECT ss.`name`, sp.`name` 
FROM spaceships AS ss
JOIN journeys AS j
ON j.spaceship_id = ss.id
JOIN spaceports AS sp
ON sp.id = j.destination_spaceport_id
ORDER BY light_speed_rate DESC
LIMIT 1;

# 10.Extract spaceships with pilots younger than 30 years
SELECT ss.`name`, ss.manufacturer FROM spaceships AS ss
JOIN journeys AS j
ON j.spaceship_id = ss.id
JOIN travel_cards AS tc
ON tc.journey_id = j.id
JOIN colonists AS c
ON c.id = tc.colonist_id
WHERE timestampdiff(YEAR, c.birth_date, '2019-01-01') < 30
ORDER BY ss.`name`;

# 11. Extract all educational mission planets and spaceports
SELECT p.`name`, sp.`name`
FROM planets AS p
JOIN spaceports AS sp
ON sp.planet_id = p.id
JOIN journeys AS j
ON j.destination_spaceport_id = sp.id
WHERE j.purpose = 'Educational'
ORDER BY sp.`name` DESC;

# 12. Extract all planets and their journey count
SELECT p.`name` AS 'planet_name', count(j.id) AS 'journeys_count'
FROM planets AS p
LEFT JOIN spaceports AS sp
ON sp.planet_id = p.id
LEFT JOIN journeys AS j
ON j.destination_spaceport_id = sp.id
GROUP BY planet_name
ORDER BY journeys_count DESC, planet_name;

# 13.Extract the shortest journey
SELECT j.id, p.`name` AS 'planet_name',
sp.`name` AS 'spaceport_name', j.purpose AS 'journey_purpose'
FROM journeys AS j
JOIN spaceports AS sp
ON sp.id = j.destination_spaceport_id
JOIN planets AS p
ON p.id = sp.planet_id
GROUP BY j.id
ORDER BY j.journey_end - j.journey_start
LIMIT 1;

# 14.Extract the less popular job
SELECT tc.job_during_journey FROM travel_cards AS tc
JOIN colonists AS c
ON c.id = tc.colonist_id
JOIN journeys AS j
ON j.id = tc.journey_id
WHERE (
SELECT j.id FROM journeys AS j
GROUP BY j.id
ORDER BY j.journey_end - j.journey_start DESC
LIMIT 1)
LIMIT 1;

# 15. Get colonists count
DELIMITER //
CREATE FUNCTION udf_count_colonists_by_destination_planet(planet_name VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT count(c.id) FROM planets AS p
	LEFT JOIN spaceports AS sp
	ON sp.planet_id = p.id
	LEFT JOIN journeys AS j
	ON j.destination_spaceport_id = sp.id
	LEFT JOIN travel_cards AS tc
	ON tc.journey_id = j.id
	LEFT JOIN colonists AS c
	ON tc.colonist_id = c.id
	WHERE p.`name` = planet_name);
END //
DELIMITER ;

# 16. Modify spaceship
DELIMITER //
CREATE PROCEDURE udp_modify_spaceship_light_speed_rate(spaceship_name VARCHAR(50), light_speed_rate_increse INT(11))
BEGIN
	IF ((SELECT count(`name`)
	FROM spaceships
	WHERE `name` = spaceship_name) = 0) 
	THEN SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Spaceship you are trying to modify does not exists.';
	ELSE
	UPDATE spaceships
	SET light_speed_rate = light_speed_rate + light_speed_rate_increse
	WHERE `name` = spaceship_name;
	END IF;
END //
DELIMITER //
