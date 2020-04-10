--*************************************
--CREATE Parquet TABLES on Sales Data
--*************************************


SET VAR:database_name=zeroes_and_ones_sales;

--Create Parquet Product Region Sales Partitioned Table

CREATE TABLE IF NOT EXISTS ${var:database_name}.product_region_sales_partition (
order_id int,
sales_person_id int,
customer_id int,
product_id int,
product_name varchar,
product_price decimal(15,2),
quantity int,
total_sales_amount decimal(15,2),
order_date varchar)
PARTITIONED BY (region varchar,sales_year int,sales_month varchar)
COMMENT 'Parquet Product, Region and Sales partitioned table'
STORED AS Parquet;

Insert into ${var:database_name}.product_region_sales_partition partition(region='east',sales_year,sales_month)
Select se.order_id,se.sales_person_id,se.customer_id,se.product_id,se.product_name,cast(se.product_price as decimal(15,2)) as product_price,
se.quantity,cast(se.total_sales_amount as decimal(15,2)), to_date(se.order_date),se.sales_year,se.sales_month
From ${var:database_name}.product_sales_partition se 
	join ${var:database_name}.employees e
	on(se.sales_person_id=e.employee_id)
	where e.region = 'east';;

Insert into ${var:database_name}.product_region_sales_partition partition(region='west',sales_year,sales_month)
Select se.order_id,se.sales_person_id,se.customer_id,se.product_id,se.product_name,cast(se.product_price as decimal(15,2)) as product_price,
se.quantity,cast(se.total_sales_amount as decimal(15,2)), to_date(se.order_date),se.sales_year,se.sales_month
From ${var:database_name}.product_sales_partition se 
	join ${var:database_name}.employees e
	on(se.sales_person_id=e.employee_id)
	where e.region = 'west';;

Insert into ${var:database_name}.product_region_sales_partition partition(region='north',sales_year,sales_month)
Select se.order_id,se.sales_person_id,se.customer_id,se.product_id,se.product_name,cast(se.product_price as decimal(15,2)) as product_price,
se.quantity,cast(se.total_sales_amount as decimal(15,2)), to_date(se.order_date),se.sales_year,se.sales_month
From ${var:database_name}.product_sales_partition se 
	join ${var:database_name}.employees e
	on(se.sales_person_id=e.employee_id)
	where e.region = 'north';;

Insert into ${var:database_name}.product_region_sales_partition partition(region='south',sales_year,sales_month)
Select se.order_id,se.sales_person_id,se.customer_id,se.product_id,se.product_name,cast(se.product_price as decimal(15,2)) as product_price,
se.quantity,cast(se.total_sales_amount as decimal(15,2)), to_date(se.order_date),se.sales_year,se.sales_month
From ${var:database_name}.product_sales_partition se 
	join ${var:database_name}.employees e
	on(se.sales_person_id=e.employee_id)
	where e.region = 'south';;
invalidate metadata;
compute stats ${var:database_name}.product_region_sales_partition; 