-- Assignment - 1
	-- To give the baisc idea of the database and touches the basic of SQL
-- 1.	Give the top 10 movies with the longest run times (just movies & runtimes)
select
	title, length
from film
order by length desc -- default order by is always ascending order
limit 10 ; -- limit function gets the top n records from the output of a query

-- 2.	Can you get me the list of movies released in years other than 2006 and has a replacement cost of >$20?
select
	title
from film
where release_year <> 2006
and replacement_cost > 20;

-- 3.	How many movies does each category contain and what is the average rental rate of each category?
select
	category, 
    count(film_id) as num_films, 
    avg(rental_rate) as avg_rental_rate
from film
group by category -- Tip: make sure the level of aggregation and the 
-- level of the data matches to execute a query without errors
order by 2 desc;

-- 4.	In the above, subset the list to only categories where average rental rate is >$3?
select
	category, 
    count(film_id) as num_films, 
    avg(rental_rate) as avg_rental_rate
from film
group by category
having avg_rental_rate > 3; 
-- having is used to work on the columns that are created in the processing executing the query

-- 5.	To find a pattern of wildcard characters for 
-- e.g., (say column name: genre) the genre of the movie is 100%comedy. Write a query to find the “100%” pattern
select
	category
from film 
where category like '%100\%%';
-- learn more about like function on: https://www.w3schools.com/sql/sql_ref_like.asp

-- 6.	List the movies which is not present in “documentary” category
select
	title, category
from film
where category != 'Documentary';