--******************************************
--Performing Quality Check on Raw Data
--******************************************


SET VAR:database_name=zeros_and_ones_sales_raw;

--checking uniqueness of the key
select count(order_id) from ${var:database_name}.sales;
select count(distinct order_id) from ${var:database_name}.sales;

--checking uniqueness of the key
select count(customer_id) from ${var:database_name}.customers;
select count(distinct customer_id) from ${var:database_name}.customers;

--checking uniqueness of the key
select count(product_id) from ${var:database_name}.products;
select count(distinct product_id) from ${var:database_name}.products;

--checking uniqueness of the key
select count(employee_id) from ${var:database_name}.employees;
select count(distinct employee_id) from ${var:database_name}.employees;

--checking whether price is negative or null
select count(*) from ${var:database_name}.products where price < 0;
select count(*) from ${var:database_name}.products where price = null;

--checking whether date is null
select count(*) from ${var:database_name}.sales where sale_date = null;

--checking for empty values so that we can impute if need be
select count(*) from ${var:database_name}.customers where middle_initial = '';
select count(*) from ${var:database_name}.customers where first_name = '';
select count(*) from ${var:database_name}.customers where last_name = '';
select count(*) from ${var:database_name}.employees where middle_initial = '';
select count(*) from ${var:database_name}.employees where first_name = '';
select count(*) from ${var:database_name}.employees where last_name = '';
select count(*) from ${var:database_name}.employees where region = '';
-- ** found that many middle names were empty, since BQ doesn't require it we will not include this column

--checking number of distinct regions for static partitioning
select distinct(region) from ${var:database_name}.employees;
-- ** found that regions need to be converted to lowercase in order to get distinct values

--checking the precision for price
select price from ${var:database_name}.products limit 100;
--Few entries had price value with high precision (256.99999999...) These values have been rounded off to two
--decimals for an easy visualization to users.