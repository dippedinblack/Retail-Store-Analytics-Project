
-- Evaluating year-wise KPI metrics for non-returned orders--
with kpi_metrics as (
select 
	extract(year from order_date) as year,
	sum(sales) as tot_sales,
	round((sum(sales)/ count(distinct order_id)),2) as avg_sales_order,
	sum(quantity) as quantity,
	sum(quantity) /  count(distinct order_id) as avg_quantity_order,
	sum(profit) as tot_profit,
	round((sum(profit) / sum(sales))*100,2) || ' ' || '%' as profit_margin,
	count(distinct order_id) as tot_orders
from non_returned_orders
left join orders
	using (order_id)
group by extract(year from order_date) 
)

select
	year, 
	tot_sales,
	avg_sales_order,
	lag(tot_sales,1) over(order by year asc) as py_sales,
	round(((tot_sales - lag(tot_sales,1) over(order by year asc)) / lag(tot_sales,1) over(order by year asc))*100,2) || ' ' || '%' as sales_growth,
	quantity,
	avg_quantity_order,
	tot_profit,
	profit_margin,
	tot_orders
from kpi_metrics
;

-- Analyzing the total number of customers each year and their year-over-year change --
with customers_count as(
select 
	extract(year from order_date) as year,
	count(distinct customer_id) as customers
from orders
left join customers
	using(customer_id)
group by extract(year from order_date) 
)

select
	year,
	customers,
	lag(customers,1) over(order by year asc) as py_customers,
	customers - lag(customers,1) over(order by year asc) as customers_change
from customers_count
order by year asc
;

-- Analyzing yearly revenue and profit loss caused by returns --
select
	extract(year from order_date) as year,
	sum(sales) as sales_lost,
	(select
		sum(sales) 
	from non_returned_orders) as overall_sales,
	round((sum(sales) / (select
		sum(sales) 
	from non_returned_orders))* 100,2) || ' ' || '%' as loss_percent
from order_items 
left join orders
	using(order_id)
where returned = 'Yes'
group by extract(year from order_date) 
;

-- Analyzing total returns on a year-over-year basis --
with returns as (
select -- creating a returns related factors cte --
	order_id,
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
select -- calculating total returns --
	extract(year from order_date) as year,
	sum(num_return) as tot_returns
from returns
group by extract(year from order_date) 
;

-- dimension exploration -- 
select -- cities--
	distinct city
from customers
;

-- finding different categories and subcategories --
select 
	distinct category,
	sub_category
from products 
order by category
;

select -- finding different consumer segment -- 
	distinct segment
from customers 
;

-- date exploartion --
select 
	min(order_date) as first_order,
	max(order_date) as last_order,
	age(max(order_date),min(order_date)) as duration
from orders

-- Exploring yearly sales, quantity, profit, and discount ranges --
select 
	extract(year from order_date) as year,
	min(sales) as min_sales,
	max(sales) as max_sales,
	min(profit) as min_profit,
	max(profit) as max_profit,
	min(discount) as min_discount,
	max(discount) as max_discount,
	min(quantity) as min_quantity,
	max(quantity) as max_quantity
from non_returned_orders
left join orders
	using(order_id)
group by extract(year from order_date) 
;

-- year wise sales --
select 
	coalesce(date_trunc('year', order_date):: text,'Totals') as year,
	sum(sales) as sales 
from non_returned_orders
left join orders 
	using(order_id)
group by rollup(date_trunc('year', order_date))
order by 2 desc 
;

-- Conducting year-wise customer exploration and analysis --
select 
	extract(year from order_date) as year,
	coalesce(segment, 'Totals') as segment,
	count(distinct customer_id) as customers,
	sum(sales) as sales,
	sum(quantity) as qty
from order_items -- order_items to see the costumer behaviour --
left join orders
	using(order_id)
left join customers
	using(customer_id)
group by rollup(extract(year from order_date),segment)
order by year
;

-- Analyzing total orders by shipment method for each year --

select 
	extract(year from order_date) as year,
	ship_mode,
	count(distinct order_id) as orders 
from orders 
group by extract(year from order_date), ship_mode
order by 1
;

-- Analyzing yearly sales and profit across categories and subcategories --
select 
	extract (year from order_date) as year,
	coalesce(category,'Totals') as category,
	coalesce(sub_category, 'Totals') as sub_category,
	count(distinct order_id) as orders,
	sum(sales) as revenue,
	sum(profit) as profit
from non_returned_orders
left join orders
	using(order_id)
left join products
	using(product_id)
group by rollup(extract (year from order_date),category, sub_category)
order by 1 asc
;

-- Ranking the top 10 cities by annual revenue --
with cities_rank as (
select 
	extract (year from order_date) as year,
	city,
	sum(sales) as revenue,
	rank() over(partition by extract (year from order_date)
				order by sum(sales) desc)
from non_returned_orders
left join orders 
	using(order_id)
left join customers 
	using(customer_id)
group by year, city
)

select
	year,
	city,
	revenue,
	rank
from cities_rank
where rank <= 10
;

-- Ranking the top 10 cities by annual profit --
select 
	state,
	city,
	sum(sales) as revenue,
	rank() over(order by sum(sales) desc)
from non_returned_orders
left join orders 
	using(order_id)
left join customers 
	using(customer_id)
group by state, city
order by 3 desc
limit 10
;
	
-- Identifying the top 10 customers each year based on sales --
with customers_rank as (
select 
	extract(year from order_date) as year,
	customer_id,
	customer_name,
	sum(sales) as revenue,
	count(distinct order_id) as orders,
	rank() over (partition by extract(year from order_date)
				order by sum(sales) desc ) as rank
from non_returned_orders
left join orders 
	using(order_id)
left join customers 
	using(customer_id)
group by extract(year from order_date), customer_id, customer_name
order by 1 asc, 4 desc
)
select
	year,
	customer_id,
	customer_name,
	revenue,
	orders,
	rank
from customers_rank
where rank <= 10
;

-- Identifying the bottom 10 customers each year based on sales --
with customers_rank as (
select 
	extract(year from order_date) as year,
	customer_id,
	customer_name,
	sum(sales) as revenue,
	count(distinct order_id) as orders,
	rank() over (partition by extract(year from order_date)
				order by sum(sales) asc) as rank
from non_returned_orders
left join orders 
	using(order_id)
left join customers 
	using(customer_id)
group by extract(year from order_date), customer_id, customer_name
order by 1 asc, 4 asc
)
select
	year,
	customer_id,
	customer_name,
	revenue,
	orders,
	rank
from customers_rank
where rank <= 10
;

-- Ranking subcategories by annual revenue-- 
with sub_sales as (
select -- finding total revenue from each sub category --
	extract(year from order_date) as year,
	category,
	sub_category,
	sum(sales) as revenue,
	sum(profit) as profits
from non_returned_orders
left join orders 
	using(order_id)
left join products 
	using(product_id)
group by year, category, sub_category
order by 1 asc
)

select 
	year,
	category,
	sub_category,
	revenue,
	profits,
	rank() over (partition by year
				order by revenue desc ) as sales_rank,
	rank() over (partition by year
				order by profits desc ) as profit_rank
from sub_sales
order by 1
;

-- Identifying the top 50 revenue-generating products for each year --
with products_rank as (
select 
	extract(year from order_date) as year,
	product_name,
	sum(sales) as revenue,
	sum(profit) as profit,
	rank() over (partition by extract(year from order_date)
				order by sum(sales) desc ) as sales_rank,
	rank() over (partition by extract(year from order_date)
				order by sum(profit) desc ) as profit_rank
from non_returned_orders
left join orders 
	using(order_id)
left join products 
	using(product_id)
group by extract(year from order_date), product_name
order by 1 asc, 3 desc, 4 desc
)

select 
	year, 
	product_name,
	revenue,
	profit,
	sales_rank,
	profit_rank
from products_rank
;

-- Analyzing profit margins by category and subcategory --
select 
	extract(year from order_date) as year,
	category,
	sub_category,
	round((sum(profit)/ sum(sales)) * 100, 2)  as profit_margin
from non_returned_orders
left join orders
	using(order_id)
left join products 
	using(product_id)
group by extract(year from order_date), category, sub_category
order by 1
;

--  Analyzing yearly profit margins by state --
select
	extract(year from order_date) as year,
	state,
	round((sum(profit)/ sum(sales)) * 100, 2) as profit_margin
from non_returned_orders
left join orders 
	using(order_id)
left join customers 
	using(customer_id)
group by extract(year from order_date),state
order by 1
;

-- Analyzing total sales and profit across different discount levels -- 
select
	extract(year from order_date) as year,
	discount,
	sum(sales) as sales,
	sum(profit) as profit
from non_returned_orders
left join orders
	using(order_id)
left join products 
	using(product_id)
group by extract(year from order_date), discount
order by 1
;

-- finding avg delivery time -- 
select
	extract(year from order_date) as year,
	round((avg(ship_date - order_date)),1) as avg_delivery_days
from orders
group by extract(year from order_date)
;