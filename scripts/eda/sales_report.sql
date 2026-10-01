/*
===============================================================================
Sales Report
===============================================================================
Purpose:
    - Provides one row per order line, enriched with product details and
      customer segments, as a data source for the Tableau dashboard.
    - Supports monthly trends and order-level analysis such as the attach rate
      (how often bike orders include Accessories & Clothing).
Highlights:
    1. Order details: order number, order, month and year dates.
    2. Product details: name, category, subcategory and product line.
    3. Customer segments reused from gold.report_customers, so segment
       definitions live in one place only.
    4. Order-level flags:
       - line_type: Bike or Add-on (Accessories & Clothing)
       - order_has_bike: whether any line in the order is a bike
       - order_type: Bike order or Add-on only order
Tables used:
    - gold.fact_sales
    - gold.dim_products
    - gold.report_customers
Notes:
    - Order lines with invalid (NULL) order dates are excluded.
    - Dec 2010 (from 29 Dec) and Jan 2014 (to 28 Jan) are partial months.
    - All monetary values are in US dollars (USD).
===============================================================================
*/

DROP VIEW IF EXISTS gold.report_sales;
CREATE VIEW gold.report_sales AS

WITH order_lines AS (
	SELECT
		f.order_number,
		f.order_date,
		f.customer_key,
		f.product_key,
		f.sales_amount,
		f.quantity,
		f.price,
		p.product_name,
		p.category,
		p.subcategory,
		p.product_line,
		MAX(CASE WHEN p.category = 'Bikes' THEN 1 ELSE 0 END)
			OVER (PARTITION BY f.order_number) AS order_has_bike   -- 1 if any line in the order is a bike
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
		ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
)

SELECT
	--Order details
	ol.order_number,
	ol.order_date,
	CAST(DATE_TRUNC('month', ol.order_date) AS DATE) AS order_month,
	EXTRACT(YEAR FROM ol.order_date) AS order_year,

	--Product details
	ol.product_key,
	ol.product_name,
	ol.category,
	ol.subcategory,
	ol.product_line,
	CASE
		WHEN ol.category = 'Bikes' THEN 'Bike'
		ELSE 'Add-on'
	END AS line_type,

	--Order-level flags
	ol.order_has_bike,
	CASE
		WHEN ol.order_has_bike = 1 THEN 'Bike order'
		ELSE 'Add-on only order'
	END AS order_type,

	--Customer details and segments (from report_customers)
	ol.customer_key,
	rc.country,
	rc.gender,
	rc.age_group,
	rc.customer_segment,
	rc.buyer_type,
	rc.join_period,
	rc.entry_type,

	--Measures
	ol.quantity,
	ol.price,
	ol.sales_amount
FROM order_lines ol
LEFT JOIN gold.report_customers rc
	ON ol.customer_key = rc.customer_key;