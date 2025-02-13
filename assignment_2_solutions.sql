-- Assignment - 2
	-- Part-1: Questions related to Aggregates
-- 1. Give the top 3 categories for movies having the longest average runtime (Exclude movies with trailers)
select
	category, -- 1
    avg(length) as avg_lngst_run_time
from film
where special_features not like '%Trailers%' 
-- like function here excludes all the records which has Trailers (irrespective of the position) in special_features 
group by 1
order by 2 desc
limit 3;

-- 2. At what hour of the day is sales volume & revenue the highest? 
select
	hour(rental_date) as hour_of_the_day,
    count(film_id) as sales_vol,
    sum(coalesce(amount,0) + coalesce(tax,0)) as revenue
    -- the coalesce function replaces the null values with value of user's choice, here it's '0'
from rental
group by 1
order by 2 desc;

-- 3. Give me the count of movies by their length categories
-- 	  Short movies: <1hr
--    Mid length movies: 1-2hrs
--    Long movies: >2hrs
select
	case
		when length < 60 then "Short Movie"
        when length > 120 then "Long Movie"
        else "Medium Movie"
	end as movie_length_category,
    -- case when statement is used to implement conditions on a column
    -- learn more on: https://www.w3schools.com/sql/sql_case.asp
    count(film_id) as number_of_movies
from film 
group by 1
order by 2;

	-- Part-2: Questions related to sub-queries
-- 1. List the movies with the highest and lowest replacement costs (Just the movie & its corresponding replacement costs)
(
select
	title,
    replacement_cost
from film
order by 2 desc
limit 1
)
union
(
select
	title,
    replacement_cost
from film
order by 2 
limit 1
);
-- The issue with the above query is, if there are multiple entries with minimum and/or maximum replacement cost the records
-- from position 2 can't be seen in outuput
/* Try the below query to understand above statement
select
	title,
    replacement_cost
from film
where replacement_cost = 9.99 */

-- so we use sub-queries 
select
	title,
    replacement_cost
from film
where replacement_cost in
(
select
	min(replacement_cost)
from film
union
select
    max(replacement_cost)
from film
)
order by replacement_cost;

-- 2.	List all the movies that have a longer runtimes than the average runtime of the category with the highest average runtime.

select
	title,
    length
from film
where length >
(
select
	avg_run_time as max_run_time_cat
from
(
	select
		category,
		avg(length) as avg_run_time
	from film
	group by 1
	order by 2 desc
    limit 1
) as temp
);

/* Express the value as a ratio of the movie’s runtime to the said category and exclude movies falling 
under the said category from this list */

select
	f1.title, 
    f1.category,
    f1.length,
    f1.length/f2.max_avg_length as runtime_ratio
from film as f1
join (
select
	avg(length) as max_avg_length
from film
group by category
order by max_avg_length desc 
limit 1
) as f2

where 
	length > 
(
select
	avg(length) as avg_runtime
from film
group by category
order by avg_runtime desc 
limit 1
)
and
	category !=
(
select
	category
from
	(
	select
		category,
		avg(length) as avg_runtime
	from film
	group by category
	order by avg_runtime desc 
	limit 1
	) as temp
);
