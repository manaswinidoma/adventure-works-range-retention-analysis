/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - Ranks products, subcategories and customers by revenue to identify the
      best and worst performers.
Tables used:
    - gold.fact_sales
    - gold.dim_products
    - gold.dim_customers
Notes:
    - Revenue totals include every order line.
===============================================================================
*/

--Which 5 products generated highest revenue? 
SELECT * 
FROM
	(SELECT 
		p.product_name,
		SUM(f.sales_amount) AS total_revenue,
		ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC ) as rnk_products
	FROM gold.fact_sales AS f 
	LEFT JOIN gold.dim_products AS p
	ON f.product_key = p.product_key
	GROUP BY p.product_name )t
WHERE rnk_products <=5;

--What are the 5 worst-performing products in terms of sales?
SELECT 
	p.product_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f 
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY 2 ASC LIMIT 5;

--Top 5 subcategories
SELECT 
	p.subcategory,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f 
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key
GROUP BY p.subcategory
ORDER BY 2 DESC LIMIT 5;

--Find top 10 customers who have generated the highest revenue
SELECT 
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue_by_customer
FROM gold.fact_sales AS f 
LEFT JOIN gold.dim_customers AS c
ON f.customer_key=c.customer_key
GROUP BY c.customer_key,
c.first_name,
c.last_name
ORDER BY 4 DESC LIMIT 10;


