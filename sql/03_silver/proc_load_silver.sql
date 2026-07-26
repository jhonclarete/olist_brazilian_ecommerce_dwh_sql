/*
This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
*/
USE olist_brazilian_ecommerce_dwh;
GO

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE @batch_start_time AS DATETIME, @batch_end_time AS DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';
        PRINT '------------------------------------------------';
        PRINT 'Loading Tables';
        PRINT '------------------------------------------------';
        
        PRINT 'Truncating/Inserting silver.olist_customers_dataset';
        TRUNCATE TABLE silver.olist_customers_dataset;
        INSERT INTO silver.olist_customers_dataset
        (
            customer_id,
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state
        )
        SELECT DISTINCT
            customer_id,
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state
        FROM bronze.olist_customers_dataset;

        PRINT 'Truncating/Inserting silver.olist_geolocation_dataset';
        TRUNCATE TABLE silver.olist_geolocation_dataset;
        WITH geolocation_dedup AS
        (
            SELECT 
                geolocation_zip_code_prefix,
                CAST(geolocation_lat AS DECIMAL(19,15)) AS geolocation_lat,
                CAST(geolocation_lng AS DECIMAL(19,15)) AS geolocation_lng,
                LOWER(TRIM(geolocation_city)) COLLATE Latin1_General_100_CI_AI AS geolocation_city,
                geolocation_state,
                ROW_NUMBER() 
                OVER
                (
                    PARTITION BY 
                        geolocation_zip_code_prefix,
                        geolocation_lat,
                        geolocation_lng,
                        LOWER(TRIM(geolocation_city)) COLLATE Latin1_General_100_CI_AI,
                        geolocation_state
                    ORDER BY geolocation_city DESC
                ) AS row_num,
                CASE
                    WHEN TRY_CAST(geolocation_lat AS DECIMAL(19,15)) NOT BETWEEN -33.75 AND 5.27 THEN 1
                    ELSE 0
                END AS dwh_geolocation_lat_out_of_range_flag,
                CASE
                    WHEN TRY_CAST(geolocation_lng AS DECIMAL(19,15)) NOT BETWEEN -73.99 AND -34.79 THEN 1
                    ELSE 0
                END AS dwh_geolocation_lng_out_of_range_flag,
                CASE
                    WHEN geolocation_city LIKE '%[0-9]%' THEN 1
                    ELSE 0
                END AS dwh_city_quality_flag
            FROM bronze.olist_geolocation_dataset
        )
        INSERT INTO silver.olist_geolocation_dataset
        (
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state,
            dwh_geolocation_lat_out_of_range_flag,
            dwh_geolocation_lng_out_of_range_flag,
            dwh_city_quality_flag
        )
        SELECT
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state,
            dwh_geolocation_lat_out_of_range_flag,
            dwh_geolocation_lng_out_of_range_flag,
            dwh_city_quality_flag
        FROM geolocation_dedup
        WHERE row_num = 1;

        /*PRINT 'Truncating/Inserting silver.olist_order_items_dataset';
        TRUNCATE TABLE silver.olist_order_items_dataset;
        INSERT INTO silver.olist_order_items_dataset
        (
            order_id,
            order_item_id,
            product_id,
            seller_id,
            shipping_limit_date,
            price,
            freight_value
        )
        SELECT DISTINCT
            order_id,
            order_item_id,
            product_id,
            seller_id,
            shipping_limit_date,
            price,
            freight_value
        FROM bronze.olist_order_items_dataset;*/

        /*PRINT 'Truncating/Inserting silver.olist_order_payments_dataset';
        TRUNCATE TABLE silver.olist_order_payments_dataset;
        INSERT INTO silver.olist_order_payments_dataset
        (
            order_id,
            payment_sequential,
            payment_type,
            payment_installments,
            payment_value
        )
        SELECT
            NULLIF(LTRIM(RTRIM(order_id)), '') AS order_id,
            payment_sequential,
            NULLIF(LTRIM(RTRIM(payment_type)), '') AS payment_type,
            payment_installments,
            TRY_CAST(payment_value AS DECIMAL(10,2)) AS payment_value
        FROM bronze.olist_order_payments_dataset;*/

        /*PRINT 'Truncating/Inserting silver.olist_order_payments_dataset';
        TRUNCATE TABLE silver.olist_order_payments_dataset;
        INSERT INTO silver.olist_order_reviews_dataset
        (
            review_id,
            order_id,
            review_score,
            review_comment_title,
            review_comment_message,
            review_creation_date,
            review_answer_timestamp
        )
        SELECT
            NULLIF(LTRIM(RTRIM(review_id)), '') AS review_id,
            NULLIF(LTRIM(RTRIM(order_id)), '') AS order_id,
            review_score,
            NULLIF(LTRIM(RTRIM(review_comment_title)), '') AS review_comment_title,
            NULLIF(LTRIM(RTRIM(review_comment_message)), '') AS review_comment_message,
            TRY_CAST(review_creation_date AS DATETIME) AS review_creation_date,
            TRY_CAST(review_answer_timestamp AS DATETIME) AS review_answer_timestamp
        FROM bronze.olist_order_reviews_dataset;*/

        /*PRINT 'Truncating/Inserting silver.olist_orders_dataset';
        TRUNCATE TABLE silver.olist_orders_dataset;
        INSERT INTO silver.olist_orders_dataset
        (
            order_id,
            customer_id,
            order_status,
            order_purchase_timestamp,
            order_approved_at,
            order_delivered_carrier_date,
            order_delivered_customer_date,
            order_estimated_delivery_date
        )
        SELECT
            NULLIF(LTRIM(RTRIM(order_id)), '') AS order_id,
            NULLIF(LTRIM(RTRIM(customer_id)), '') AS customer_id,
            NULLIF(LTRIM(RTRIM(order_status)), '') AS order_status,
            TRY_CAST(order_purchase_timestamp AS DATETIME) AS order_purchase_timestamp,
            TRY_CAST(order_approved_at AS DATETIME) AS order_approved_at,
            TRY_CAST(order_delivered_carrier_date AS DATETIME) AS order_delivered_carrier_date,
            TRY_CAST(order_delivered_customer_date AS DATETIME) AS order_delivered_customer_date,
            TRY_CAST(order_estimated_delivery_date AS DATETIME) AS order_estimated_delivery_date
        FROM bronze.olist_orders_dataset;*/

        /*PRINT 'Truncating/Inserting silver.olist_products_dataset';
        TRUNCATE TABLE silver.olist_products_dataset;
        INSERT INTO silver.olist_products_dataset
        (
            product_id,
            product_category_name,
            product_name_lenght,
            product_description_lenght,
            product_photos_qty,
            product_weight_g,
            product_length_cm,
            product_height_cm,
            product_width_cm
        )
        SELECT
            NULLIF(LTRIM(RTRIM(product_id)), '') AS product_id,
            NULLIF(LTRIM(RTRIM(product_category_name)), '') AS product_category_name,
            product_name_lenght,
            product_description_lenght,
            product_photos_qty,
            product_weight_g,
            product_length_cm,
            product_height_cm,
            product_width_cm
        FROM bronze.olist_products_dataset;*/

        PRINT 'Truncating/Inserting silver.olist_sellers_dataset';
        TRUNCATE TABLE silver.olist_sellers_dataset;
        INSERT INTO silver.olist_sellers_dataset
        (
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state,
            dwh_unknown_zip_code_prefix_flag,
		    dwh_city_quality_flag
        )
        SELECT
            s.seller_id,
            s.seller_zip_code_prefix,
            s.seller_city,
            s.seller_state,
            CASE 
                WHEN NOT EXISTS (SELECT 1 FROM silver.olist_geolocation_dataset g 
                    WHERE g.geolocation_zip_code_prefix = s.seller_zip_code_prefix) THEN 1
                ELSE 0
            END AS seller_zip_codwh_unknown_zip_code_prefix_flagde_prefix,
            CASE 
                WHEN s.seller_city LIKE '%[0-9]%' THEN 1
                ELSE 0
            END AS dwh_city_quality_flag
        FROM bronze.olist_sellers_dataset s;

        PRINT 'Truncating/Inserting silver.olist_product_category_name_translation_dataset';
        TRUNCATE TABLE silver.olist_product_category_name_translation_dataset;
        INSERT INTO silver.olist_product_category_name_translation_dataset
        (
            product_category_name,
            product_category_name_english
        )
        SELECT
            product_category_name,
            product_category_name_english
        FROM bronze.olist_product_category_name_translation_dataset;

        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Loading silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST (DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';
    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURED DURING LOADING silver LAYER';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH
END