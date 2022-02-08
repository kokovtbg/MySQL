CREATE SCHEMA instd;
USE instd;

# 01.	Table Design
CREATE TABLE users (
id INT PRIMARY KEY,
username VARCHAR(30) NOT NULL UNIQUE,
`password` VARCHAR(30) NOT NULL,
email VARCHAR(50) NOT NULL,
gender CHAR(1) NOT NULL,
age INT NOT NULL,
job_title VARCHAR(40) NOT NULL,
ip VARCHAR(30) NOT NULL
);
CREATE TABLE addresses (
id INT PRIMARY KEY AUTO_INCREMENT,
address VARCHAR(30) NOT NULL,
town VARCHAR(30) NOT NULL,
country VARCHAR(30) NOT NULL,
user_id INT NOT NULL,
CONSTRAINT fk_addresses_users
FOREIGN KEY (user_id)
REFERENCES users(id)
);
CREATE TABLE photos (
id INT PRIMARY KEY AUTO_INCREMENT,
`description` TEXT NOT NULL,
`date` DATETIME NOT NULL,
views INT NOT NULL DEFAULT 0
);
CREATE TABLE comments (
id INT PRIMARY KEY AUTO_INCREMENT,
`comment` VARCHAR(255) NOT NULL,
`date` DATETIME NOT NULL,
photo_id INT NOT NULL,
CONSTRAINT fk_comments_photos
FOREIGN KEY (photo_id)
REFERENCES photos(id)
);
CREATE TABLE users_photos (
user_id INT NOT NULL,
photo_id INT NOT NULL,
CONSTRAINT fk_users_photos_users
FOREIGN KEY (user_id)
REFERENCES users(id),
CONSTRAINT fk_users_photos_photos
FOREIGN KEY (photo_id)
REFERENCES photos(id)
);
CREATE TABLE likes (
id INT PRIMARY KEY AUTO_INCREMENT,
photo_id INT,
user_id INT,
CONSTRAINT fk_likes_photos
FOREIGN KEY (photo_id)
REFERENCES photos(id),
CONSTRAINT fk_likes_users
FOREIGN KEY (user_id)
REFERENCES users(id)
);

# 02.	Insert
INSERT INTO addresses(address, town, country, user_id)
SELECT username, `password`, ip, age
FROM users
WHERE users.gender = 'M';

# 03.	Update
UPDATE addresses
SET country = 
CASE
WHEN country LIKE 'B%' THEN 'Blocked'
WHEN country LIKE 'T%' THEN 'Test'
WHEN country LIKE 'P%' THEN 'In Progress'
ELSE country
END
WHERE id BETWEEN 1 AND 100;

# 04.	Delete
DELETE FROM addresses
WHERE id % 3 = 0;

# 05.	Users
SELECT username, gender, age FROM users
ORDER BY age DESC, username;

# 06.	Extract 5 Most Commented Photos
SELECT p.id, p.`date`, p.`description`, count(c.id) AS 'commentsCount'
FROM photos AS p
JOIN comments AS c
ON c.photo_id = p.id
GROUP BY p.id
ORDER BY commentsCount DESC, p.id
LIMIT 5;

# 07.	Lucky Users
SELECT concat(u.id, ' ', u.username) AS 'id_username', email 
FROM users AS u
JOIN users_photos AS up
ON up.user_id = u.id
JOIN photos AS p
ON p.id = up.photo_id
WHERE u.id = p.id
ORDER BY u.id;

# 08.	Count Likes and Comments
SELECT p.id AS 'the_photo_id', count(l.id) AS 'likes_count', 
(SELECT count(com.id)
FROM photos AS ph
LEFT JOIN comments AS com
ON com.photo_id = ph.id
WHERE ph.id = p.id
GROUP BY ph.id) AS 'comments_count'
FROM photos AS p
LEFT JOIN likes AS l
ON l.photo_id = p.id
GROUP BY p.id
ORDER BY likes_count DESC, comments_count DESC, p.id;

# 09.	The Photo on the Tenth Day of the Month
SELECT concat(substring(`description`, 1, 30), '...') AS 'summary',
`date` 
FROM photos
WHERE day(`date`) = 10
ORDER BY `date` DESC;

# 10.	Get User’s Photos Count
DELIMITER //
CREATE FUNCTION udf_users_photos_count(username_desired VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (
    SELECT count(up.photo_id) FROM users AS u
    LEFT JOIN users_photos AS up
    ON up.user_id = u.id
    WHERE u.username = username_desired);
END //
DELIMITER ;

# 11.	Increase User Age
DELIMITER //
CREATE PROCEDURE udp_modify_user(address_desired VARCHAR(30), town_desired VARCHAR(30))
BEGIN
	UPDATE users AS u
    JOIN addresses AS a
    ON a.user_id = u.id
    SET age = age + 10
    WHERE a.address = address_desired
    AND a.town = town_desired;
END //
DELIMITER ;