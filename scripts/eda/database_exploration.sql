--Explore all Objects in the Database
SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA IN ('bronze','silver','gold')

--Explore all Columns in the Database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'