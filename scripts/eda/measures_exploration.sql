--Find the Total Sales
SELECT SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

--Find how many items are sold
SELECT SUM(quantity) AS total_quantity
FROM gold.fact_sales;

--Find the average selling price
SELECT ROUND(AVG(price),2) AS avg_price
FROM gold.fact_sales;

--Find the Total number of  Orders
SELECT COUNT(order_number) AS total_orders
FROM gold.fact_sales;

SELECT COUNT( DISTINCT order_number) AS total_orders
FROM gold.fact_sales;

SELECT order_number,COUNT(*)
FROM gold.fact_sales  
GROUP BY order_number 
HAVING COUNT(*) >1;

--Find the Total number of products
SELECT COUNT( product_key) AS total_products
FROM gold.dim_products;

SELECT COUNT(DISTINCT product_key) AS total_products
FROM gold.dim_products;

--Find the Total number of customers that 
SELECT COUNT(customer_key) AS total_customers
FROM gold.dim_customers;

SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM gold.dim_customers;

--Find the Total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) FROM gold.fact_sales;

--Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' as measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' as measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price' as measure_name, ROUND(AVG(price),2) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total No.of Orders' as measure_name, COUNT( DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total No.of Products' as measure_name, COUNT(product_name) AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'Total No.of Customers' as measure_name, COUNT(customer_key) AS measure_value FROM gold.dim_customers


