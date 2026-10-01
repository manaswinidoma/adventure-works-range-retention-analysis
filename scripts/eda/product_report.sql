/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - Consolidates key product metrics and behaviours into one view, built as
      a data source for the Tableau dashboard.
Highlights:
    1. Gathers product details: name, category, subcategory, product line,
       maintenance flag and cost.
    2. Segments products by revenue into High-Performers, Mid-Range and
       Low-Performers.
    3. Aggregates product-level metrics:
       - total orders, sales, quantity and customers (unique)
       - first and last sale dates, lifespan (in months)
       - orders that also contained a bike (add-on products only)
    4. Calculates KPIs:
       - recency (months between the last sale and the end of the data)
       - average selling price
       - average order revenue
       - average monthly revenue
       - % of orders that included a bike (add-on products only)
Tables used:
    - gold.fact_sales
    - gold.dim_products
Notes:
    - Only products sold at least once appear: 130 of the 295 catalogue products.
      The 165 never sold are all 134 Components (7 have no category) plus
      9 Bikes, 15 Clothing and 7 Accessories products.
    - Order lines with invalid (NULL) order dates are excluded.
    - Recency is measured from the last order date in the data (28 Jan 2014),
      not today's date.
    - All monetary values are in US dollars (USD).
===============================================================================
*/

DROP VIEW IF EXISTS gold.report_products;
CREATE VIEW gold.report_products AS

--Reference date: the last order date in the data
WITH data_end AS (
	SELECT MAX(order_date) AS last_data_date
	FROM gold.fact_sales
)

--Base query: one row per order line, with product details
, base_query AS (
	SELECT
		f.order_number,
		f.order_date,
		f.customer_key,
		f.sales_amount,
		f.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.product_line,
		p.maintenance,
		p.cost,
		MAX(CASE WHEN p.category = 'Bikes' THEN 1 ELSE 0 END)
			OVER (PARTITION BY f.order_number) AS order_has_bike   -- 1 if any line in the order is a bike
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
		ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
)

--Product aggregations: one row per product
, product_aggregations AS (
	SELECT
		product_key,
		product_name,
		category,
		subcategory,
		product_line,
		maintenance,
		cost,
		MIN(order_date) AS first_sale_date,
		MAX(order_date) AS last_sale_date,
		EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
			+ EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan,
		COUNT(DISTINCT order_number) AS total_orders,
		COUNT(DISTINCT customer_key) AS total_customers,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		ROUND(AVG(1.0 * sales_amount / NULLIF(quantity, 0)), 2) AS avg_selling_price,
		COUNT(DISTINCT CASE WHEN order_has_bike = 1 THEN order_number END) AS orders_with_bike
	FROM base_query
	GROUP BY
		product_key,
		product_name,
		category,
		subcategory,
		product_line,
		maintenance,
		cost
)

SELECT
	--Product details
	pa.product_key,
	pa.product_name,
	pa.category,
	pa.subcategory,
	pa.product_line,
	pa.maintenance,
	pa.cost,

	--Segment
	CASE
		WHEN pa.total_sales > 50000 THEN 'High-Performer'
		WHEN pa.total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,

	--Dates
	pa.first_sale_date,
	pa.last_sale_date,
	pa.lifespan,
	EXTRACT(YEAR FROM AGE(d.last_data_date, pa.last_sale_date)) * 12
		+ EXTRACT(MONTH FROM AGE(d.last_data_date, pa.last_sale_date)) AS recency,

	--Measures
	pa.total_orders,
	pa.total_sales,
	pa.total_quantity,
	pa.total_customers,
	pa.orders_with_bike,

	--KPIs
	pa.avg_selling_price,
	CASE
		WHEN pa.total_orders = 0 THEN 0
		ELSE ROUND(1.0 * pa.total_sales / pa.total_orders, 2)
	END AS avg_order_revenue,
	CASE
		WHEN pa.lifespan = 0 THEN pa.total_sales
		ELSE ROUND(1.0 * pa.total_sales / pa.lifespan, 2)
	END AS avg_monthly_revenue,
	CASE
		WHEN pa.category = 'Bikes' THEN NULL   -- not meaningful for bikes (always 100%)
		ELSE ROUND(100.0 * pa.orders_with_bike / pa.total_orders, 1)
	END AS pct_orders_with_bike
FROM product_aggregations pa
CROSS JOIN data_end d;