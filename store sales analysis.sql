
-- Analyzing monthly sales and profit trends on a year-over-year basis--
with monthly_sales_trends as (
select 
	date_trunc('month', order_date) as year_month,
	sum(sales) as revenue,
	sum(profit) as profit
from non_returned_orders
left join orders 
	using(order_id)
group by date_trunc('month', order_date)
order by 1 asc
)
select -- finding running sales total and running profits total for each year --
	year_month,
	revenue,
	sum(revenue) over(partition by date_trunc('year',year_month)
				order by year_month
				rows between unbounded preceding and current row) as cumm_sales,
	profit,
	sum(profit) over(partition by date_trunc('year',year_month)
				order by year_month
				rows between unbounded preceding and current row) as cumm_profits
from monthly_sales_trends
;

-- Evaluating yearly performance of each subcategory --
with subcategory_sales as(
select
	extract (year from order_date) as year,
	sub_category,
	sum(sales) as sales,
	sum(profit) as profits
from non_returned_orders
left join orders
	using(order_id)
left join products
	using(product_id)
group by (extract (year from order_date)), sub_category
order by 1
)

select 
	year,
	sub_category,
	sales,
	profits,
	round(avg(sales) over(partition by year),2) as avg_sales_subcatgeory,
	round(avg(profits) over(partition by year),2) as avg_profits_subcategory,
	case
		when sales >= round(avg(sales) over(partition by year),2) and profits >= round(avg(profits) over(partition by year),2) then 'High perfoming subcategory'
		when sales < round(avg(sales) over(partition by year),2) and profits < round(avg(profits) over(partition by year),2) then 'Poor performing subcategory'
		when  sales > round(avg(sales) over(partition by year),2) and profits < round(avg(profits) over(partition by year),2) then 'poor profit performance'
		when sales < round(avg(sales) over(partition by year),2) and profits > round(avg(profits) over(partition by year),2) then  'Poor sales performance'
	end as subcategory_performance
from subcategory_sales
;

-- Analyzing annual performance of each product --
with product_sales as(
select
	extract (year from order_date) as year,
	sub_category,
	product_name,
	sum(sales) as sales,
	sum(profit) as profits
from non_returned_orders
left join orders
	using(order_id)
left join products
	using(product_id)
group by (extract (year from order_date)), sub_category, product_name
order by 1
)

select 
	year,
	sub_category,
	product_name,
	sales,
	profits,
	round(avg(sales) over(partition by year),2) as avg_sales_product,
	round(avg(profits) over(partition by year),2) as avg_profits_product,
	case
		when sales >= round(avg(sales) over(partition by year),2) and profits >= round(avg(profits) over(partition by year),2) then 'High perfoming subcategory'
		when sales < round(avg(sales) over(partition by year),2) and profits < round(avg(profits) over(partition by year),2) then 'Poor performing subcategory'
		when  sales > round(avg(sales) over(partition by year),2) and profits < round(avg(profits) over(partition by year),2) then 'poor profit performance'
		when sales < round(avg(sales) over(partition by year),2) and profits > round(avg(profits) over(partition by year),2) then  'Poor sales performance'
	end as product_performance
from product_sales
;

 -- Identifying the top 10 revenue-generating products for each year --
with top10_sales as ( 
select 
	extract(year from order_date) as year,
	sub_category,
	product_name,
	sum(sales) as revenue,
	rank() over (partition by extract(year from order_date)
				order by sum(sales) desc)
from non_returned_orders
left join orders
	using(order_id)
left join products
	using(product_id)
group by extract(year from order_date), sub_category, product_name
order by 1, 4 desc 
)

select 
	year,
	sub_category,
	product_name,
	revenue,
	rank
from top10_sales
where rank <= 10
;

-- Identifying the top 10 profit-generating products --
with top10_profit as ( 
select 
	extract (year from order_date) as year,
	sub_category,
	product_name,
	sum(profit) as profit,
	rank() over ( partition by extract (year from order_date)
				order by sum(profit) desc)
from non_returned_orders
left join orders
	using(order_id)
left join products
	using(product_id)
group by extract (year from order_date),sub_category, product_name
order by 1, 4 desc
)
select 
	year,
	sub_category,
	product_name,
	profit,
	rank
from top10_profit
where rank <= 10
;

 -- Identifying the bottom 10 revenue-generating products for each year --
with bottom_products as(
select 
	extract (year from order_date) as year,
	sub_category,
	product_name,
	sum(sales) as revenue,
	rank() over (partition by extract (year from order_date)
				order by sum(sales) asc)
from non_returned_orders
left join orders
	using(order_id)
left join products
	using(product_id)
group by extract (year from order_date), sub_category, product_name
order by 1 asc, 4 asc
)
select 
	year,
	sub_category,
	product_name,
	revenue,
	rank
from bottom_products
where rank <= 10
;

-- Identifying the bottom 10 profit-generating products for each year --
with bottom_products as(
select 
	extract (year from order_date) as year,
	sub_category,
	product_name,
	sum(profit) as profits,
	rank() over (partition by extract (year from order_date)
				order by sum(profit) asc)
from non_returned_orders
left join orders
	using(order_id)
left join products
	using(product_id)
group by extract (year from order_date), sub_category, product_name
order by 1 asc, 4 asc
)
select 
	year,
	sub_category,
	product_name,
	profits,
	rank
from bottom_products
where rank <= 10
;

-- Analyzing each subcategory’s sales contribution to total yearly sales  --
with category_sales as(
select 
	extract(year from order_date) as year,
	category,
	sub_category,
	sum(sales) as revenue
from non_returned_orders
left join orders
	using(order_id)
left join products 
	using(product_id)
group by extract(year from order_date), category, sub_category
order by 1
),

year_totals as (
select 
	year,
	category,
	sub_category,
	revenue,
	sum(revenue) over(partition by year) as category_totals
from category_sales
)

select 
	year,
	category,
	sub_category,
	revenue,
	category_totals,
	round((revenue/category_totals)* 100,2) || ' ' || '%' as percentage
from year_totals
;
	
-- Evaluating total products, revenue, and profits by discount category for each year --
with discount_category as ( -- categorising products based on discounts --
select 
	extract(year from order_date) as year,
	category,
	sub_category,
	product_id,
	product_name,
	discount,
	sales,
	profit,
	case 
		when discount = 0.00 then 'No Discount'
		when discount > 0.00 and discount < 0.20 then 'Less than 20%'
		when discount = 0.20 then '20% Discount'
		when discount > 0.20 then 'More than 20%'
	end as disc_category
from non_returned_orders
left join orders
	using(order_id)
left join products
	using (product_id)
order by 1
)
select 
	year,
	disc_category,
	count(product_id) as products,
	sum(sales) as revenue,
	sum(profit) as profit_total
from discount_category
group by year ,disc_category
order by 1
;

-- Analyzing yearly return frequency for each product --
with returns as (
select -- creating a returns related factors cte --
	extract( year from order_date) as year,
	ship_date,
	ship_mode,
	state,
	region,
	returned,
	case 
		when returned = 'Yes' then 1
		else 0
	end as num_return,
	category,
	sub_category,
	product_name
from order_items as i
left join orders as o
	using(order_id)
left join products as p
	using(product_id)
left join customers as c
	using (customer_id)
order by 1
),

returned_products as ( -- filtering for all the products that have been returned --
select 
	year,
	category,
	sub_category,
	product_name,
	count(*) as no_of_returns
from returns 
	where returned = 'Yes'
group by year,
	category,
	sub_category,
	product_name
order by 1
)

select *
from returned_products
order by 1
;

-- Assessing the yearly correlation between returns and delivery time --
with returns as (
select -- creating a returns related factors cte --
	extract (year from order_date) as year,
	order_date,
	ship_date,
	ship_mode,
	state,
	region,
	returned,
	case 
		when returned = 'Yes' then 1
		else 0
	end as num_return,
	category,
	sub_category,
	product_name
from order_items as i
left join orders as o
	using(order_id)
left join products as p
	using(product_id)
left join customers as c
	using (customer_id)
)
select 
	year,
	age(ship_date, order_date) as delivery_time,
	count(*) as returns 
from returns
	where returned = 'Yes'
group by rollup(year, age(ship_date, order_date))
order by 1
;

-- Analyzing yearly returns by shipment method --
 --
with returns as (
select -- creating a returns related factors cte --
	extract(year from order_date) as year,
	order_date,
	ship_date,
	ship_mode,
	state,
	region,
	returned,
	case 
		when returned = 'Yes' then 1
		else 0
	end as num_return,
	category,
	sub_category,
	product_name
from order_items as i
left join orders as o
	using(order_id)
left join products as p
	using(product_id)
left join customers as c
	using (customer_id)
)

select 
	year,
	ship_mode,
	count(*) as no_of_returns
from returns 
	where returned = 'Yes'
group by rollup(year, ship_mode)
order by 1
;

-- Identifying the state and city with the highest returns each year --
select 
	extract(year from order_date) as year,
	state,
	city,
	count(order_id) as returns
from order_items
left join orders
	using(order_id)
left join customers 
	using(customer_id)
where returned = 'Yes'
group by extract(year from order_date), state, city
order by 1 
;

-- Identifying customers associated with returned orders --
select 
	extract(year from order_date) as year,
	customer_id,
	customer_name,
	count(order_id) as returns
from order_items
left join orders
	using(order_id)
left join customers 
	using(customer_id)
where returned = 'Yes'
group by extract(year from order_date), customer_id, customer_name
order by 1
;

-- Analyzing returns across different discount levels --
with discount_category as (
select 
	extract(year from order_date) as year,
	order_id,
	category,
	sub_category,
	product_id,
	product_name,
	discount,
	sales,
	profit,
	case 
		when discount = 0.00 then 'No Discount'
		when discount > 0.00 and discount < 0.20 then 'Less than 20%'
		when discount = 0.20 then '20% Discount'
		when discount > 0.20 then 'More than 20%'
	end as disc_category
from order_items
left join orders 
	using(order_id)
left join products
	using (product_id)
where returned = 'Yes'
)
select 
	year,
	disc_category,
	count(order_id) as returns
from discount_category
group by year, disc_category
order by 1
;

-- finding top 10 customers in each segment based on sales only for each year --
with customer_orders as ( -- finding customers no of orders and sales amount --
select 
	extract(year from order_date) as year,
	segment,
	customer_id,
	customer_name,
	count(order_id) as orders,
	sum(sales) as sales
from order_items
left join orders 
	using(order_id)
left join customers 
	using(customer_id)
group by 	year, segment,
	customer_id,
	customer_name
order by 1
),

ranks as ( -- ranking customers in each respective segment based on sales --
select 
	year,
	segment,
	customer_id,
	customer_name,
	orders,
	sales,
	dense_rank() over(partition by year, segment
				order by sales desc) as customer_rank
from customer_orders
order by year
)

select -- filtering to top 10 customers from each each segment --
	year,
	segment,
	customer_id,
	customer_name,
	orders,
	sales,
	customer_rank
from ranks
where customer_rank <= 10
;

-- Analyzing yearly counts of late vs. on-time deliveries --
with delivery as (
select 
	extract(year from order_date) as year,
	order_id,
	order_date,
	ship_date,
	age(ship_date, order_date) as delivery_time,
	ship_mode,
	case 
		when age(ship_date, order_date) <= '4 days' then 'standard delivery period'
		when age(ship_date, order_date) > '4 days' then 'late delivery'
	end as standard_late,
	state,
	city
from order_items
left join orders 
	using(order_id)
left join customers
	using(customer_id)
)
select 
	year,
	standard_late,
	count(distinct order_id) as delayed_orders
from delivery
group by year, standard_late
order by 1
;

-- Identifying cities with the highest number of delayed deliveries each year. --
with delivery as (
select 
	extract(year from order_date) as year,
	order_id,
	order_date,
	ship_date,
	age(ship_date, order_date) as delivery_time,
	ship_mode,
	case 
		when age(ship_date, order_date) <= '4 days' then 'standard delivery period'
		when age(ship_date, order_date) > '4 days' then 'late delivery'
	end as standard_late,
	state,
	city
from order_items
left join orders 
	using(order_id)
left join customers
	using(customer_id)
)
select
	year,
	city,
	count(distinct order_id) as delayed_orders
from delivery
where standard_late = 'late delivery'
group by year, city
order by 1
;

-- Analyzing the number of delayed orders by shipment mode --
with delivery as (
select 
	extract(year from order_date) as year,
	order_id,
	order_date,
	ship_date,
	age(ship_date, order_date) as delivery_time,
	ship_mode,
	case 
		when age(ship_date, order_date) <= '4 days' then 'standard delivery period'
		when age(ship_date, order_date) > '4 days' then 'late delivery'
	end as standard_late,
	state,
	city
from order_items
left join orders 
	using(order_id)
left join customers
	using(customer_id)
)

select 
	year,
	ship_mode,
	count(distinct order_id)
from delivery
where standard_late = 'late delivery'
group by year, ship_mode
order by 1
;

-- Analyzing delayed orders by region --
with delivery as (
select 
	extract(year from order_date) as year,
	order_id,
	order_date,
	ship_date,
	age(ship_date, order_date) as delivery_time,
	ship_mode,
	case 
		when age(ship_date, order_date) <= '4 days' then 'standard delivery period'
		when age(ship_date, order_date) > '4 days' then 'late delivery'
	end as standard_late,
	state,
	city, 
	region
from order_items
left join orders 
	using(order_id)
left join customers
	using(customer_id)
)

select 
	year,
	region,
	count(distinct order_id) as delayed_orders
from delivery 
where standard_late = 'late delivery'
group by year, region
order by 1
;

-- Segregating cities by sales and profit performance for each year --
with cities as (
select 
	extract(year from order_date) as year,
	city,
	sum(sales) as sales,
	sum(profit) as profits
from non_returned_orders
left join orders
	using(order_id)
left join customers
	using(customer_id)
group by extract(year from order_date), city
order by 1
),

cities_avg as (
select
	year,
	city,
	sales, 
	profits,
	round(avg(sales) over (partition by year),2) as avg_sales_city,
	round(avg(profits) over(partition by year),2) as avg_profits_city
from cities
) 

select
	year,
	city,
	sales,
	profits,
	avg_sales_city,
	avg_profits_city,
	case
		when sales >= avg_sales_city and profits >= avg_profits_city then 'High sales and high profits'
		when sales > avg_sales_city and profits < avg_profits_city then 'High sales and low profits'
		when sales < avg_sales_city and profits > avg_profits_city then 'low sales and high profits'
		when sales <avg_sales_city and profits < avg_profits_city then 'low sales and low profits'
	end as cities_performance
from cities_avg
order by 1
;