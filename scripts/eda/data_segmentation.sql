--Group the data based on a specific range
--Helps to understand the correlation between two measures.

--Segment products into cost ranges and 
--count how many products fall into each segment.
WITH product_segment AS (
	SELECT 
	product_key,
	product_name,
	cost,
	CASE
		WHEN cost < 100 THEN 'Below 100'
		WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		ELSE 'Above 1000'
	END cost_range
	FROM gold.dim_products
)
SELECT 
cost_range,
COUNT(product_key) As total_products
FROM product_segment
GROUP BY cost_range 
ORDER BY total_products DESC


--Group customers into three segments based on their spending behavior:   
--	VIP: at least 12 months of history and spending more than $5,000.   
--	Regular: at least 12 months of history but spending $5,000 or less.   
--	New: lifespan less than 12 months.

WITH customer_spending AS (
	SELECT 
		c.customer_key,
		SUM(f.sales_amount) AS total_spending,
		min(f.order_date) AS first_order,
		max(f.order_date) AS last_order,
		EXTRACT(YEAR FROM AGE(max(f.order_date), min(f.order_date))) * 12 + 
		EXTRACT(MONTH FROM AGE(max(f.order_date), min(f.order_date))) AS lifespan
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON f.customer_key=c.customer_key
	WHERE f.order_date IS NOT NULL
	GROUP BY c.customer_key
)

SELECT
customer_key,
total_spending,
lifespan,
CASE
	WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
	ELSE 'New'
END customer_segment
FROM customer_spending


--Total number of customers by each group.
WITH customer_spending AS (
	SELECT 
		c.customer_key,
		SUM(f.sales_amount) AS total_spending,
		min(f.order_date) AS first_order,
		max(f.order_date) AS last_order,
		EXTRACT(YEAR FROM AGE(max(f.order_date), min(f.order_date))) * 12 + 
		EXTRACT(MONTH FROM AGE(max(f.order_date), min(f.order_date))) AS lifespan
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON f.customer_key=c.customer_key
	WHERE f.order_date IS NOT NULL
	GROUP BY c.customer_key
)

SELECT 
customer_segment,
COUNT(customer_key) AS total_customers,
SUM(total_spending) AS revenue,
ROUND(100.0 * SUM(total_spending) / SUM(SUM(total_spending)) OVER (), 2) AS pct_revenue
FROM 
	(SELECT customer_key,total_spending,
	CASE
		WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
		ELSE 'New'
	END customer_segment
	FROM customer_spending) t
GROUP BY customer_segment
ORDER BY revenue DESC


-- One-time vs repeat buyers
WITH customer_orders AS (
    SELECT 
        customer_key,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_spending
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY customer_key
)

SELECT 
    CASE 
        WHEN total_orders = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS buyer_type,
    COUNT(customer_key) AS customers,
    ROUND(100.0 * COUNT(customer_key) / SUM(COUNT(customer_key)) OVER (), 2) AS pct_customers,
    SUM(total_spending) AS revenue,
    ROUND(100.0 * SUM(total_spending) / SUM(SUM(total_spending)) OVER (), 2) AS pct_revenue
FROM customer_orders
GROUP BY 1
ORDER BY revenue DESC;


