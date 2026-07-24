/*
This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    DECLARE @batch_start_time AS DATETIME, @batch_end_time AS DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================';
        PRINT '------------------------------------------------';
        PRINT 'Loading Tables';
        PRINT '------------------------------------------------';
        TRUNCATE TABLE bronze.olist_customers_dataset;
        BULK INSERT bronze.olist_customers_dataset FROM 'C:\Users\jhonr\source\repos\olist_brazilian_ecommerce_dwh_sql\datasets\olist_customers_dataset.csv'
            WITH (FIRSTROW = 2, FORMAT = 'CSV', FIELDQUOTE = '"', FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK, CODEPAGE = '65001');
        TRUNCATE TABLE bronze.olist_geolocation_dataset;
        BULK INSERT bronze.olist_geolocation_dataset FROM 'C:\Users\jhonr\source\repos\olist_brazilian_ecommerce_dwh_sql\datasets\olist_geolocation_dataset.csv'
            WITH (FIRSTROW = 2, FORMAT = 'CSV', FIELDQUOTE = '"', FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK, CODEPAGE = '65001');
        TRUNCATE TABLE bronze.olist_order_items_dataset;
        BULK INSERT bronze.olist_order_items_dataset FROM 'C:\Users\jhonr\source\repos\olist_brazilian_ecommerce_dwh_sql\datasets\olist_order_items_dataset.csv'
            WITH (FIRSTROW = 2, FORMAT = 'CSV', FIELDQUOTE = '"', FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK, CODEPAGE = '65001');
        TRUNCATE TABLE bronze.olist_order_payments_dataset;
        BULK INSERT bronze.olist_order_payments_dataset FROM 'C:\Users\jhonr\source\repos\olist_brazilian_ecommerce_dwh_sql\datasets\olist_order_payments_dataset.csv'
            WITH (FIRSTROW = 2, FORMAT = 'CSV', FIELDQUOTE = '"', FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK, CODEPAGE = '65001');
        TRUNCATE TABLE bronze.olist_order_reviews_dataset;
        BULK INSERT bronze.olist_order_reviews_dataset FROM 'C:\Users\jhonr\source\repos\olist_brazilian_ecommerce_dwh_sql\datasets\olist_order_reviews_dataset.csv'
            WITH (FIRSTROW = 2, FORMAT = 'CSV', FIELDQUOTE = '"', FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK, CODEPAGE = '65001');
        TRUNCATE TABLE bronze.olist_orders_dataset;
        BULK INSERT bronze.olist_orders_dataset FROM 'C:\Users\jhonr\source\repos\olist_brazilian_ecommerce_dwh_sql\datasets\olist_orders_dataset.csv'
            WITH (FIRSTROW = 2, FORMAT = 'CSV', FIELDQUOTE = '"', FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK, CODEPAGE = '65001');
        TRUNCATE TABLE bronze.olist_products_dataset;
        BULK INSERT bronze.olist_products_dataset FROM 'C:\Users\jhonr\source\repos\olist_brazilian_ecommerce_dwh_sql\datasets\olist_products_dataset.csv'
            WITH (FIRSTROW = 2, FORMAT = 'CSV', FIELDQUOTE = '"', FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK, CODEPAGE = '65001');
        TRUNCATE TABLE bronze.olist_sellers_dataset;
        BULK INSERT bronze.olist_sellers_dataset FROM 'C:\Users\jhonr\source\repos\olist_brazilian_ecommerce_dwh_sql\datasets\olist_sellers_dataset.csv'
            WITH (FIRSTROW = 2, FORMAT = 'CSV', FIELDQUOTE = '"', FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK, CODEPAGE = '65001');
        TRUNCATE TABLE bronze.olist_product_category_name_translation_dataset;
        BULK INSERT bronze.olist_product_category_name_translation_dataset FROM 'C:\Users\jhonr\source\repos\olist_brazilian_ecommerce_dwh_sql\datasets\product_category_name_translation.csv'
            WITH (FIRSTROW = 2, FORMAT = 'CSV', FIELDQUOTE = '"', FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK, CODEPAGE = '65001');
        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST (DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';
    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH
END