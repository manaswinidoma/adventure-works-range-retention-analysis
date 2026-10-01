/*
===============================================================================
Range Expansion Analysis
===============================================================================
Purpose:
    - Did adding Accessories & Clothing bring in customers who return or buy bikes?
Notes:
    - Range start = first recorded Accessories/Clothing sale (28 Dec 2012).
      Products exist in the catalogue earlier; no claim is made about why sales began.
    - Order lines with invalid (NULL) order dates are excluded.
    - Data ends Jan 2014: 2013-14 customers have had at most ~13 months to return.
===============================================================================
*/

--when did each category start selling? (first recorded sale)
SELECT p.category, 
MIN(f.order_date) AS first_sale
FROM gold.fact_sales f 
LEFT JOIN gold.dim_products p 
ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY 2;

--one-time buyer rate by first-order year (before vs after the range started selling)
SELECT
EXTRACT(YEAR FROM first_order) AS first_order_year,
COUNT(customer_key) AS customers,
SUM(
CASE 
	WHEN orders = 1 THEN 1 
	ELSE 0 
	END) AS one_time_buyers,
ROUND(100.0 * AVG(CASE WHEN orders = 1 THEN 1 ELSE 0 END), 1) AS pct_one_time
FROM
	(SELECT
	customer_key,
	MIN(order_date) AS first_order,
	COUNT(DISTINCT order_number) AS orders
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY customer_key) t
GROUP BY 1
ORDER BY 1;

--did accessory/clothing-first customers go on to buy a bike?
WITH first_orders AS (
	SELECT
	customer_key,
	MIN(order_date) AS first_order_date,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_revenue
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY customer_key
)
, entry AS (
	SELECT
	fo.customer_key,
	fo.first_order_date,
	fo.total_orders,
	fo.total_revenue,  
	CASE
		WHEN MAX(CASE WHEN p.category = 'Bikes' THEN 1 ELSE 0 END) = 1 THEN 'Bike-first'
		ELSE 'Accessory/Clothing-first'
	END AS entry_type
	FROM first_orders fo
	JOIN gold.fact_sales f
	ON f.customer_key = fo.customer_key
	AND f.order_date = fo.first_order_date
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	GROUP BY fo.customer_key, fo.first_order_date, fo.total_orders, fo.total_revenue)
,
later_bike AS (
	SELECT DISTINCT e.customer_key
	FROM entry e
	JOIN gold.fact_sales f
	ON f.customer_key = e.customer_key
	AND f.order_date > e.first_order_date
	JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE p.category = 'Bikes')

SELECT
CASE
	WHEN e.first_order_date < '2012-12-28' THEN 'Joined before range'
	ELSE 'Joined after range'
END AS join_period,
e.entry_type,
COUNT(*) AS customers,
COUNT(lb.customer_key) AS later_bought_bike,
ROUND(100.0 * COUNT(lb.customer_key) / COUNT(*), 1) AS pct_later_bought_bike,
ROUND(100.0 * COUNT(*) FILTER (WHERE e.total_orders > 1) / COUNT(*), 1) AS pct_repeat_any,   
ROUND(AVG(e.total_revenue), 2) AS avg_revenue_per_customer                                      
FROM entry e
LEFT JOIN later_bike lb
ON e.customer_key = lb.customer_key
GROUP BY join_period, e.entry_type
ORDER BY join_period, e.entry_type;




