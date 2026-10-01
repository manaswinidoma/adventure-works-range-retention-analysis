--Calculate total sales per month
--and the running total of sales over time
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date ) AS running_total_sales,
ROUND(AVG(avg_price) OVER (ORDER BY order_date ),2)  AS moving_average_price

FROM
(SELECT
	CAST(DATE_TRUNC('month', order_date) AS DATE) AS order_date,
	SUM(sales_amount) as total_sales,
	AVG(sales_amount) as avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY CAST(DATE_TRUNC('month', order_date) AS DATE)
	ORDER BY 1)t
