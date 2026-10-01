/*
===============================================================================
Dimension Exploration
===============================================================================
Purpose:
    - Explores the key dimensions: customer countries, product categories,
      the date range of sales and the age range of customers.
Tables used:
    - gold.dim_customers
    - gold.dim_products
    - gold.fact_sales
Notes:
    - Ages are calculated as at the last order date in the data (Jan 2014),
      not today's date, so they reflect customers when they were buying.
===============================================================================
*/

--Explore all Countries our customers come from.
SELECT DISTINCT country 
FROM gold.dim_customers;

--Explore all categories "The major divisions"
SELECT 
	DISTINCT category,subcategory, product_name 
FROM gold.dim_products 
ORDER BY 1,2,3;

--Find the date of first and last order
--How many months of sales are available
SELECT 
	MIN(order_date) AS first_order_date, 
	MAX(order_date) AS last_order_date,
	EXTRACT(YEAR FROM AGE(MAX(order_date) , MIN(order_date))) * 12
	     + EXTRACT(MONTH FROM AGE(MAX(order_date) , MIN(order_date))) AS order_range_months
FROM gold.fact_sales;


--Find the youngest and the oldest customer (age as at the last order date in the data)
SELECT
	MIN(birth_date) AS oldest_birthdate,
	MAX(birth_date) AS youngest_birthdate,
	EXTRACT(YEAR FROM AGE((SELECT MAX(order_date) FROM gold.fact_sales), MIN(birth_date))) AS oldest_age,
	EXTRACT(YEAR FROM AGE((SELECT MAX(order_date) FROM gold.fact_sales), MAX(birth_date))) AS youngest_age
FROM gold.dim_customers;