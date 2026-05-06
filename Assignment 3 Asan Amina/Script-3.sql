
WITH new_movies AS (
    SELECT
        'White Chicks' AS title,
        'In New York City, FBI agent brothers Marcus Anthony II and Kevin Copeland inadvertently ruin a drug bust' ||
        ' Their boss, Chief Elliott Gordon, offers them a reprieve if they safely escort sisters Brittany and Tiffany Wilson - the rich,' ||
        'shallow socialite daughters of Wilson Cruiseliners CEO Andrew Wilson, who the police suspect will become the next victims in a string of high-profile kidnappings - to a weekend-long fashion event in the Hamptons.' AS description,
        2004 AS release_year,
        (
        SELECT
            l.language_id
        FROM
            public."language" l
        WHERE
            lower( l."name") = 'english') AS language_id,
        7 AS rental_duration,
        4.99 AS rental_rate,
        110 AS "length",
        'PG-13'::mpaa_rating AS rating
    UNION ALL
    SELECT
        'Spider-Man: Far from Home' AS title,
        'Peter Parker, the beloved superhero Spider-Man, faces four destructive elemental monsters while on holiday in Europe.' ||
        ' Soon, he receives help from Mysterio, a fellow hero with mysterious origins.' AS description,
        2019 AS release_year,
        (
        SELECT l.language_id FROM public."language" l
        WHERE
            lower( l."name") = 'english') AS language_id,
        14 AS rental_duration,
        9.99 AS rental_rate,
        120 AS "length",
        'PG-13'::mpaa_rating AS rating
    UNION ALL
    SELECT
        'Crime City' AS title,
        ' In 2004, in Seoul Chinatown, known for its high crime rate, three ruthless migrant collectors make their presence' ||
        'known by killing the head of one of the criminal gangs instead of simply demanding money from debtors.' AS description,
        2017 AS release_year,
        (SELECT l.language_id FROM public."language" l WHERE lower( l."name") = 'english') AS language_id,
        21 AS rental_duration,
        19.99 AS rental_rate,
        121 AS "length",
        'R'::mpaa_rating AS rating
        
), --CTE FOR inserting movies that defined in previous CTE with checking on existing in database
inserted_movies AS (
    INSERT INTO public.film
        (title,
        description,
        release_year,
        language_id,
        rental_duration,
        rental_rate,
        "length",
        rating,
        last_update)
    SELECT 
        nm.title,
        nm.description,
        nm.release_year,
        nm.language_id,
        nm.rental_duration,
        nm.rental_rate,
        nm."length",
        nm.rating,
        current_date AS last_update
    FROM
        new_movies nm
    WHERE NOT EXISTS (SELECT * FROM  public.film f WHERE f.title = nm.title AND f.release_year = nm.release_year)
    RETURNING film_id, title, release_year, rental_duration, rental_rate, last_update
)
SELECT film_id, title, release_year, rental_duration, rental_rate, last_update FROM inserted_movies;

--Insert (ACTOR)

INSERT INTO actor (first_name, last_name, last_update)
SELECT 'Shawn', 'Wayans', CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM actor 
    WHERE first_name = 'Shawn' AND last_name = 'Wayans'
);

INSERT INTO actor (first_name, last_name, last_update)
SELECT 'Tom', 'Holland', CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM actor 
    WHERE first_name = 'Tom' AND last_name = 'Holland'
);

INSERT INTO actor (first_name, last_name, last_update)
SELECT 'Ma', 'Dong-seok', CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM actor 
    WHERE first_name = 'Ma' AND last_name = 'Dong-seok'
);

--Task 2 - Insert film actors

INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT a.actor_id, f.film_id, CURRENT_DATE
FROM actor a
JOIN film f ON f.title = 'White Chicks'
WHERE a.first_name = 'Shawn'
  AND a.last_name  = 'Wayans'
ON CONFLICT DO NOTHING;

INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT a.actor_id, f.film_id, CURRENT_DATE
FROM actor a
JOIN film f ON f.title = 'Spider-Man: Far from Home'
WHERE a.first_name = 'Tom'
  AND a.last_name  = 'Holland'
ON CONFLICT DO NOTHING;

INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT a.actor_id, f.film_id, CURRENT_DATE
FROM actor a
JOIN film f ON f.title = 'Crime City'
WHERE a.first_name = 'Ma'
  AND a.last_name  = 'Dong-seok'
ON CONFLICT DO NOTHING;

-- Task 2b — Link actors to films

-- White Chicks → Shawn Wayans
INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT a.actor_id, f.film_id, CURRENT_DATE
FROM actor a
JOIN film f ON f.title = 'White Chicks'
WHERE a.first_name = 'Shawn'
  AND a.last_name  = 'Wayans'
ON CONFLICT DO NOTHING;

-- Spider-Man → Tom Holland
INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT a.actor_id, f.film_id, CURRENT_DATE
FROM actor a
JOIN film f ON f.title = 'Spider-Man: Far from Home'
WHERE a.first_name = 'Tom'
  AND a.last_name  = 'Holland'
ON CONFLICT DO NOTHING;

-- Crime City → Ma Dong-seok
INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT a.actor_id, f.film_id, CURRENT_DATE
FROM actor a
JOIN film f ON f.title = 'Crime City'
WHERE a.first_name = 'Ma'
  AND a.last_name  = 'Dong-seok'
ON CONFLICT DO NOTHING;

--CHECK 
SELECT f.title, a.first_name, a.last_name
FROM film_actor fa
JOIN film f USING (film_id)
JOIN actor a USING (actor_id)
WHERE f.title IN ('White Chicks','Spider-Man: Far from Home','Crime City')
ORDER BY f.title;


--===========
--Task 3. Add films to inventory 


INSERT INTO inventory (film_id, store_id, last_update)
SELECT 
    (SELECT film_id FROM film WHERE title = 'White Chicks'),
    (SELECT store_id FROM store ORDER BY store_id LIMIT 1),
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM inventory
    WHERE film_id = (SELECT film_id FROM film WHERE title = 'White Chicks')
      AND store_id = (SELECT store_id FROM store ORDER BY store_id LIMIT 1)
);

INSERT INTO inventory (film_id, store_id, last_update)
SELECT 
    (SELECT film_id FROM film WHERE title = 'Spider-Man: Far from Home'),
    (SELECT store_id FROM store ORDER BY store_id LIMIT 1),
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM inventory
    WHERE film_id = (SELECT film_id FROM film WHERE title = 'Spider-Man: Far from Home')
      AND store_id = (SELECT store_id FROM store ORDER BY store_id LIMIT 1)
);

INSERT INTO inventory (film_id, store_id, last_update)
SELECT 
    (SELECT film_id FROM film WHERE title = 'Crime City'),
    (SELECT store_id FROM store ORDER BY store_id LIMIT 1),
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM inventory
    WHERE film_id = (SELECT film_id FROM film WHERE title = 'Crime City')
      AND store_id = (SELECT store_id FROM store ORDER BY store_id LIMIT 1)
);


-- Before update 
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       COUNT(DISTINCT r.rental_id)  AS rental_count,
       COUNT(DISTINCT p.payment_id) AS payment_count
FROM customer c
JOIN rental  r ON c.customer_id = r.customer_id
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT r.rental_id)  >= 43
   AND COUNT(DISTINCT p.payment_id) >= 43
ORDER BY rental_count DESC;

-- Task 4 — Update customer
UPDATE customer
SET first_name='Amina',
    last_name='Asan',
    email='amina@example.com',
    address_id=(SELECT address_id FROM address ORDER BY address_id LIMIT 1),
    last_update=CURRENT_DATE
WHERE (first_name='ELEANOR' AND last_name='HUNT')
   OR (first_name='Amina' AND last_name='Asan');


-- Task 5 — Clean old records


-- Check first
SELECT * FROM payment
WHERE customer_id = (SELECT customer_id FROM customer WHERE first_name = 'Amina' AND last_name = 'Asan');

-- Then delete
DELETE FROM payment
WHERE customer_id = (SELECT customer_id FROM customer WHERE first_name = 'Amina' AND last_name = 'Asan');

SELECT * FROM rental
WHERE customer_id = (SELECT customer_id FROM customer WHERE first_name = 'Amina' AND last_name = 'Asan');

DELETE FROM rental
WHERE customer_id = (SELECT customer_id FROM customer WHERE first_name = 'Amina' AND last_name = 'Asan');


-- Task 6 — Rentals (WITH RETURNING)

INSERT INTO rental ( rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT '2017-01-15'::timestamp,
    ( SELECT i.inventory_id FROM inventory i JOIN film f USING (film_id) WHERE f.title = 'White Chicks' LIMIT 1),
    (SELECT customer_id FROM customer WHERE first_name = 'Amina' AND last_name = 'Asan'), '2017-01-15'::timestamp +
    (SELECT rental_duration FROM film WHERE title = 'White Chicks' ) * INTERVAL '1 day',
    ( SELECT staff_id FROM staff ORDER BY staff_id LIMIT 1),
    CURRENT_DATE
WHERE NOT EXISTS (
	SELECT 1 FROM rental
    WHERE rental_date = '2017-01-15'
      AND customer_id = (SELECT customer_id FROM customer WHERE first_name = 'Amina' AND last_name = 'Asan') )
RETURNING rental_id, rental_date, return_date;



INSERT INTO rental ( rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT '2017-02-10'::timestamp,
    ( SELECT i.inventory_id FROM inventory i JOIN film f USING (film_id) WHERE f.title = 'Spider-Man: Far from Home' LIMIT 1),
    (SELECT customer_id FROM customer WHERE first_name = 'Amina' AND last_name = 'Asan'), '2017-02-10'::timestamp +
    (SELECT rental_duration FROM film WHERE title = 'Spider-Man: Far from Home' ) * INTERVAL '1 day',
    ( SELECT staff_id FROM staff ORDER BY staff_id LIMIT 1),
    CURRENT_DATE
WHERE NOT EXISTS (
	SELECT 1 FROM rental
    WHERE rental_date = '2017-02-10'
      AND customer_id = (SELECT customer_id FROM customer WHERE first_name = 'Amina' AND last_name = 'Asan') )
RETURNING rental_id, rental_date, return_date;



INSERT INTO rental ( rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT '2017-03-05'::timestamp,
    ( SELECT i.inventory_id FROM inventory i JOIN film f USING (film_id) WHERE f.title = 'Crime City' LIMIT 1),
    (SELECT customer_id FROM customer WHERE first_name = 'Amina' AND last_name = 'Asan'), '2017-03-05'::timestamp +
    (SELECT rental_duration FROM film WHERE title = 'Crime City' ) * INTERVAL '1 day',
    ( SELECT staff_id FROM staff ORDER BY staff_id LIMIT 1),
    CURRENT_DATE
WHERE NOT EXISTS (
	SELECT 1 FROM rental
    WHERE rental_date = '2017-03-05'
      AND customer_id = (SELECT customer_id FROM customer WHERE first_name = 'Amina' AND last_name = 'Asan') )
RETURNING rental_id, rental_date, return_date;


--==================
-- Task 6b — Payment
--==================

INSERT INTO payment ( customer_id, staff_id, rental_id, amount,  payment_date)
SELECT c.customer_id, (SELECT staff_id FROM staff ORDER BY staff_id LIMIT 1),
       r.rental_id,  (SELECT rental_rate FROM film WHERE title = 'White Chicks'), '2017-01-15'::timestamp
FROM rental r
JOIN customer c ON r.customer_id = c.customer_id
WHERE c.first_name = 'Amina'
  AND c.last_name  = 'Asan'
  AND r.inventory_id = (SELECT i.inventory_id FROM inventory i JOIN film f USING (film_id)  WHERE f.title = 'White Chicks' LIMIT 1)
  AND NOT EXISTS (SELECT 1 FROM payment p WHERE p.rental_id = r.rental_id AND p.customer_id = c.customer_id);


INSERT INTO payment ( customer_id, staff_id, rental_id, amount,  payment_date)
SELECT c.customer_id, (SELECT staff_id FROM staff ORDER BY staff_id LIMIT 1),
       r.rental_id,  (SELECT rental_rate FROM film WHERE title = 'Spider-Man: Far from Home'), '2017-02-10'::timestamp
FROM rental r
JOIN customer c ON r.customer_id = c.customer_id
WHERE c.first_name = 'Amina'
  AND c.last_name  = 'Asan'
  AND r.inventory_id = (SELECT i.inventory_id FROM inventory i JOIN film f USING (film_id) WHERE f.title = 'Spider-Man: Far from Home' LIMIT 1)
  AND NOT EXISTS (SELECT 1 FROM payment p WHERE p.rental_id = r.rental_id AND p.customer_id = c.customer_id);

INSERT INTO payment ( customer_id, staff_id, rental_id, amount,  payment_date)
SELECT c.customer_id, (SELECT staff_id FROM staff ORDER BY staff_id LIMIT 1),
       r.rental_id,  (SELECT rental_rate FROM film WHERE title = 'Crime City'), '2017-03-05'::timestamp
FROM rental r
JOIN customer c ON r.customer_id = c.customer_id
WHERE c.first_name = 'Amina'
  AND c.last_name  = 'Asan'
  AND r.inventory_id = (SELECT i.inventory_id FROM inventory i JOIN film f USING (film_id) WHERE f.title = 'Crime City' LIMIT 1)
  AND NOT EXISTS (SELECT 1 FROM payment p WHERE p.rental_id = r.rental_id AND p.customer_id = c.customer_id);

--==============
-- VERIFICATION
--==============

SELECT 'film', COUNT(*) FROM film WHERE title IN ('White Chicks','Spider-Man: Far from Home','Crime City')
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory i JOIN film f USING(film_id)
WHERE f.title IN ('White Chicks','Spider-Man: Far from Home','Crime City')
UNION ALL
SELECT 'customer', COUNT(*) FROM customer WHERE first_name='Amina' AND last_name='Asan'
UNION ALL
SELECT 'rental', COUNT(*) FROM rental r JOIN customer c USING(customer_id)
WHERE c.first_name='Amina' AND c.last_name='Asan'
UNION ALL
SELECT 'payment', COUNT(*) FROM payment p JOIN customer c USING(customer_id)
WHERE c.first_name='Amina' AND c.last_name='Asan';
