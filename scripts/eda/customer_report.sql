/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - Consolidates key customer metrics and behaviours into one view, built as
      a data source for the Tableau dashboard.
Highlights:
    1. Gathers customer details: name, age, country, gender and marital status.
    2. Segments customers by:
       - spending segment (VIP, Regular, New) and age group
       - buyer type (One-time, Repeat)
       - join period (before or after Accessories & Clothing started selling)
       - entry type (Bike-first or Accessory/Clothing-first)
    3. Aggregates customer-level metrics:
       - total orders, sales, quantity and products
       - bike sales and add-on (Accessories & Clothing) sales
       - first and last order dates, lifespan (in months)
    4. Calculates KPIs:
       - recency (months between the last order and the end of the data)
       - average order value
       - average monthly spend
Tables used:
    - gold.fact_sales
    - gold.dim_customers
    - gold.dim_products
Notes:
    - Order lines with invalid (NULL) order dates are excluded.
    - Age and recency are measured from the last order date in the data
      (28 Jan 2014), not today's date.
    - Range start = 28 Dec 2012 (first recorded Accessories/Clothing sale).
    - All monetary values are in US dollars (USD).
===============================================================================
*/

DROP VIEW IF EXISTS gold.report_customers;
CREATE VIEW gold.report_customers AS

--Reference date: the last order date in the data
WITH data_end AS (
	SELECT MAX(order_date) AS last_data_date
	FROM gold.fact_sales
)

--Base query: one row per order line, with customer and product details
, base_query AS (
	SELECT
		f.order_number,
		f.product_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		p.category,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		c.country,
		c.gender,
		c.marital_status,
		EXTRACT(YEAR FROM AGE(d.last_data_date, c.birth_date)) AS age,
		MIN(f.order_date) OVER (PARTITION BY f.customer_key) AS first_order_date   -- each customer's first purchase day
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
		ON f.customer_key = c.customer_key
	LEFT JOIN gold.dim_products p
		ON f.product_key = p.product_key
	CROSS JOIN data_end d
	WHERE f.order_date IS NOT NULL
)

--Customer aggregations: one row per customer
, customer_aggregations AS (
	SELECT
		customer_key,
		customer_number,
		customer_name,
		country,
		gender,
		marital_status,
		age,
		first_order_date,
		MAX(order_date) AS last_order_date,
		EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
			+ EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT product_key) AS total_products,
		SUM(CASE WHEN category = 'Bikes' THEN sales_amount ELSE 0 END) AS bike_sales,
		SUM(CASE WHEN category IN ('Accessories', 'Clothing') THEN sales_amount ELSE 0 END) AS add_on_sales,
		MAX(CASE WHEN category = 'Bikes' THEN 1 ELSE 0 END) AS bought_bike_flag,
		MAX(CASE WHEN category = 'Bikes' AND order_date = first_order_date THEN 1 ELSE 0 END) AS first_day_bike_flag
	FROM base_query
	GROUP BY
		customer_key,
		customer_number,
		customer_name,
		country,
		gender,
		marital_status,
		age,
		first_order_date
)

SELECT
	--Customer details
	ca.customer_key,
	ca.customer_number,
	ca.customer_name,
	ca.country,
	ca.gender,
	ca.marital_status,
	ca.age,
	CASE
		WHEN ca.age IS NULL THEN 'Unknown'
		WHEN ca.age < 20 THEN 'Under 20'
		WHEN ca.age BETWEEN 20 AND 29 THEN '20-29'
		WHEN ca.age BETWEEN 30 AND 39 THEN '30-39'
		WHEN ca.age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 and above'
	END AS age_group,

	--Segments
	CASE
		WHEN ca.lifespan >= 12 AND ca.total_sales > 5000 THEN 'VIP'
		WHEN ca.lifespan >= 12 AND ca.total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment,
	CASE
		WHEN ca.total_orders = 1 THEN 'One-time'
		ELSE 'Repeat'
	END AS buyer_type,
	CASE
		WHEN ca.first_order_date < '2012-12-28' THEN 'Joined before range'
		ELSE 'Joined after range'
	END AS join_period,
	CASE
		WHEN ca.first_day_bike_flag = 1 THEN 'Bike-first'
		ELSE 'Accessory/Clothing-first'
	END AS entry_type,
	CASE
		WHEN ca.bought_bike_flag = 1 THEN 'Yes'
		ELSE 'No'
	END AS has_bought_bike,

	--Dates
	ca.first_order_date,
	ca.last_order_date,
	ca.lifespan,
	EXTRACT(YEAR FROM AGE(d.last_data_date, ca.last_order_date)) * 12
		+ EXTRACT(MONTH FROM AGE(d.last_data_date, ca.last_order_date)) AS recency,

	--Measures
	ca.total_orders,
	ca.total_sales,
	ca.bike_sales,
	ca.add_on_sales,
	ca.total_quantity,
	ca.total_products,

	--KPIs
	CASE
		WHEN ca.total_orders = 0 THEN 0
		ELSE ROUND(1.0 * ca.total_sales / ca.total_orders, 2)
	END AS avg_order_value,
	CASE
		WHEN ca.lifespan = 0 THEN ca.total_sales
		ELSE ROUND(1.0 * ca.total_sales / ca.lifespan, 2)
	END AS avg_monthly_spend
FROM customer_aggregations ca
CROSS JOIN data_end d;