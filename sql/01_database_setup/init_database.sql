/*
This script initializes the Olist Brazilian E-Commerce Data Warehouse by:
    - Dropping the existing 'olist_brazilian_ecommerce_dwh' database (if it exists)
    - Creating a new 'olist_brazilian_ecommerce_dwh' database
    - Creating the Bronze, Silver, and Gold schemas to support a medallion architecture for data ingestion, transformation, and analytics.
*/

USE master;
GO

-- Drop and recreate the 'olist_brazilian_ecommerce_dwh' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'olist_brazilian_ecommerce_dwh')
BEGIN
    ALTER DATABASE olist_brazilian_ecommerce_dwh SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE olist_brazilian_ecommerce_dwh;
END;
GO

-- Create the 'olist_brazilian_ecommerce_dwh' database
CREATE DATABASE olist_brazilian_ecommerce_dwh;
GO

USE olist_brazilian_ecommerce_dwh;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO