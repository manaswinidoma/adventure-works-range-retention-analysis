/*
===============================================================================
Attach Rate Analysis
===============================================================================
Purpose:
    - Do bike buyers also buy Accessories & Clothing?
    - Is the Accessories & Clothing range more valuable as an add-on to bike
      purchases, or as a standalone product for new customers?
Definitions:
    - Add-on       = any Accessories or Clothing item.
    - Attach rate  = % of orders containing a bike that also contain an add-on.
Notes:
    - Only orders from 28 Dec 2012 (first recorded Accessories/Clothing sale)
      are included, so bike orders placed before add-ons could be bought
      don't drag the attach rate down.
    - Order lines with invalid (NULL) order dates are excluded.
===============================================================================
*/

--1. How often does a bike order include an add-on? (attach rate)
WITH order_flags AS (
	-- one row per order: does it contain a bike, an add-on, and how much was spent on add-ons?
	SELECT
	f.order_number,
	MAX(CASE WHEN p.category = 'Bikes' THEN 1 ELSE 0 END) AS has_bike,
	MAX(CASE WHEN p.category IN ('Accessories', 'Clothing') THEN 1 ELSE 0 END) AS has_add_on,
	SUM(CASE WHEN p.category IN ('Accessories', 'Clothing') THEN f.sales_amount ELSE 0 END) AS add_on_revenue
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE f.order_date >= '2012-12-28'   -- also excludes NULL order dates
	GROUP BY f.order_number 
)
SELECT
COUNT(*) AS bike_orders,
COUNT(*) FILTER (WHERE has_add_on = 1) AS bike_orders_with_add_on,
ROUND(100.0 * COUNT(*) FILTER (WHERE has_add_on = 1) / COUNT(*), 1) AS attach_rate_pct,
ROUND(AVG(add_on_revenue) FILTER (WHERE has_add_on = 1), 2) AS avg_add_on_revenue_per_order
FROM order_flags
WHERE has_bike = 1;


--2. Is add-on revenue earned alongside bikes or on its own? (split by order type)
WITH order_flags AS (
	SELECT
	f.order_number,
	MAX(CASE WHEN p.category = 'Bikes' THEN 1 ELSE 0 END) AS has_bike,
	MAX(CASE WHEN p.category IN ('Accessories', 'Clothing') THEN 1 ELSE 0 END) AS has_add_on,
	SUM(CASE WHEN p.category IN ('Accessories', 'Clothing') THEN f.sales_amount ELSE 0 END) AS add_on_revenue
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE f.order_date >= '2012-12-28'
	GROUP BY f.order_number
)
SELECT
CASE
	WHEN has_bike = 1 THEN 'Bought with a bike'
	ELSE 'Bought without a bike'
END AS order_type,
COUNT(*) AS orders,
SUM(add_on_revenue) AS add_on_revenue,
ROUND(100.0 * SUM(add_on_revenue) / SUM(SUM(add_on_revenue)) OVER (), 1) AS pct_add_on_revenue
FROM order_flags
WHERE has_add_on = 1
GROUP BY 1
ORDER BY add_on_revenue DESC;


--3. Who buys the add-ons: bike buyers or customers who never bought a bike?
--   Counts customers (not orders). "Bike buyer" = bought a bike at any time.
WITH bike_buyers AS (
	-- every customer who has bought at least one bike
	SELECT DISTINCT f.customer_key
	FROM gold.fact_sales f
	JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE p.category = 'Bikes'
	AND f.order_date IS NOT NULL
)
SELECT
CASE
	WHEN bb.customer_key IS NOT NULL THEN 'Bike buyer'
	ELSE 'Never bought a bike'
END AS customer_type,
COUNT(DISTINCT f.customer_key) AS customers,
SUM(f.sales_amount) AS add_on_revenue,
ROUND(100.0 * SUM(f.sales_amount) / SUM(SUM(f.sales_amount)) OVER (), 1) AS pct_add_on_revenue,
ROUND(1.0 * SUM(f.sales_amount) / COUNT(DISTINCT f.customer_key), 2) AS add_on_revenue_per_customer
FROM gold.fact_sales f
JOIN gold.dim_products p
ON f.product_key = p.product_key
LEFT JOIN bike_buyers bb
ON f.customer_key = bb.customer_key
WHERE p.category IN ('Accessories', 'Clothing')
AND f.order_date IS NOT NULL
GROUP BY 1
ORDER BY add_on_revenue DESC;


