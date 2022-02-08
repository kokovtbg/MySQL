# 1. Find Book Titles 
SELECT `title` FROM `books`
WHERE substring(`title`, 1, 3) = 'The';

# 2. Replace Titles
SELECT replace(`title`, 'The', '***')
FROM `books`
WHERE substring(`title`, 1, 3) = 'The';

# 3. Sum Cost of All Books
SELECT format(sum(`cost`), 2) FROM `books`;

# 4. Days Lived
SELECT concat(`first_name`, ' ', `last_name`) AS `Full Name`,
if(`died` = null, '(NULL)', timestampdiff(day, `born`, `died`)) 
AS `Days Lived` FROM `authors`;

# 5. Harry Potter Books
SELECT `title` FROM `books`
WHERE `title` LIKE 'Harry Potter%';   