--EDA AND KPIs

-- start_date for the dataset
select min(date) as start_date
from test.orders

-- end_date for the dataset
select max(date) as end_date
from test.orders


--total orders
select count(distinct order_id) as total_orders
from test.order_details od 

--the most and the least expensive pizza
select pizza_type_id, price
from test.pizzas p 
order by price

--total revenue
select sum(order_amount) as total_revenue
from(
	with order_details_prices as (
		select *
		from test.order_details od 
		join 
		(select pizza_id, pizza_type_id, size, round(price::decimal, 2) as price
		from test.pizzas p)
		using (pizza_id)
	)
	select 	order_id, 
			sum(quantity) as pizza_count, 
			sum(quantity * price) as order_amount
	from order_details_prices
	group by order_id
	order by order_id)

--total no of pizzas sold
select sum(pizza_count) as total_pizzas
from(
	with order_details_prices as (
		select *
		from test.order_details od 
		join 
		(select pizza_id, 
				pizza_type_id, size, 
				round(price::decimal, 2) as price
		from test.pizzas p)
		using (pizza_id)
	)
	select 	order_id, 
			sum(quantity) as pizza_count, 
			sum(quantity * price) as order_amount
	from order_details_prices
	group by order_id
	order by order_id)

--average, minimum and maximum cheque
select 	round(avg(order_amount), 2) as average_cheque, 
		min(order_amount) as min_cheque, 
		max(order_amount) as max_cheque
from(
	with order_details_prices as (
		select *
		from test.order_details od 
		join 
		(select pizza_id, pizza_type_id, size, round(price::decimal, 2) as price
		from test.pizzas p)
		using (pizza_id)
	)
	select 	order_id, 
			sum(quantity * price) as order_amount
	from order_details_prices
	group by order_id) t1

-- there are 32 types of pizza
select count(distinct name)
from test.pizza_types 

--BEST AND WORST-SELLING PIZZAS

-- highest and lowest revenue pizzas
select 	name, 
		sum(quantity) as total_ordered, 
		sum(price) as revenue_per_type
from (
	select *
	from test.order_details od 
	join 
	(select *
	from
	(select pizza_type_id, name
	from test.pizza_types pt )
	join 
	(select pizza_id, pizza_type_id, size, round(price::decimal, 2) as price
	from test.pizzas p)
	using (pizza_type_id))
	using (pizza_id)) t1
group by name
order by revenue_per_type desc 

-- highest and lowest number of sales

select 	name, 
		sum(quantity) as total_ordered
from
	(select *
	from test.order_details od 
	join 
	(select *
	from
	(select pizza_type_id, name
	from test.pizza_types pt )
	join 
	(select pizza_id, pizza_type_id, size, round(price::decimal, 2) as price
	from test.pizzas p)
	using (pizza_type_id))
	using (pizza_id)) t1
group by name
order by total_ordered desc 

--highest and lowest number of sales with % of total

select 	name, 
		orders_per_type, 
		round(orders_per_type /sum(orders_per_type) over() * 100, 2) as percent_of_total
from(
	select name, sum(quantity) as orders_per_type
	from (
		select *
		from test.order_details od 
		join 
		(select *
		from
		(select pizza_type_id, name
		from test.pizza_types pt )
		join 
		(select pizza_id, pizza_type_id, size, round(price::decimal, 2) as price
		from test.pizzas p)
		using (pizza_type_id))
		using (pizza_id)
		) t1
	group by name
	order by orders_per_type desc
	)

-- highest sale with % of total
select 	name, 
		revenue_per_type, 
		round(revenue_per_type /sum(revenue_per_type) over() * 100, 2) as percent_of_total_sales
from( 
	select name, sum(price) as revenue_per_type
	from(
		select *
		from test.order_details od 
		join 
		(select *
		from
		(select pizza_type_id, 
				name
		from test.pizza_types pt )
		join 
		(select pizza_id, 
				pizza_type_id, 
				size, 
				round(price::decimal, 2) as price
		from test.pizzas p)
		using (pizza_type_id))
		using (pizza_id)) t1
	group by name
	order by revenue_per_type desc
	)

--SALES TRENDS

--order_revenue_per_type 
select 	name, 
		orders_per_type, 
		round(orders_per_type /sum(orders_per_type) over() * 100, 2) as percent_of_total_orders,
		revenue_per_type, 
		round(revenue_per_type /sum(revenue_per_type) over() * 100, 2) as percent_of_total_sales
from (
	select name, sum(quantity) as orders_per_type, sum(price) as revenue_per_type
	from
		(select *
		from test.order_details od 
		join 
		(select *
		from
		(select pizza_type_id, 
				name
		from test.pizza_types pt )
		join 
		(select pizza_id, 
				pizza_type_id, 
				size, 
				round(price::decimal, 2) as price
		from test.pizzas p)
		using (pizza_type_id))
		using (pizza_id)) t1
	group by name
	order by orders_per_type desc
	)

-- pizzas count by days of the week
select 	round(avg(pizza_count)) avg_per_dow, 
		day
from(
	select 	sum(quantity) as pizza_count,  
			date, 
			day
	from(
		select 	order_id, 
				pizza_id, 
				order_details_id, 
				quantity, pizza_type_id, 
				size, 
				round(price::decimal, 2) as price, 
				date::date, 
				to_char(date::date, 'Dy') as day, 
				time::time
		from (
			select *
			from test.order_details od 
			join 
			(select *
			from test.pizzas p)
			using (pizza_id)) t1
			join 
			(select *
			from test.orders o)
			using (order_id)
		)
	group by date, day
	)
group by day

--pizzas revenue by day of week
select 	round(avg(revenue)) as avg_rev_per_dow,
		day
from(
	select 	sum(price) as revenue,
			date,
			day
	from(
		select 	order_id,
				pizza_id,
				order_details_id,
				quantity,
				pizza_type_id,
				size,
				round(price::decimal, 2) as price,
				date::date,
				to_char(date::date, 'Dy')
				as day,
				time::time
		from 
			(select *
			from test.order_details od 
			join 
			(select *
			from test.pizzas p)
			using (pizza_id)) t1
			join 
			(select *
			from test.orders o)
			using (order_id)
		)
	group by date, day
	)
group by day

--table with average revenue and number of pizzas per weekday comparaed with annual average (revenue and number of pizzas per day)
select 	day, 
		avg_per_dow,
		avg(avg_per_dow) over() as avg_pizzas, avg_rev_per_dow,
		avg(avg_rev_per_dow) over() as avg_revenue
from (
	select 	round(avg(pizza_count)) as avg_per_dow,
			day
	from(
		select 	sum(quantity) as pizza_count,  
				date, 
				day
		from(
			select 	order_id, 
					pizza_id,
					order_details_id,
					quantity,
					pizza_type_id,
					size,
					round(price::decimal, 2) as price,
					date::date,
					to_char(date::date, 'Dy') as day,
					time::time
			from 
				(select *
				from test.order_details od 
				join 
				(select *
				from test.pizzas p)
				using (pizza_id)) t1
				join 
				(select *
				from test.orders o)
				using (order_id))
		group by date, day
		)
	group by day
	)
	join 
	(select round(avg(revenue)) as avg_rev_per_dow, 
			day
	from(
		select 	sum(price) as revenue,
				date,
				day
		from(
			select order_id,
			pizza_id,
			order_details_id,
			quantity,
			pizza_type_id,
			size,
			round(price::decimal, 2) as price,
			date::date,
			to_char(date::date, 'Dy') as day,
			time::time
			from 
				(select *
				from test.order_details od 
				join 
				(select *
				from test.pizzas p)
				using (pizza_id)) t1
				join 
				(select *
				from test.orders o)
				using (order_id))
		group by date, day
		)
	group by day)
	using (day)

--order with amount by date and time
select 	order_id,
		sum(quantity) as no_pizzas,
		sum(price) as order_amount,
		date,
		hour
from (
	select order_id, pizza_id, order_details_id, quantity, pizza_type_id, size, 
			round(price::decimal, 2) as price, 
			date::date, to_char(date::date, 'Dy') as day, 
			time::time, 
			date_part('hour', time::time) as hour
	from 
		(select *
		from test.order_details od 
		join 
		(select *
		from test.pizzas p)
		using (pizza_id)) t1
		join 
		(select *
		from test.orders o)
		using (order_id)
	)
group by order_id, date, hour
order by no_pizzas desc 

--peak hours
select 	hour,
		sum(order_amount) as revenue
from (
	select 	order_id,
			sum(quantity) as no_pizzas,
			sum(price) as order_amount,
			date,
			hour
	from(
		select 	order_id, pizza_id, order_details_id, quantity, pizza_type_id, size, 
				round(price::decimal, 2) as price, 
				date::date, to_char(date::date, 'Dy') as day, 
				time::time, 
				date_part('hour', time::time) as hour
		from 
			(select *
			from test.order_details od 
			join 
			(select *
			from test.pizzas p)
			using (pizza_id)) t1
			join 
			(select *
			from test.orders o)
			using (order_id)
		)
	group by order_id, date, hour
	)
group by hour
order by revenue 


--orders by time during the day
select 	order_id,
		sum(quantity) as no_pizzas,
		sum(price) as order_amount,
		date,
		day,
		hour
from (
	select 	order_id,
			pizza_id,
			order_details_id,
			quantity,
			pizza_type_id,
			size, 
			round(price::decimal, 2) as price, 
			date::date,
			to_char(date::date, 'Dy') as day, 
			time::time, 
			date_part('hour', time::time) as hour
	from 
		(select *
		from test.order_details od 
		join 
		(select *
		from test.pizzas p)
		using (pizza_id)) t1
		join 
		(select *
		from test.orders o)
		using (order_id)
	)
group by order_id, date, day, hour

--the most frequent ingredients
select 	ingredient, 
		count(pizza_type_id) as frequency
from (
	select  pizza_type_id,
			unnest(string_to_array(ingredients, ',')) as ingredient
	from test.pizza_types pt
	)
group by ingredient
order by frequency desc

--OCCUPANCY AND TABLE CONFIGURATION ANALYSIS

--orders_start
create materialized view  test.orders_time_in   as
(select order_id, 
		sum(quantity) as people_in, 
		date, 
		date+time as date_time,
		time as time_in, 
		case 
			when sum(quantity) <= 4 then 1
			when   4< sum(quantity)  and sum(quantity) <= 8 then 2
			when   8< sum(quantity)  and sum(quantity) <= 12 then 3
			when   12< sum(quantity) and sum(quantity) <= 16 then 4
			when   16< sum(quantity) and sum(quantity) <= 20 then 5
			when   20< sum(quantity) and sum(quantity) <= 24 then 6
			when   24< sum(quantity) and sum(quantity) <= 28 then 7
		end as tables_in
		
		
from (
	select 	order_id,
			quantity,
			date::date,
			time::time
	from test.order_details
	join test.orders
	using(order_id)
	)
group by order_id, date, time)
with data

--orders_end

create materialized view  test.orders_time_out   as
(select order_id,  
		date_time_out::date as date_out, 
		date_time_out::time as time_out, 
		no_pizzas * (-1) AS people_out,
		tables_in * (-1) as tables_out
from (
	select order_id, sum(quantity) as no_pizzas, date, 
			date+time as date_time,
			time as time_in, 
			date + time + interval '1 hour' as date_time_out,
			case 
				when sum(quantity) <= 4 then 1
				when   4< sum(quantity)  and sum(quantity) <= 8 then 2
				when   8< sum(quantity)  and sum(quantity) <= 12 then 3
				when   12< sum(quantity) and sum(quantity) <= 16 then 4
				when   16< sum(quantity) and sum(quantity) <= 20 then 5
				when   20< sum(quantity) and sum(quantity) <= 24 then 6
				when   24< sum(quantity) and sum(quantity) <= 28 then 7
			end as tables_in
			
			
	from (
		select 	order_id,
				quantity,
				date::date,
				time::time
		from test.order_details
		join test.orders
		using(order_id))
group by order_id, date, time
		)
)
with data


-- uniting two tables with people and tables in and out

select 	order_id,
		people_in as no_people,
		date, time_in as time,
		tables_in as tables
from test.orders_time_in oti 

union all

select 	order_id,
		people_out as no_people,
		date_out as date,
		time_out as time,
		tables_out as tables
from test.orders_time_out oto 
order by date, time



-- introducing columns with running total of people and tables. this table was exported to csv
select *, 
	sum(no_people) over(ROWS BETWEEN unbounded PRECEDING AND CURRENT row) as people_accumulated,
	sum(tables) over(ROWS BETWEEN unbounded PRECEDING AND CURRENT row) as tables_occupied
from (

	select 	order_id,
			people_in as no_people,
			date, time_in as time,
			tables_in as tables
	from test.orders_time_in oti 
	
	union all
	
	select 
			order_id,
			people_out as no_people,
			date_out as date,
			time_out as time,
			tables_out as tables
	from test.orders_time_out oto 
	order by date, time
	)


--filter cases when there are more pople than the capacity of the cafe
select *
from (
select *, 
	sum(no_people) over(ROWS BETWEEN unbounded PRECEDING AND CURRENT row) as people_accumulated,
	sum(tables) over(ROWS BETWEEN unbounded PRECEDING AND CURRENT row) as tables_occupied
from(

	select 	order_id,
			people_in as no_people,
			date, time_in as time,
			tables_in as tables
	from test.orders_time_in oti 
	
	union all
	
	select 	order_id,
			people_out as no_people,
			date_out as date,
			time_out as time,
			tables_out as tables
	from test.orders_time_out oto 
	order by date, time
	)
)
where people_accumulated > 60

--filter cases when there are more tables required available in the cafe
select *
from (
	select 	*, 
			sum(no_people) over(ROWS BETWEEN unbounded PRECEDING AND CURRENT row) as people_accumulated,
			sum(tables) over(ROWS BETWEEN unbounded PRECEDING AND CURRENT row) as tables_occupied
	from(
	
		select 	order_id,
				people_in as no_people,
				date,
				time_in as time,
				tables_in as tables
		from test.orders_time_in oti 
		
		union all
		select 	order_id,
				people_out as no_people,
				date_out as date,
				time_out as time,
				tables_out as tables
		from test.orders_time_out oto 
		order by date, time
		)
	)
where tables_occupied > 15

