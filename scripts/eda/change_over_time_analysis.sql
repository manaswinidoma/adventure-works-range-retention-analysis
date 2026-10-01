/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - Tracks monthly sales, quantity and active customers to show trends and
      seasonality over time.
Tables used:
    - gold.fact_sales
Notes:
    - Order lines with invalid (NULL) order dates are excluded.
    - Dec 2010 (from 29 Dec) and Jan 2014 (to 28 Jan) are partial months.
===============================================================================
*/

--Sales Performance over time
SELECT
	CAST(DATE_TRUNC('month', order_date) AS DATE) AS month_date,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity,
 	SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY CAST(DATE_TRUNC('month', order_date) AS DATE) 
ORDER BY 1;

