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

--Bike vs add-on share of revenue by year
--Requires gold.report_sales (run customer_report.sql and sales_report.sql first)
SELECT
	order_year,
	SUM(sales_amount) AS revenue,
	COALESCE(SUM(sales_amount) FILTER (WHERE line_type = 'Add-on'), 0) AS add_on_revenue,
	COALESCE(ROUND(100.0 * SUM(sales_amount) FILTER (WHERE line_type = 'Bike') / SUM(sales_amount), 2), 0) AS pct_bike,
	COALESCE(ROUND(100.0 * SUM(sales_amount) FILTER (WHERE line_type = 'Add-on') / SUM(sales_amount), 2), 0) AS pct_add_on
FROM gold.report_sales
GROUP BY order_year
ORDER BY order_year;

--Units vs revenue by product type and year (full years 2011-2013)
--Requires gold.report_sales (run customer_report.sql and sales_report.sql first)
SELECT
	order_year,
	line_type,
	SUM(quantity) AS units,
	SUM(sales_amount) AS revenue,
	ROUND(1.0 * SUM(sales_amount) / SUM(quantity), 2) AS revenue_per_unit,
	ROUND(100.0 * SUM(quantity) / SUM(SUM(quantity)) OVER (PARTITION BY order_year), 1) AS pct_units,
	ROUND(100.0 * SUM(sales_amount) / SUM(SUM(sales_amount)) OVER (PARTITION BY order_year), 2) AS pct_revenue
FROM gold.report_sales
WHERE order_year BETWEEN 2011 AND 2013
GROUP BY order_year, line_type
ORDER BY order_year, line_type;