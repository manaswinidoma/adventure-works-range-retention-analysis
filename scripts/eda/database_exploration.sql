/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - Lists the tables and views in the bronze, silver and gold layers and inspects
      their columns, to understand the database structure before analysis.
Tables used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

--Explore all Objects in the Database
SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA IN ('bronze','silver','gold');

--Explore all Columns in the dim_customers
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA ='gold' ;