/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - Shows each product category's share of total sales, to measure how
      dependent the business is on bikes.
Tables used:
    - gold.fact_sales
    - gold.dim_products
Notes:
    - Revenue totals include every order line.
===============================================================================
*/

--Which categories contribute the most to overall sales
WITH category_sales AS 
	(SELECT
		p.category,
		SUM(f.sales_amount) AS total_sales
	FROM gold.fact_sales f 
	LEFT JOIN gold.dim_products  p
	ON f.product_key = p.product_key
	GROUP BY p.category)

SELECT 
category,
total_sales,
SUM(total_sales) OVER () AS overall_sales,
CONCAT(ROUND ((total_sales / SUM(total_sales) OVER ()) *100, 2), '%') As percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;