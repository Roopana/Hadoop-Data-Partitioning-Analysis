# CSCI 5751_Hadoop_Project
> Ingest sales data from data warehouse into data lake and prepare it for analysis and consumption.

### Group Name: zeros_and_ones

### Group Members: 
* Ayushi Rastogi
* Krishna Shravya Gade
* Mourya Karan Reddy
* Roopana Vuppalapati Chenchu

## Table of contents
* [Description](#Description)
* [Technologies](#technologies)
* [Setup Cloudera VM](#setup-cloudera-vm)
* [Deployment Instructions](#deployment-instructions)
* [Rollback Script](#rollback-script)
* [Kudu Results](#kudu-results)

## Description
The data warehouse has data for Sales, Customers, Employees and Products. Below is the screenshot of the data model used. Given data has been cleaned, validated and stored in partitions to facilitate efficient analysis and visualization. 

   ![Sales Data Model](https://github.com/aiBoss/zeroes_and_ones_Hadoop/blob/master/SalesDataModel.png)
  ### Data Clean up & Validation
  * In the raw data, many entries have middle name values as empty in _Customers_ tables.  Since Business Questions do not require this field, we have removed this field while constructing parquet tables in _zeros_and_ones_sales database_.
  * In _Employees_ table, the region field has values differing in case(for example: _East_, _east_). We have converted all the values in the _region_ column to lowercase to remove false duplicates. 
  * Few products have price as 0. We retained these entries to preserve the details of all the products.
  * Few entries had price value with high precision (256.99999999...) These values have been rounded off to two decimals for an   easy visualization to users. 
  ### Data Partitions and Views
  * Views:
  <br/>&nbsp;&nbsp;&nbsp;&nbsp; _customer_monthly_sales_2019_view_ and _top_ten_customers_amount_view_ are created for a quick retrieval of monthy sales in 2019 and top 10 customers. Procedure to run these views is explained in the deployment instructions section. 
  * Partitions:
   <br/>&nbsp;&nbsp;&nbsp;&nbsp; Using partitioned views makes the data analysis and visualization more efficient due to multiple reasons. Partitioning divides table entries into distinct groups based on the partition key. Hence when searching for a value in the partitioned table, the number of entries that need to be searched is lesser resulting in a reduced run time. Also, the query can be run in parallel in different partitions, reducing the response time of query. 
   <br/>&nbsp;&nbsp;&nbsp;&nbsp; Below are three partitioned views created as part of the project. It can be observed that, it is more efficient to use _customer_monthly_sales_2019_partitioned_view_ than  _customer_monthly_sales_2019_view_ for data retrieval and data visualization due to the partitioning done on sales year and month.
      
      * _product_sales_partition_: Total sales amount for each product is captured in this table and the data is partitioned on sales year and month
    * _customer_monthly_sales_2019_partitioned_view_: This table gives monthly sales of each customer in 2019. The data partitioned on year and month.
    * _product_region_sales_partition_: Regional sales for each product is stored in this table and the data is partitioned on sales year and month

## Technologies
* VirtualBox Cloudera VM - version 5.13.0
  * HDFS
  * Impala
  * Kudu

## Setup Cloudera VM
Follow the instructions [here](https://github.com/aiBoss/zeroes_and_ones_Hadoop/blob/master/Cloudera%20VM.pdf) to install and configure Cloudera VM on local machine

## Deployment Instructions

* Clone the git repository  
* In the same location where the repository is cloned, run _"sh /zeroes_and_ones_Hadoop/bin/deploy.sh -h"_ to get the list of commands that need to be executed for each query.
* Run the queries as required. For example, _"sh /zeroes_and_ones_Hadoop/bin/deploy.sh -l"_ to load sales data to hdfs

## Rollback Script
* run _"sh /zeroes_and_ones_Hadoop/bin/deploy.sh -d"_ to drop all views, databases and delete the data from HDFS and disk.
   * Additional info for user: While dropping managed tables(parquet tables), instead of using _'CASCADE'_ command to drop the databases, the script initially drops the tables (using _'PURGE'_ command) and then the databases to remove the HDFS files. If we dont follow this approach to remove databases and create another database immediately, it has two copies of the data.

## Kudu Results
### 1. Query to give the total dollar amount sold by year
<br/>
SELECT sum(p.price) as total_dollar, date_part('year',s.sale_date) as year FROM kudu_products p JOIN kudu_sales s ON p.product_id=s.product_id GROUP BY date_part('year',s.sale_date)
<br/>
### Query Results
<br/>
+-------------------+------+<br/>
| total_dollar      | year |<br/>
+-------------------+------+<br/>
| 260623819.5950315 | 2020 |<br/>
| 1505770418.65269  | 2018 |<br/>
| 1761530108.44215  | 2019 |<br/>
+-------------------+------+<br/>
Fetched 3 row(s) in 14.29s<br/>

### 2. Query to give the total dollar amount sold by year after inserting given records into the sales table
<br/>
SELECT sum(p.price) as total_dollar, date_part('year',s.sale_date) as year FROM kudu_products p JOIN kudu_sales s ON p.product_id=s.product_id GROUP BY date_part('year',s.sale_date)
<br/>
### Query Results
<br/>
+-------------------+------+<br/>
| total_dollar&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | year&nbsp;&nbsp;&nbsp; |<br/>
+-------------------+------+<br/>
| 260628054.5750315 | 2020 |<br/>
| 1505770418.65269  | 2018 |<br/>
| 1761530108.44215  | 2019 |<br/>
+-------------------+------+<br/>
Fetched 3 row(s) in 18.82s<br/>

### Query to give the total dollar amount sold by year after deleting records added in step 2 and upserting given records into the sales table
<br/>
SELECT sum(p.price) as total_dollar, date_part('year',s.sale_date) as year FROM kudu_products p JOIN kudu_sales s ON p.product_id=s.product_id GROUP BY date_part('year',s.sale_date)
<br/>
### Query Results
<br/>
+-------------------+------+<br/>
| total_dollar      | year |<br/>
+-------------------+------+<br/>
| 260623819.5950315 | 2020 |<br/>
| 1505770418.65269  | 2018 |<br/>
| 1761530108.44215  | 2019 |<br/>
+-------------------+------+<br/>
Fetched 3 row(s) in 42.45s<br/>
