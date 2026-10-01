--Dimension Exploration

--Explore all Countries our customers come from.
SELECT DISTINCT country 
FROM gold.dim_customers;

--Explore all categories "The major divisions"
SELECT 
	DISTINCT category,subcategory, product_name 
FROM gold.dim_products 
ORDER BY 1,2,3;

--Find the date of first and last order
--How many years of sales are available
SELECT 
	MIN(order_date) AS first_order_date, 
	MAX(order_date) AS last_order_date,
	EXTRACT (YEAR FROM MAX(order_date)) - EXTRACT(YEAR FROM MIN(order_date)) AS order_range_years,
	EXTRACT(YEAR FROM AGE(MAX(order_date) , MIN(order_date))) * 12
	     + EXTRACT(MONTH FROM AGE(MAX(order_date) , MIN(order_date))) AS order_range_months
FROM gold.fact_sales;


--Find the youngest and the oldest customer
SELECT 
	MIN(birth_date) AS oldest_birthdate, 
	max(birth_date) AS youngest_birthdate,
	EXTRACT(YEAR FROM NOW()) - EXTRACT(YEAR FROM MIN(birth_date)) AS oldest_age,
	EXTRACT(YEAR FROM NOW()) - EXTRACT(YEAR FROM MAX(birth_date)) AS youngest_age
FROM gold.dim_customers;


