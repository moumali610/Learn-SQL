use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name, ' ', last_name) AS 'Actor Name' from actor;
   


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor
where first_name like 'Joe%';

-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id, first_name, last_name from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select actor_id, last_name, first_name from actor
where last_name like '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country IN ('Afghanistan', 'Bangladesh', 'China');




-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD middle_name text;
select actor_id, first_name, middle_name, last_name from actor;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor
modify middle_name blob;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor
Drop middle_name;
select * from actor;




-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) as Num_actor from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name) as Num_actor from actor
group by last_name
having(count(last_name)) >= 2;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS,
	--  the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.'
Update actor
set first_name = 'HARPO'
where actor_id = 172;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
	-- It turns out that GROUCHO was the correct name after all!
    -- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
    -- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
    -- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! 
    -- (Hint: update the record using a unique identifier.)

Update actor
set first_name = 'GROUCHO'
where actor_id = 172;



-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
	-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
select * from address;
SHOW CREATE TABLE address;



-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select * from staff;
select * from address;

select s.first_name, s.last_name, a.address
from address a
join staff s
on (a.address_id = s.address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select * from staff; -- s
select * from payment; -- p

select s.staff_id, s.first_name, s.last_name, sum(p.amount) AS Total_amount_processed, count(p.payment_date) as Aug2015
from payment p
join staff s
on (p.staff_id = s.staff_id)
where payment_date like '2005-08%'
group by staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select * from film_actor; -- fa
select * from film; -- f

select f.title, count(fa.actor_id) as NumActors
from film f 
join film_actor fa
on (f.film_id=fa.film_id)
group by title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select * from film; -- f
select * from inventory; -- i

select f.title, count(i.inventory_id) as Num_Copies 
from inventory i
join film f
on (f.film_id = i.film_id)
where f.title = 'HUNCHBACK IMPOSSIBLE';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
-- List the customers alphabetically by last name:
-- 	![Total amount paid](Images/total_payment.png)
select * from payment; -- p
select * from customer; -- c

select c.last_name, c.first_name, sum(p.amount) as Total_paid
from payment p
join customer c
on (p.customer_id = c.customer_id)
group by last_name, first_name;



-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
	-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
    -- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select * from film; -- f
select * from language; -- b

create view Eng_films as
select title
from film f 
where language_id in
(
select language_id
from language b
where language_id = '1'
);

select * from Eng_films
where title like 'K%'
or title like 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select * from actor;
select * from film;
select* from film_actor;

select a.first_name, a.last_name
from actor a
where a.actor_id IN 
(
select m.actor_id
from film_actor m
where m.film_id in
(
select f.film_id
 from film f 
 where f.title = 'Alone Trip'
 )
 );
 
-- 7c. You want to run an email marketing campaign in Canada, 
	-- for which you will need the names and email addresses of all Canadian customers. 
	-- Use joins to retrieve this information.
select * from customer; -- cus
select * from address; -- a
select * from city; -- c
select * from country; -- co

select co.country, cus.first_name, cus.last_name, cus.email
from customer cus
inner join address a 
on (cus.address_id=a.address_id)
inner join city c 
on (a.city_id=c.city_id)
inner join country co
on (c.country_id=co.country_id)
where country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
	-- Identify all movies categorized as famiy films.
select * from film; -- f 
select * from film_category; -- fic
select * from category; -- cat 

select f.title, cat.name as 'Category'
from film f
inner join film_category fic
on (f.film_id=fic.film_id)
inner join category cat
on (fic.category_id=cat.category_id)
where name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
select * from rental; -- r
select * from inventory; -- i 
select * from film; -- f

select f.title, count(r.inventory_id) as 'NumRented'
from rental r 
join inventory i
on (r.inventory_id=i.inventory_id)
join film f
on (i.film_id=f.film_id)
group by f.title
order by NumRented desc; 

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select * from store; -- so
select * from staff; -- st
select * from payment; -- p

select so.store_id, sum(p.amount) as 'TotalAmount' 
from store so
join staff st
on (so.store_id=st.store_id)
join payment p
on (st.staff_id=p.staff_id)
group by so.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select * from store; -- s
select * from address; -- a
select * from city; -- c
select * from country; -- co

select s.store_id, c.city, co.country
from store s
join address a
on (s.address_id=a.address_id)
join city c 
on (a.city_id=c.city_id)
join country co
on (c.country_id=co.country_id);

-- 7h. List the top five genres in gross revenue in descending order. 
	-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select * from category; -- c
select * from film_category; -- f 
select * from inventory; -- i
select * from rental; -- r
select * from payment; -- p

select c.name, sum(p.amount) as 'Gross Revenue ($)'
from category c
join film_category f 
on (c.category_id=f.category_id)
join inventory i 
on (f.film_id=i.film_id)
join rental r 
on (i.inventory_id=r.inventory_id)
join payment p 
on (r.rental_id=p.rental_id)
group by c.name
order by sum(p.amount) desc
LIMIT 5;



-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
	-- Use the solution from the problem above to create a view. 
	-- If you haven't solved 7h, you can substitute another query to create a view.
create view Top5_Grossing_Genres as
select c.name, sum(p.amount) as 'Gross Revenue ($)'
from category c
join film_category f 
on (c.category_id=f.category_id)
join inventory i 
on (f.film_id=i.film_id)
join rental r 
on (i.inventory_id=r.inventory_id)
join payment p 
on (r.rental_id=p.rental_id)
group by c.name
order by sum(p.amount) desc
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
select * from Top5_Grossing_Genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view Top5_Grossing_Genres;
