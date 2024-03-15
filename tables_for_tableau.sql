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

-- introducing columns with running total of people and tables. this table was exported to csv
SELECT 	*, 
		sum(no_people) over(ROWS BETWEEN unbounded PRECEDING AND CURRENT row) as people_accumulated,
		sum(tables) over(ROWS BETWEEN unbounded PRECEDING AND CURRENT row) as tables_occupied
FROM(

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

--order_revenue_per_type (export to csv)
select 	name,
		orders_per_type,
		round(orders_per_type /sum(orders_per_type) over() * 100, 2) as percent_of_total_orders,
		revenue_per_type,
		round(revenue_per_type /sum(revenue_per_type) over() * 100, 2) as percent_of_total_sales
from (
	select 	name,
			sum(quantity) as orders_per_type,
			sum(price) as revenue_per_type
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

--calculating amount of each order
with order_details_prices as
	(select *
	from test.order_details od 
	join 
	(select pizza_id,
			pizza_type_id,
			size,
			round(price::decimal, 2) as price
	from test.pizzas p)
	using (pizza_id)
	)
select 	order_id,
		sum(quantity) as pizza_count,
		sum(quantity * price) as order_amount
from order_details_prices
group by order_id
order by order_id

--table with average revenue and number of pizzas per weekday comparaed with annual average (revenue and number of pizzas per day)
select 	day,
		avg_per_dow,
		avg(avg_per_dow) over() as avg_pizzas,
		avg_rev_per_dow,
		avg(avg_rev_per_dow) over() as avg_revenue
from (
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
				using (order_id)
			)
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
				using (order_id)
			)
		group by date, day
		)
	group by day)
	using (day)
