-- below exercises are using standard sakila database. 
-- In order to check table relationships and definitions of table fields, use reverse engineer option in mysql workbench under menu tab ‘database’ --

-- or use below sql code if just want to check the tabel relationships--
SELECT 
`TABLE_NAME`, 
`COLUMN_NAME`, 
`REFERENCED_TABLE_NAME`, 
`REFERENCED_COLUMN_NAME` 
FROM `information_schema`.`KEY_COLUMN_USAGE` 
WHERE `CONSTRAINT_SCHEMA` = 'sakila' AND 
`REFERENCED_TABLE_SCHEMA` IS NOT NULL AND 
`REFERENCED_TABLE_NAME` IS NOT NULL AND 
`REFERENCED_COLUMN_NAME` IS NOT NULL ;

-- Start -- 
use sakila;

-- Display first and last nameof all actors --
select first_name, last_name
from actor;

-- display first and last name of each actor in a single column in upper case --
select upper(concat(first_name,' ', last_name)) as 'Actor Name'
from actor;

-- find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe. --
select actor_id, first_name, last_name from actor
where first_name = 'Joe'

-- Find all actors whose last name contain the letters GEN: --
select first_name, last_name from actor
WHERE INSTR(last_name, 'GEN') > 0 ; 
-- or --
select first_name, last_name from actor
WHERE last_name LIKE  '%GEN%'; 

-- Find all actors whose last names contain the letters LI. order the rows by last name and first name, in that order --
select last_name, first_name from actor
WHERE last_name LIKE  '%LI%'; 

-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China --
select country_id, country from country 
where country in ('Afghanistan', 'Bangladesh', 'China');

alter table actor add column (
description BLOB
);

-- List the last names of actors, as well as how many actors have that last name. --
select last_name, count(last_name) from actor
group by last_name

-- List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors --
select last_name, count(last_name) from actor
group by last_name
having count(last_name) >1;

-- HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. fix it --

UPDATE actor 
SET 
    first_name = 'HARPO',
    last_name  = 'WILLIAMS'
WHERE
    first_name = 'GROUCHO' and last_name = 'WILLIAMS';
    
    select * from actor where first_name = 'HARPO';
    
    
    -- revert above change --
    UPDATE actor 
SET 
    first_name = 'GROUCHO',
    last_name  = 'WILLIAMS'
WHERE
    first_name = 'HARPO' and last_name = 'WILLIAMS';
    
    -- check schema of address table -- 
    SHOW CREATE TABLE address;
    
  -- address of staff members --
SELECT 
    address.address, staff.first_name, staff.Last_name
FROM
    staff
        JOIN
    address ON staff.address_id = address.address_id;
    
    --  display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. --
    
    select concat(staff.first_name, ' ', staff.last_name) as Staff_Name, sum(payment.amount) as amount_rung_up
    from staff
    join payment
    group by concat(staff.first_name, ' ', staff.last_name)
    
    -- List each film and the number of actors who are listed for that film. Use tables film_actor and film --
    
    select film.title as film_name, count( distinct film_actor.actor_id) as no_of_actors
    from film
    join film_actor
    using (film_id)
    group by film.title;
    
    -- How many copies of the film Hunchback Impossible exist in the inventory system? --
    
use sakila;
    select film.title, count(i.film_id) as copies_in_inventory
    from inventory as i
    join film 
    using (film_id)
    where i.film_id = (
    select film.film_id from film where film.title = 'Hunchback Impossible'
    );

-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name --


select customer.last_name, customer.first_name, sum(payment.amount)
from customer 
join payment 
using (customer_id)
group by customer.last_name
order by customer.last_name limit 5;

/* The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. 
*/

select title as `Film Name`
from film
where (title like 'Q%' or title like 'K%') 
	and (language_id in 
		(select language_id from language where name = 'English' ))
limit 10
;

/* Sample example for nested subqueries
SELECT COUNT(*)
 FROM customer
 WHERE customer_id IN
 (
  SELECT customer_id
  FROM payment
  WHERE rental_id IN
  (
   SELECT rental_id
   FROM rental
   WHERE inventory_id IN
   (
    SELECT inventory_id
    FROM inventory
    WHERE film_id IN
    (
     SELECT film_id
     FROM film
     WHERE title = 'Blanket Beverly'
    )
   )
  )
 );
*/

--  Use subqueries to display all actors who appear in the film Alone Trip --

select first_name, last_name 
from actor
	where actor_id in 
		(select actor_id 
		from film_actor
		where film_id in
				(select film_id 
				from film 
				where title = 'Alone Trip'
				)
		); 
        
    
/* 
You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
Use joins to retrieve this information.
*/

select c.first_name, c.last_name, c.email
from customer as c
join address using (address_id)
join city using (city_id)
join country using(country_id) 
where country.country = 'canada';

/*
Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films
*/

select f.title as `Film Name`, cat.name as Category
from film as f
join film_category fc using (film_id)
join category cat using (category_id)
where cat.name like 'family%'

-- Display the most frequently rented movies in descending order. --

select f.title, count(r.inventory_id) times_rented from 
rental as r
join inventory i using(inventory_id)
join film f using(film_id)
group by f.title
order by times_rented desc;

-- Write a query to display how much business, in dollars, each store brought in. --

select concat(ad.address,' ',city.city, ' ',  ad.district,' ', country.country ) as Store, sum(payment.amount) as `Amount($)`
from payment
join rental using(rental_id)
join staff on staff.staff_id= rental.staff_id
join store using (store_id)
join address ad on store.address_id = ad.address_id
join city using (city_id) 
join country using(country_id)
group by Store;  
 
-- Write a query to display for each store its store ID, city, and country.--


select store.store_id as `Store ID`, city.city as `City Name`, country.country as `Country Name`
from store 
join address using (address_id) 
join city using(city_id)
join country using (country_id);

-- List the top five genres in gross revenue in descending order, create a view --

CREATE VIEW top_5_genres AS
    SELECT 
        category.name AS Genre, SUM(payment.amount) AS `Sale($)`
    FROM
        payment
            JOIN
        rental USING (rental_id)
            JOIN
        inventory USING (inventory_id)
            JOIN
        film_category USING (film_id)
            JOIN
        category USING (category_id)
    GROUP BY Genre
    ORDER BY `Sale($)`
    LIMIT 5; 


-- displaying the view 'top_5_genres' --
SELECT * FROM top_5_genres;
 -- dropping the view 'top_5_genres' --
 drop view top_5_genres;


