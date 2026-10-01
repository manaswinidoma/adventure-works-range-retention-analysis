--Compare current value with target value.
--Helps measure success and compare performance.

--Anlayse the yearly performance of products by comparing
--each product's sales to both its average sales performance
--and the previous year's sales
WITH yearly_product_sales AS (
	SELECT 
		EXTRACT(YEAR FROM f.order_date) AS order_year,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
	ON f.product_key = p.product_key
	WHERE order_date IS NOT NULL
	GROUP BY EXTRACT(YEAR FROM f.order_date),p.product_name
)

SELECT 
order_year,
product_name,
current_sales,

--Year-Over-Year analysis

LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) AS py_sales, 
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) AS diff_py,
CASE
	WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) > 0 THEN 'Increase'
	WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) < 0 THEN 'Decrease'
	ELSE 'No Change '
END py_change,
ROUND(AVG(current_sales) OVER(PARTITION BY product_name),2) AS avg_sales_product,
current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name),2) AS diff_avg,
CASE 
	WHEN current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name),2) > 0 THEN 'Above Avg'
	WHEN current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name),2) < 0 THEN 'Below Avg'
	ELSE 'Avg'
END avg_change
FROM yearly_product_sales
ORDER BY product_name,order_year
