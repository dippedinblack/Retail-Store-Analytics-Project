
-- creating store_sales database --
create database store_sales ;

-- creating raw dataset sales -- 
CREATE TABLE sales (
	row_id INT,
	order_id VARCHAR(20),
	order_date DATE,
	ship_date DATE,
	ship_mode VARCHAR(20),
	customer_id VARCHAR(20),
	customer_name VARCHAR(50),
	segment VARCHAR(50),
	country VARCHAR(50),
	city VARCHAR(50),
	state VARCHAR(50),
	postal_code VARCHAR(10),
	region VARCHAR(20),
	product_id VARCHAR(20),
	category VARCHAR(50),
	sub_category VARCHAR(50),
	product_name VARCHAR(150),  
	sales NUMERIC(10,2),
	quantity INT,
	discount NUMERIC(10,2),
	profit NUMERIC(10,2),
	returned VARCHAR(10)
);

-- altering order date and ship data type to date in sales table --
alter table sales
alter column order_date type date
using order_date:: date, -- casting the order_date which was string to date using :: -- 
alter column ship_date type date
using ship_date:: date
;

-- creating table customers --
create table customers (
	customer_id VARCHAR(20) primary key,
	customer_name VARCHAR(50) not null,
	segment VARCHAR(50),
	country VARCHAR(50),
	city VARCHAR(50),
	state VARCHAR(50),
	postal_code VARCHAR(10),
	region VARCHAR(20)
);

-- creating table products --
create table products (
	product_id VARCHAR(20) primary key,
	category VARCHAR(50),
	sub_category VARCHAR(50),
	product_name VARCHAR(150) not null
);

-- creating tabvle orders --
create table orders (
	order_id VARCHAR(20) primary key,
	order_date DATE not null,
	ship_date DATE,
	ship_mode VARCHAR(20),
	customer_id VARCHAR(20) not null,
	foreign key (customer_id) references customers(customer_id)
);

-- creating table order_items --
create table order_items (
	row_id int primary key,
	order_id VARCHAR(20) not null,
	product_id VARCHAR(20) not null, 
	sales NUMERIC(10,2),
	quantity INT,
	discount NUMERIC(10,2),
	profit NUMERIC(10,2),
	returned VARCHAR(10),
	foreign key (order_id) references orders(order_id),
	foreign key (product_id) references products(product_id)
);

-- inserting daat into customers table --
insert into customers 
	(customer_id,
	customer_name,
	segment ,
	country ,
	city ,
	state ,
	postal_code ,
	region )

select distinct on (customer_id)
	customer_id,
	customer_name,
	segment ,
	country ,
	city ,
	state ,
	postal_code ,
	region 
from sales
order by customer_id, customer_name asc
;

-- inserting data into products --
insert into products 
	(product_id,
	product_name,
	category,
	sub_category)
	
select distinct on (product_id)
	product_id,
	product_name,
	category,
	sub_category
from sales 
order by product_id, product_name asc 
;

-- inserting data into orders table -- 
insert into orders 
	(order_id,
	order_date,
	ship_date,
	ship_mode,
	customer_id)

select distinct on (order_id)
	order_id,
	order_date ,
	ship_date,
	ship_mode,
	customer_id
from sales 
order by order_id
;

-- inserting data into order_items table 
insert into order_items 
	(row_id,
	order_id,
	product_id,
	sales, 
	discount,
	profit,
	quantity,
	returned )

select 
	 row_id,
	order_id,
	product_id,
	sales, 
	discount,
	profit,
	quantity,
	returned
from sales 
;

-- checking the tables --
select * from customers ;
select * from products ;
select * from orders ;

-- chceking the final table with all table joins --
select * 
from order_items 
left join orders 
	using(order_id)
left join customers
	using (customer_id)
left join products 
	using(product_id)
;

-- droppping the raw table data source --
drop table sales ;
