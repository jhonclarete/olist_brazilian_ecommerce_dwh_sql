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

        PRINT 'Truncating/Inserting silver.olist_geolocation_dataset';
        TRUNCATE TABLE silver.olist_geolocation_dataset;
        INSERT INTO silver.olist_geolocation_dataset
        (
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state,
            dwh_lat_outside_brazil_flag,
            dwh_lng_outside_brazil_flag
        )
        SELECT DISTINCT
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            LOWER(
                REPLACE(
                REPLACE(
                REPLACE(
                REPLACE(
                REPLACE(
                REPLACE(
                        TRANSLATE(
                            TRIM(geolocation_city),
                            'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                            'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC'
                    ), 
                '''', ' '), 
                '4º centenario', 'quarto centenario'), 
                '4o. centenario', 'quarto centenario'),
                'lambari d%26apos%3boeste', 'lambari d oeste'),
                'sao joao do pau d%26apos%3balho', 'sao joao do pau d alho'),
                'maceia³', 'maceio')) AS geolocation_city,
            geolocation_state,
            CASE
                WHEN 
                    CAST(geolocation_lat AS decimal(19, 15)) < -33.75 
                    OR CAST(geolocation_lat AS decimal(19, 15)) > 5.27
                THEN 1
                ELSE 0
            END AS dwh_lat_outside_brazil_flag,
            CASE
                WHEN 
                    CAST(geolocation_lng AS decimal(19, 15)) < -73.98 
                    OR CAST(geolocation_lng AS decimal(19, 15)) > -28.85
                THEN 1
                ELSE 0
            END AS dwh_lng_outside_brazil_flag
        FROM bronze.olist_geolocation_dataset
        
        PRINT 'Truncating/Inserting silver.olist_customers_dataset';
        TRUNCATE TABLE silver.olist_customers_dataset;
        INSERT INTO silver.olist_customers_dataset
        (
            customer_id,
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state,
            dwh_zip_code_prefix_not_in_geolocation_flag
        )
        SELECT
            c.customer_id,
            c.customer_unique_id,
            c.customer_zip_code_prefix,
            c.customer_city,
            c.customer_state,
            CASE
                WHEN NOT EXISTS (SELECT 1 FROM silver.olist_geolocation_dataset g 
                    WHERE TRIM(g.geolocation_zip_code_prefix) = TRIM(c.customer_zip_code_prefix)) THEN 1
                ELSE 0
            END AS dwh_zip_code_prefix_not_in_geolocation_flag
        FROM bronze.olist_customers_dataset c;

        PRINT 'Truncating/Inserting silver.olist_sellers_dataset';
        TRUNCATE TABLE silver.olist_sellers_dataset;
        INSERT INTO silver.olist_sellers_dataset
        (
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state,
            dwh_zip_code_prefix_not_in_geolocation_flag,
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
            END AS dwh_zip_code_prefix_not_in_geolocation_flag,
            CASE 
                WHEN s.seller_city LIKE '%[0-9]%' THEN 1
                ELSE 0
            END AS dwh_city_quality_flag
        FROM bronze.olist_sellers_dataset s;

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
            order_estimated_delivery_date,
            dwh_missing_order_id_flag,
		    dwh_missing_customer_id_flag,
		    dwh_missing_order_status_flag,
		    dwh_customer_id_not_in_customer_table_flag,
		    dwh_invalid_order_status_flag,
            dwh_missing_purchase_date_flag,
            dwh_missing_estimated_delivery_date_flag,
            dwh_payment_not_approved_flag,
            dwh_not_shipped_flag,
            dwh_not_delivered_flag,
            dwh_delivered_flag,
            dwh_late_delivery_flag,
            dwh_early_delivery_flag,
            dwh_on_time_delivery_flag
        )
        SELECT
            o.order_id,
            o.customer_id,
            o.order_status,
            o.order_purchase_timestamp,
            o.order_approved_at,
            o.order_delivered_carrier_date,
            o.order_delivered_customer_date,
            o.order_estimated_delivery_date,
            CASE
                WHEN o.order_id IS NULL OR TRIM(o.order_id) = '' THEN 1
                ELSE 0
            END AS dwh_missing_order_id_flag,
            CASE
                WHEN o.customer_id IS NULL OR TRIM(o.customer_id) = '' THEN 1
                ELSE 0
            END AS dwh_missing_customer_id_flag,
            CASE
                WHEN o.order_status IS NULL OR TRIM(o.order_status) = '' THEN 1
                ELSE 0
            END AS dwh_missing_order_status_flag,
            CASE 
                WHEN NOT EXISTS (SELECT 1 FROM silver.olist_customers_dataset c 
                    WHERE c.customer_id = o.customer_id) THEN 1
                ELSE 0
            END AS dwh_customer_id_not_in_customer_table_flag,
            CASE
                WHEN o.order_status NOT IN ('approved', 'canceled',
                                            'created',
                                            'delivered',
                                            'invoiced',
                                            'processing',
                                            'shipped',
                                            'unavailable') THEN 1
                ELSE 0
            END AS dwh_invalid_order_status_flag,
            CASE
                WHEN o.order_purchase_timestamp IS NULL THEN 1
                ELSE 0
            END AS dwh_missing_purchase_date_flag,
            CASE
                WHEN o.order_estimated_delivery_date IS NULL THEN 1
                ELSE 0
            END AS dwh_missing_estimated_delivery_date_flag,
            CASE
                WHEN o.order_approved_at IS NULL THEN 1
                ELSE 0
            END AS dwh_payment_not_approved_flag,
            CASE
                WHEN o.order_delivered_carrier_date IS NULL THEN 1
                ELSE 0
            END AS dwh_not_shipped_flag,
            CASE
                WHEN o.order_delivered_customer_date IS NULL THEN 1
                ELSE 0
            END AS dwh_not_delivered_flag,
            CASE
                WHEN o.order_delivered_customer_date IS NOT NULL THEN 1
                ELSE 0
            END AS dwh_delivered_flag,
            CASE
                WHEN o.order_delivered_customer_date > order_estimated_delivery_date THEN 1
                ELSE 0
            END AS dwh_late_delivery_flag,
            CASE
                WHEN o.order_delivered_customer_date < order_estimated_delivery_date THEN 1
                ELSE 0
            END AS dwh_early_delivery_flag,
            CASE
                WHEN o.order_delivered_customer_date <= order_estimated_delivery_date THEN 1
                ELSE 0
            END AS dwh_on_time_delivery_flag
        FROM bronze.olist_orders_dataset o;

        PRINT 'Truncating/Inserting silver.olist_products_dataset';
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
            product_width_cm,
            dwh_missing_product_id_flag,
            dwh_missing_category_flag,
            dwh_invalid_dimension_flag,
            dwh_invalid_weight_flag,
            dwh_category_name_not_in_category
        )
        SELECT
            p.product_id,
            p.product_category_name,
            p.product_name_lenght,
            p.product_description_lenght,
            p.product_photos_qty,
            p.product_weight_g,
            p.product_length_cm,
            p.product_height_cm,
            p.product_width_cm,
            CASE 
                WHEN p.product_id IS NULL OR TRIM(p.product_id) = ''
                THEN 1 
                ELSE 0 
            END AS dwh_missing_product_id_flag,
            CASE 
                WHEN p.product_category_name IS NULL OR TRIM(p.product_category_name) = ''
                THEN 1 
                ELSE 0 
            END AS dwh_missing_category_flag,
            CASE
                WHEN p.product_length_cm IS NULL
                OR p.product_height_cm IS NULL
                OR p.product_width_cm IS NULL
                OR p.product_length_cm <= 0
                OR p.product_height_cm <= 0
                OR p.product_width_cm <= 0
                THEN 1
                ELSE 0
            END AS dwh_invalid_dimension_flag,
            CASE
                WHEN p.product_weight_g <= 0
                THEN 1
                ELSE 0
            END AS dwh_invalid_weight_flag,
            CASE 
                WHEN NOT EXISTS (SELECT 1 FROM silver.olist_product_category_name_translation_dataset c
                    WHERE c.product_category_name = p.product_category_name) THEN 1
                ELSE 0
            END AS dwh_category_name_not_in_category

        FROM bronze.olist_products_dataset p;

        PRINT 'Truncating/Inserting silver.olist_order_items_dataset';
        TRUNCATE TABLE silver.olist_order_items_dataset;
        INSERT INTO silver.olist_order_items_dataset
        (
            order_id,
            order_item_id,
            product_id,
            seller_id,
            shipping_limit_date,
            price,
            freight_value,
            dwh_missing_order_id_flag,
            dwh_missing_order_item_id_flag,
            dwh_missing_product_id_flag,
            dwh_missing_seller_id_flag,
            dwh_invalid_price_flag,
            dwh_invalid_freight_value_flag,
            dwh_product_id_not_in_product_flag,
		    dwh_seller_id_not_in_seller_flag
        )
        SELECT
            oi.order_id,
            oi.order_item_id,
            oi.product_id,
            oi.seller_id,
            oi.shipping_limit_date,
            oi.price,
            oi.freight_value,
            CASE
                WHEN oi.order_id IS NULL OR TRIM(oi.order_id) = '' THEN 1
                ELSE 0
            END AS dwh_missing_order_id_flag,
            CASE
                WHEN oi.order_item_id IS NULL THEN 1
                ELSE 0
            END AS dwh_missing_order_item_id_flag,
            CASE
                WHEN oi.product_id IS NULL OR TRIM(oi.product_id) = '' THEN 1
                ELSE 0
            END AS dwh_missing_product_id_flag,
            CASE
                WHEN oi.seller_id IS NULL OR TRIM(oi.seller_id) = '' THEN 1
                ELSE 0
            END AS dwh_missing_seller_id_flag,
            CASE
                WHEN CAST(oi.price AS DECIMAL(16, 2)) IS NULL OR CAST(oi.price AS DECIMAL(16, 2)) <= 0 THEN 1
                ELSE 0
            END AS dwh_invalid_price_flag,
            CASE
                WHEN CAST(oi.freight_value AS DECIMAL(16, 2)) IS NULL OR CAST(oi.freight_value AS DECIMAL(16, 2)) <= 0 THEN 1
                ELSE 0
            END AS dwh_invalid_freight_flag,
            CASE 
                WHEN NOT EXISTS (SELECT 1 FROM silver.olist_products_dataset p
                    WHERE p.product_id = oi.product_id) THEN 1
                ELSE 0
            END AS dwh_product_id_not_in_product_flag,
            CASE 
                WHEN NOT EXISTS (SELECT 1 FROM silver.olist_sellers_dataset s
                    WHERE s.seller_id = oi.seller_id) THEN 1
                ELSE 0
            END AS dwh_seller_id_not_in_seller_flag
        FROM bronze.olist_order_items_dataset oi;

        /PRINT 'Truncating/Inserting silver.olist_order_payments_dataset';
        TRUNCATE TABLE silver.olist_order_payments_dataset
        INSERT INTO silver.olist_order_payments_dataset
        (
            order_id,
            payment_sequential,
            payment_type,
            payment_installments,
            payment_value,
            dwh_missing_order_id_flag,
            dwh_invalid_payment_type_flag,
            dwh_invalid_installments_flag,
            dwh_invalid_payment_flag,
            dwh_order_id_not_in_orders_flag
        )
        SELECT
            order_id,
            payment_sequential,
            payment_type,
            payment_installments,
            payment_value,
            CASE 
                WHEN op.order_id IS NULL OR TRIM(op.order_id) = ''
                THEN 1
                ELSE 0
            END AS dwh_missing_order_id_flag,
            CASE
                WHEN LOWER(op.payment_type) NOT IN 
                (
                    'credit_card',
                    'boleto',
                    'voucher',
                    'debit_card',
                    'not_defined'
                )
                THEN 1
                ELSE 0
            END AS dwh_invalid_payment_type_flag,
            CASE
                WHEN CAST(op.payment_installments AS INT) <= 0
                THEN 1
                ELSE 0
            END AS dwh_invalid_installments_flag,
            CASE
                WHEN CAST(op.payment_value AS DECIMAL(16, 2)) <= 0
                THEN 1
                ELSE 0
            END AS dwh_invalid_payment_flag,
            CASE 
                WHEN NOT EXISTS (SELECT 1 FROM silver.olist_orders_dataset o
                    WHERE o.order_id = op.order_id) THEN 1
                ELSE 0
            END AS dwh_order_id_not_in_orders_flag

        FROM bronze.olist_order_payments_dataset op;

        PRINT 'Truncating/Inserting silver.olist_order_reviews_dataset';
        TRUNCATE TABLE silver.olist_order_reviews_dataset;
        INSERT INTO silver.olist_order_reviews_dataset
        (
            review_id,
            order_id,
            review_score,
            review_comment_title,
            review_comment_message,
            review_creation_date,
            review_answer_timestamp,

        )
        SELECT
            orev.review_id,
            orev.order_id,
            orev.review_score,
            orev.review_comment_title,
            orev.review_comment_message,
            orev.review_creation_date,
            orev.review_answer_timestamp
        FROM bronze.olist_order_reviews_dataset orev;*/

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