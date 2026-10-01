/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - Calculates monthly sales, the running total of sales and the running
      average order-line value, to show how the business has grown over time.
Tables used:
    - gold.fact_sales
Notes:
    - Order lines with invalid (NULL) order dates are excluded.
===============================================================================
*/

--Calculate total sales per month
--and the running total of sales over time
SELECT
month_date,
total_sales,
SUM(total_sales) OVER (ORDER BY month_date ) AS running_total_sales,
ROUND(AVG(avg_line_value) OVER (ORDER BY month_date ),2)  AS running_avg_line_value

FROM
(SELECT
	CAST(DATE_TRUNC('month', order_date) AS DATE) AS month_date,
	SUM(sales_amount) as total_sales,
	AVG(sales_amount) as avg_line_value
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY CAST(DATE_TRUNC('month', order_date) AS DATE)
	ORDER BY 1)t;