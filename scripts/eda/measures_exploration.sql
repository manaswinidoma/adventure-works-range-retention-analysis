/*
===============================================================================
Measures Exploration
===============================================================================
Purpose:
    - Calculates the headline business measures (total sales, quantity, average
      price, orders, products and customers) and combines them into one report.
Tables used:
    - gold.fact_sales
    - gold.dim_products
    - gold.dim_customers
Notes:
    - Revenue totals include every order line.
    - All monetary values are in US dollars (USD).
===============================================================================
*/

--Find the total sales
SELECT SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

--Find how many items were sold
SELECT SUM(quantity) AS total_quantity
FROM gold.fact_sales;

--Find the average selling price (average across all order lines)
SELECT ROUND(AVG(price), 2) AS avg_price
FROM gold.fact_sales;

--Find the total number of orders
--(one order can have several lines, so count distinct order numbers)
SELECT COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;

--Find the average order value
SELECT ROUND(1.0 * SUM(sales_amount) / COUNT(DISTINCT order_number), 2) AS avg_order_value
FROM gold.fact_sales;

--Find the total number of products in the catalogue (current product versions)
SELECT COUNT(product_key) AS products_in_catalogue
FROM gold.dim_products;

--Find the number of products that have been sold at least once
SELECT COUNT(DISTINCT product_key) AS products_sold
FROM gold.fact_sales;

--Find the total number of customers in the database
SELECT COUNT(customer_key) AS customers_in_database
FROM gold.dim_customers;

--Find the number of customers who placed an order with a valid order date
--(matches the customer count used in the segment and retention analysis)
SELECT COUNT(DISTINCT customer_key) AS customers_who_ordered
FROM gold.fact_sales
WHERE order_date IS NOT NULL;


--Check: orders with more than one line
--(shows why orders must be counted with COUNT(DISTINCT order_number))
SELECT
	order_number,
	COUNT(*) AS order_lines
FROM gold.fact_sales
GROUP BY order_number
HAVING COUNT(*) > 1
ORDER BY order_lines DESC;


--Generate a report that shows all key metrics of the business
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', ROUND(AVG(price), 2) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Average Order Value', ROUND(1.0 * SUM(sales_amount) / COUNT(DISTINCT order_number), 2) FROM gold.fact_sales
UNION ALL
SELECT 'Products in Catalogue', COUNT(product_key) FROM gold.dim_products
UNION ALL
SELECT 'Products Sold', COUNT(DISTINCT product_key) FROM gold.fact_sales
UNION ALL
SELECT 'Customers in Database', COUNT(customer_key) FROM gold.dim_customers
UNION ALL
SELECT 'Customers Who Ordered', COUNT(DISTINCT customer_key) FROM gold.fact_sales WHERE order_date IS NOT NULL;