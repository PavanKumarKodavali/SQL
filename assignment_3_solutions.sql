-- Assignment - 3

-- 1. What were the categories with the highest and lowest revenues?
(
select
	f.category,
    sum(amount + coalesce(tax,0)) as revenue
from film as f
inner join rental as r
	on f.film_id = r.film_id
group by 1
order by 2 desc
limit 1
)
union
(
select
	f.category,
    sum(amount + coalesce(tax,0)) as revenue
from film as f
inner join rental as r
	on f.film_id = r.film_id
group by 1
order by 2
limit 1
);

-- with cte
with cte_1 as (
select
	f.category,
    sum(amount + coalesce(tax,0)) as revenue
from film as f
inner join rental as r
	on f.film_id = r.film_id
group by 1
)
select
	category,
    revenue
from cte_1
where revenue in (select max(revenue) from cte_1)
union
select
	category,
    revenue
from cte_1
where revenue in (select min(revenue) from cte_1)
;



-- 2. What movies did Marilyn Ross rent in July
with film_id_cte as 
(
select
		distinct r.film_id
from customer as c
inner join rental as r
	on c.customer_id = r.customer_id
where c.first_name = 'Marilyn' and c.last_name = 'Ross'
and month(rental_date) = 07
)

select
	f.film_id,
    f.title
from film as f
where f.film_id in (select distinct film_id from film_id_cte)
order by film_id;

-- 3. For all the films in the inventory, give the number of times they were rented
with film_count_cte as
(
	select
		film_id,
        count(film_id) as rents
    from rental
    group by 1
    order by 1
)

select
	f.title,
    r.rents
from film_count_cte as r
right join film as f
	on r.film_id = f.film_id
order by rents;

-- 4. How many customers have not rented any movie in the month of june (give two solutions - with and without joins)
-- without joins
select
	customer_id,
    concat(c.first_name,' ',c.last_name) as customer_name
from customer c
where customer_id not in (select distinct customer_id from rental where month(rental_date) = 06);

-- with joins
select
	c.customer_id,
    r.customer_id,
    concat(c.first_name,' ',c.last_name) as customer_name
from customer c
left join rental r
	on c.customer_id = r.customer_id
	and month(rental_date) = 06
where r.customer_id is null;

-- 5. who are the customers who have rented the same movie twice and which movie was it for each of them
with twice_rents_cte as 
(
select
	customer_id,
    film_id,
    count(film_id) as rents
from rental
group by 1,2
having rents = 2
order by customer_id
)

select
	c.customer_id,
    f.film_id,
	concat(c.first_name,' ',c.last_name) as customer_name,
    f.title,
    t.rents
from twice_rents_cte as t
inner join customer as c
	on t.customer_id = c.customer_id
inner join film as f
	on t.film_id = f.film_id
order by c.customer_id;

-- 6. How many customers in Jul 2005 were new customers & what % of the sale of the month was contributed by them?
/* 
Explanation: 
		step-1: Find the customers who never made purchase prior Jul 2005 --> new customers
			sub-step-1: Select only the customers who have a rental data as Jul-2005 and exclude the customers
						with rental data < Jul-2005
        step-2: Get the total sales in Jul 2005 --> total july sales for the year 2005
*/
with cte_1 as
(
select
	customer_id,
    sum(amount + coalesce(tax,0)) as sale
from rental
where month(rental_date) = 7 and year(rental_date) = 2005
and customer_id not in 
(
select
	distinct customer_id
from rental
where month(rental_date) <= 6 and year(rental_date) <= 2005
)
group by 1
)

select 
	customer_id, 
    sale, 
    (sale/t.sale_7)*100 as '% of Sales' from cte_1 
    join (select 
					sum(amount + coalesce(tax,0)) as sale_7 
				from rental 
                where month(rental_date) = 7 and year(rental_date) = 2005
                ) as t ;


-- 7.	Which movie(s) has been rented more than once by most customers?
/*
Note that it's not the movies that were rented by custmers more than once. Instead, if a movie was rented by a customer
more than once, which movie is it that have more number of such customers.
*/

with cte as (
select 
	film_id,
    customer_id
    -- count(distinct rental_id) as 'num_of_times_rented'
from rental
group by 1,2
having count(distinct rental_id) > 1
order by 1,2
)

select
	t.film_id,
    f.title,
    t.num_of_customers
from 
(
select
	film_id,
    count(distinct customer_id) as 'num_of_customers',
    rank() over (order by count(distinct customer_id) desc) as r
from cte
group by 1
order by 2 desc
) as t
inner join 
	film f 
    on t.film_id = f.film_id
where r = 1;

-- 8.	Give the list of movies that brought in more revenue than the average revenue in their respective categories? 
-- What share of the corresponding category’s revenue was contributed by each of these movies?(Round off the ratio to 2 decimals)

with cat_avg_rev as
(
select
	f.category,
    avg(r.amount + coalesce(tax,0)) as avg_cat_rev
from rental as r
inner join  film as f
	on r.film_id = f.film_id
group by 1
)