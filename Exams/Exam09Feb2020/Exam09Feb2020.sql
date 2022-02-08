CREATE SCHEMA fsd;
USE fsd;

# 1.	Table Design
CREATE TABLE coaches (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
salary DECIMAL(10,2) NOT NULL DEFAULT 0,
coach_level INT NOT NULL DEFAULT 0
);
CREATE TABLE skills_data (
id INT PRIMARY KEY AUTO_INCREMENT,
dribbling INT DEFAULT 0,
pace INT DEFAULT 0,
passing INT DEFAULT 0,
shooting INT DEFAULT 0,
speed INT DEFAULT 0,
strength INT DEFAULT 0
);
CREATE TABLE countries (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL
);
CREATE TABLE towns (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
country_id INT NOT NULL,
CONSTRAINT fk_towns_countries
FOREIGN KEY (country_id)
REFERENCES countries(id)
);
CREATE TABLE stadiums (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
capacity INT NOT NULL,
town_id INT NOT NULL,
CONSTRAINT fk_stadiums_towns
FOREIGN KEY (town_id)
REFERENCES towns(id)
);
CREATE TABLE teams (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
established DATE NOT NULL,
fan_base BIGINT NOT NULL DEFAULT 0,
stadium_id INT NOT NULL,
CONSTRAINT fk_teams_stadiums
FOREIGN KEY (stadium_id)
REFERENCES stadiums(id)
);
CREATE TABLE players (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
age INT NOT NULL DEFAULT 0,
`position` CHAR(1) NOT NULL,
salary DECIMAL(10,2) NOT NULL DEFAULT 0,
hire_date DATETIME,
skills_data_id INT NOT NULL,
team_id INT,
CONSTRAINT fk_players_skills_data
FOREIGN KEY (skills_data_id)
REFERENCES skills_data(id),
CONSTRAINT fk_players_teams
FOREIGN KEY (team_id)
REFERENCES teams(id)
);
CREATE TABLE players_coaches (
player_id INT NOT NULL,
coach_id INT NOT NULL,
PRIMARY KEY (player_id, coach_id),
CONSTRAINT fk_players_coaches_players
FOREIGN KEY (player_id)
REFERENCES players(id),
CONSTRAINT fk_players_coaches_coaches
FOREIGN KEY (coach_id)
REFERENCES coaches(id)
);

# 2.	Insert
INSERT INTO coaches(first_name, last_name, salary, coach_level)
SELECT first_name, last_name, salary * 2, char_length(first_name)
FROM players
WHERE age >= 45;

# 3.	Update
UPDATE coaches AS co
JOIN players_coaches AS pc
ON pc.coach_id = co.id
JOIN players AS p
ON p.id = pc.player_id
SET coach_level = coach_level + 1
WHERE co.first_name LIKE 'A%';

# 4.	Delete
DELETE FROM players WHERE age >= 45;

# 5.	Players 
SELECT first_name, age, salary
FROM players
ORDER BY salary DESC;

# 6.	Young offense players without contract
SELECT p.id, concat(first_name, ' ', last_name) AS 'full_name',
age, `position`, hire_date 
FROM players AS p
JOIN skills_data AS sd
ON sd.id = p.skills_data_id
WHERE age < 23 AND `position` = 'A'
AND hire_date IS NULL AND strength > 50
ORDER BY salary, age;

# 7.	Detail info for all teams
SELECT t.`name` AS 'team_name', t.established AS 'established', 
t.fan_base AS 'fan_base', count(p.id) AS 'player_count'
FROM teams AS t
LEFT JOIN players AS p
ON p.team_id = t.id
GROUP BY team_name, established, fan_base
ORDER BY player_count DESC, fan_base DESC;

# 8.	The fastest player by towns
SELECT max(speed) AS 'max_speed', t.`name` AS 'town_name'
FROM towns AS t
LEFT JOIN stadiums AS s
ON s.town_id = t.id
LEFT JOIN teams
ON teams.stadium_id = s.id
LEFT JOIN players AS p
ON p.team_id = teams.id
LEFT JOIN skills_data AS sd
ON sd.id = p.skills_data_id
WHERE teams.`name` NOT IN ('Devify')
GROUP BY town_name
ORDER BY max_speed DESC, town_name;

# 9.	Total salaries and players by country
SELECT c.`name` AS 'name', count(p.id) AS 'total_count_of_players',
sum(p.salary) AS 'total_sum_of_salaries'
FROM countries AS c
LEFT JOIN towns AS t
ON t.country_id = c.id
LEFT JOIN stadiums AS s
ON s.town_id = t.id
LEFT JOIN teams
ON teams.stadium_id = s.id
LEFT JOIN players AS p
ON p.team_id = teams.id
GROUP BY `name`
ORDER BY total_count_of_players DESC, `name`;

# 10.	Find all players that play on stadium
DELIMITER //
CREATE FUNCTION udf_stadium_players_count(stadium_name VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (
    SELECT count(p.id) AS 'count'
    FROM stadiums AS s
    LEFT JOIN teams AS t
    ON t.stadium_id = s.id
    LEFT JOIN players AS p
    ON p.team_id = t.id
    WHERE s.`name` = stadium_name
    GROUP BY s.id
    );
END //
DELIMITER ;

# 11.	Find good playmaker by teams
DELIMITER //
CREATE PROCEDURE udp_find_playmaker(min_dribble_points INT, team_name_desired VARCHAR(45))
BEGIN
	SELECT concat(p.first_name, ' ', p.last_name) AS 'full_name',
    p.age, p.salary, sd.dribbling, sd.speed, t.`name` AS 'team_name'
    FROM players AS p
    JOIN teams AS t
    ON t.id = p.team_id
    JOIN skills_data AS sd
    ON sd.id = p.skills_data_id
    WHERE t.`name` = team_name_desired
    AND sd.dribbling > min_dribble_points
    AND sd.speed > (SELECT avg(speed) FROM skills_data)
    ORDER BY speed DESC
    LIMIT 1;
END //
DELIMITER ;