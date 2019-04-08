USE sakila;

-- 1a --
SELECT first_name, last_name 
FROM actor;

-- 1b --
SELECT CONCAT(first_name, " ",last_name) AS 'Actor Name' 
FROM actor;

-- 2a --
SELECT actor_id, first_name, last_name 
FROM actor 
WHERE first_name='Joe';

-- 2b --
SELECT actor_id, first_name, last_name 
FROM actor 
WHERE first_name LIKE '%gen%' OR last_name LIKE '%gen%';

-- 2c --
SELECT actor_id, first_name, last_name 
FROM actor 
WHERE first_name LIKE '%LI%' OR last_name LIKE '%LI%'
ORDER BY 3,2;

-- 2d --
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a --
ALTER TABLE actor
ADD description BLOB;

-- 3b --
ALTER TABLE actor
DROP COLUMN description;

-- 4a --
SELECT last_name, COUNT(last_name) AS name_count
FROM actor
GROUP BY 1;

-- 4b --
SELECT last_name, COUNT(last_name) AS name_count
FROM actor
GROUP BY 1
HAVING name_count>1;

-- 4c --
UPDATE actor
SET first_name = "HARPO"
WHERE first_name="GROUCHO" and last_name="WILLIAMS";

-- 4d --
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name="HARPO" and last_name="WILLIAMS";

-- 5a --
SHOW CREATE TABLE address;

-- 6a --
SELECT a.first_name, a.last_name, b.address
FROM staff AS a
LEFT JOIN address AS b
USING (address_id);

-- 6b --
SELECT a.staff_id, a.first_name, a.last_name, SUM(b.amount) AS total_amount_rung_up
FROM staff AS a
LEFT JOIN payment AS b
USING (staff_id)
WHERE b.payment_date BETWEEN '2005-08-01 00:00:00' AND '2005-09-01 00:00:00' 
GROUP BY 1,2,3;

-- 6c --
SELECT a.title, COUNT(b.actor_id) AS actor_count
FROM film AS a
INNER JOIN film_actor AS b
USING (film_id)
GROUP BY 1;

-- 6d --
SELECT COUNT(a.film_id) AS inventory_count, b.title
FROM inventory AS a
INNER JOIN film AS b
USING (film_id)
WHERE b.title = "Hunchback Impossible"
GROUP BY 2;

-- 6e --
SELECT a.first_name, a.last_name, sum(b.amount) as total_amount_paid
FROM Customer AS a
LEFT JOIN payment AS b
USING (customer_id)
GROUP BY 2,1
ORDER BY 2,1;

-- 7a --
SELECT title
FROM film
WHERE (title LIKE 'k%' OR title LIKE 'q%') 
AND language_id IN (SELECT language_id FROM language WHERE name="English");

-- 7b --
SELECT first_name, last_name
FROM actor
WHERE actor_id IN 
(SELECT actor_id FROM film_actor WHERE film_id IN 
(SELECT film_id FROM film WHERE title = 'Alone Trip'))
ORDER BY 2;

-- 7c --
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN 
(SELECT address_id FROM address WHERE city_id IN
(SELECT city_id FROM city WHERE country_id IN
(SELECT country_id FROM country WHERE country='Canada')))
ORDER BY 2,1,3;

-- 7d --
SELECT a.title 
FROM film as a
INNER JOIN film_category as b
USING (film_id)
WHERE b.category_id IN 
(SELECT category_id FROM category WHERE name= "family");

-- 7e --
SELECT b.title, count(c.rental_id) AS rental_count
FROM inventory AS a
INNER JOIN film AS b
USING (film_id)
INNER JOIN rental AS c
USING (inventory_id)
GROUP BY 1
ORDER BY 2 DESC;

-- 7f --
SELECT store, total_sales
FROM sales_by_store;

-- 7g --
SELECT SID as 'store id', city, country
FROM staff_list;

-- 7h --
SELECT b.name as film_type, sum(c.amount)
FROM film_category AS a
INNER JOIN category AS b
USING (category_id)
INNER JOIN 
	(SELECT sum(e.amount) AS amount, f.film_id
	FROM rental AS d
	INNER JOIN
	payment AS e
	USING(rental_id)
    INNER JOIN inventory as f
    USING (inventory_id)
	GROUP BY 2) AS c
USING (film_id)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 8a --
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `sakila`.`top_sales_by_genre` AS
    SELECT 
        `b`.`name` AS `film_type`,
        SUM(`c`.`amount`) AS `total_sales`
    FROM
        ((`sakila`.`film_category` `a`
        JOIN `sakila`.`category` `b` ON ((`a`.`category_id` = `b`.`category_id`)))
        JOIN (SELECT 
            SUM(`e`.`amount`) AS `amount`, `f`.`film_id` AS `film_id`
        FROM
            ((`sakila`.`rental` `d`
        JOIN `sakila`.`payment` `e` ON ((`d`.`rental_id` = `e`.`rental_id`)))
        JOIN `sakila`.`inventory` `f` ON ((`d`.`inventory_id` = `f`.`inventory_id`)))
        GROUP BY `f`.`film_id`) `c` ON ((`a`.`film_id` = `c`.`film_id`)))
    GROUP BY `b`.`name`
    ORDER BY SUM(`c`.`amount`) DESC
    LIMIT 5;
    
-- 8b --
SELECT film_type, total_sales
FROM top_sales_by_genre;

-- 8c --
DROP VIEW top_sales_by_genre;

    