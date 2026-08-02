-- This script creates views in the 'gold' schema, dropping existing views if they already exist.

USE olist_brazilian_ecommerce_dwh;
GO

CREATE OR ALTER PROCEDURE gold.setup_gold_tables
AS
BEGIN
    DECLARE @batch_start_time AS DATETIME, @batch_end_time AS DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Gold Layer';
        PRINT '================================================';
        PRINT '------------------------------------------------';
        PRINT 'Loading Tables';
        PRINT '------------------------------------------------';

        PRINT 'Truncating/Inserting gold.dim_customer';
        TRUNCATE TABLE gold.dim_customer;
        INSERT INTO gold.dim_customer
        (
            customer_key,
            customer_id,
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state,
            dwh_zip_code_prefix_not_in_geolocation_flag
        )
        SELECT 
            ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
            customer_id,
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state,
            dwh_zip_code_prefix_not_in_geolocation_flag
        FROM silver.olist_customers_dataset;

        PRINT 'Truncating/Inserting gold.dim_product';
        TRUNCATE TABLE gold.dim_product;
        INSERT INTO gold.dim_product
        (
            product_key,
            product_id,
            product_category_name,
            product_category_name_english,
            product_name_lenght,
            product_description_lenght,
            product_photos_qty,
            product_weight_g,
            product_length_cm,
            product_height_cm,
            product_width_cm,
            dwh_category_name_not_in_category_flag,
            dwh_invalid_product_weight_g_flag
        )
        SELECT 
            ROW_NUMBER() OVER (ORDER BY product_id) AS product_key, 
            p.product_id,
            p.product_category_name,
            pc.product_category_name_english,
            p.product_name_lenght,
            p.product_description_lenght,
            p.product_photos_qty,
            p.product_weight_g,
            p.product_length_cm,
            p.product_height_cm,
            p.product_width_cm,
            p.dwh_category_name_not_in_category_flag,
            p.dwh_invalid_product_weight_g_flag
        FROM silver.olist_products_dataset p
        LEFT JOIN silver.olist_product_category_name_translation_dataset pc
            ON p.product_category_name = pc.product_category_name;

        PRINT 'Truncating/Inserting gold.dim_seller';
        TRUNCATE TABLE gold.dim_seller;
        INSERT INTO gold.dim_seller
        (
            seller_key,
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state,
            dwh_zip_code_prefix_not_in_geolocation_flag,
            dwh_city_quality_flag
        )
        SELECT 
            ROW_NUMBER() OVER (ORDER BY seller_id) AS seller_key,
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state,
            dwh_zip_code_prefix_not_in_geolocation_flag,
            dwh_city_quality_flag
        FROM silver.olist_sellers_dataset;

        PRINT 'Truncating/Inserting gold.dim_date';
        TRUNCATE TABLE gold.dim_date;
        WITH all_dates AS
        (
            SELECT CAST(order_purchase_timestamp AS DATE) AS order_date
            FROM silver.olist_orders_dataset

            UNION ALL

            SELECT CAST(order_approved_at AS DATE)
            FROM silver.olist_orders_dataset

            UNION ALL

            SELECT CAST(order_delivered_carrier_date AS DATE)
            FROM silver.olist_orders_dataset

            UNION ALL

            SELECT CAST(order_delivered_customer_date AS DATE)
            FROM silver.olist_orders_dataset

            UNION ALL

            SELECT CAST(order_estimated_delivery_date AS DATE)
            FROM silver.olist_orders_dataset
        ),
        date_range AS
        (
            SELECT
                MIN(order_date) AS start_date,
                MAX(order_date) AS end_date
            FROM all_dates
        ),
        calendar AS
        (
            SELECT
                DATEADD(DAY, value, start_date) AS full_date
            FROM date_range
            CROSS APPLY GENERATE_SERIES(0, DATEDIFF(DAY, start_date, end_date))
        )
        INSERT INTO gold.dim_date
        (
            date_key,
            full_date,
            [year],
            [quarter],
            [month],
            month_name,
            [day],
            day_of_week,
            day_name,
            is_weekend
        )
        SELECT
            CAST(CONVERT(VARCHAR(8), full_date, 112) AS INT) AS date_key,
            full_date,
            YEAR(full_date) AS year,
            DATEPART(QUARTER, full_date) AS quarter,
            MONTH(full_date) AS month,
            DATENAME(MONTH, full_date) AS month_name,
            DAY(full_date) AS day,
            DATEPART(WEEKDAY, full_date) AS day_of_week,
            DATENAME(WEEKDAY, full_date) AS day_name,
            CASE
                WHEN DATEPART(WEEKDAY, full_date) IN (1,7) THEN 1
                ELSE 0
            END AS is_weekend
        FROM calendar;

        PRINT 'Truncating/Inserting gold.fact_order_items';
        TRUNCATE TABLE gold.fact_order_items;
        INSERT INTO gold.fact_order_items
        (
            order_id,
            order_item_id,
            customer_id,
            customer_key,
            product_id,
            product_key,
            seller_id, 
            seller_key,
            purchase_date_key,
            order_status,
            quantity,
            price,
            freight_value,
            total_item_amount
        )
        SELECT
            oi.order_id,
            oi.order_item_id,
            o.customer_id,
            dc.customer_key,
            oi.product_id,
            dp.product_key,
            oi.seller_id, 
            ds.seller_key,
            dd.date_key AS purchase_date_key,
            o.order_status,
            1 AS quantity,
            oi.price,
            oi.freight_value,
            oi.price + oi.freight_value AS total_item_amount
        FROM silver.olist_order_items_dataset oi
        LEFT JOIN silver.olist_orders_dataset o
        ON oi.order_id = o.order_id
        LEFT JOIN gold.v_dim_customer dc
        ON o.customer_id = dc.customer_id
        LEFT JOIN gold.v_dim_product dp
        ON oi.product_id = dp.product_id
        LEFT JOIN gold.v_dim_seller ds
        ON oi.seller_id = ds.seller_id
        LEFT JOIN gold.v_dim_date dd
        ON CAST(o.order_purchase_timestamp AS DATE) = dd.full_date;

        PRINT 'Truncating/Inserting gold.fact_payments';
        TRUNCATE TABLE gold.fact_payments;
        INSERT INTO gold.fact_payments
        (
            order_id,
            customer_id,
            customer_key,
            purchase_date_key,
            payment_sequential,
            payment_type,
            payment_installments,
            payment_value,
            payment_count,
            dwh_installments_less_than_zero_flag
        )
        SELECT
            p.order_id,
            o.customer_id,
            dc.customer_key,
            dd.date_key AS purchase_date_key,
            p.payment_sequential,
            p.payment_type,
            p.payment_installments,
            p.payment_value,
            1 AS payment_count,
            p.dwh_installments_less_than_zero_flag
        FROM silver.olist_order_payments_dataset p
        LEFT JOIN silver.olist_orders_dataset o
        ON p.order_id = o.order_id
        LEFT JOIN gold.v_dim_customer dc
        ON o.customer_id = dc.customer_id
        LEFT JOIN gold.v_dim_date dd
        ON CAST(o.order_purchase_timestamp AS DATE) = dd.full_date;

        PRINT 'Truncating/Inserting gold.fact_delivery';
        TRUNCATE TABLE gold.fact_delivery;
        INSERT INTO gold.fact_delivery
        (
            order_id,
            customer_id,
            customer_key,
            purchase_date_key,
            approved_date_key,
            shipped_date_key,
            delivered_date_key,
            estimated_delivery_date_key,
            delivery_days,
            estimated_delivery_days,
            late_delivery_fla,
            dwh_missing_approval_date_flag,
            dwh_missing_carrier_date_flag,
            dwh_missing_delivery_date_flag,
            dwh_shipment_before_approval_flag,
            dwh_delivery_before_shipment_flag,
            delivery_status,
            processing_days,
            shipping_days,
            shipping_to_customer_days
        )
        SELECT
            o.order_id,
            o.customer_id,
            dc.customer_key,
            dpurchase.date_key AS purchase_date_key,
            dapproved.date_key AS approved_date_key,
            dshipped.date_key AS shipped_date_key,
            ddelivered.date_key AS delivered_date_key,
            destimated.date_key AS estimated_delivery_date_key,
            CASE
                WHEN o.order_delivered_customer_date IS NOT NULL
                THEN DATEDIFF
                (
                    DAY,
                    o.order_purchase_timestamp,
                    o.order_delivered_customer_date
                )
                ELSE NULL
            END AS delivery_days,
            CASE
                WHEN o.order_estimated_delivery_date IS NOT NULL
                THEN DATEDIFF
                (
                    DAY,
                    o.order_purchase_timestamp,
                    o.order_estimated_delivery_date
                )
                ELSE NULL
            END AS estimated_delivery_days,
            CASE
                WHEN o.order_delivered_customer_date IS NOT NULL
                AND o.order_estimated_delivery_date IS NOT NULL
                AND o.order_delivered_customer_date >
                    o.order_estimated_delivery_date
                THEN 1
                ELSE 0
            END AS late_delivery_flag,
            o.dwh_missing_approval_date_flag,
            o.dwh_missing_carrier_date_flag,
            o.dwh_missing_delivery_date_flag,
            o.dwh_shipment_before_approval_flag,
            o.dwh_delivery_before_shipment_flag,
            CASE
                WHEN o.order_status != 'delivered'
                THEN 'NOT_DELIVERED'
                WHEN o.order_delivered_customer_date IS NULL
                THEN 'INVALID_DELIVERY_DATE'
                WHEN o.order_delivered_customer_date >
                    o.order_estimated_delivery_date
                THEN 'LATE'
                ELSE 'ON_TIME'
            END AS delivery_status,
            DATEDIFF
            (
                DAY,
                o.order_purchase_timestamp,
                o.order_approved_at
            ) AS processing_days,
            DATEDIFF
            (
                DAY,
                o.order_approved_at,
                o.order_delivered_carrier_date
            ) AS shipping_days,
            DATEDIFF
            (
                DAY,
                o.order_delivered_carrier_date,
                o.order_delivered_customer_date
            ) AS shipping_to_customer_days
        FROM silver.olist_orders_dataset o
        LEFT JOIN gold.v_dim_customer dc
        ON o.customer_id = dc.customer_id
        LEFT JOIN gold.v_dim_date dpurchase
        ON CAST(o.order_purchase_timestamp AS DATE) = dpurchase.full_date
        LEFT JOIN gold.v_dim_date dapproved ON CAST(o.order_approved_at AS DATE) = dapproved.full_date
        LEFT JOIN gold.v_dim_date dshipped
        ON CAST(o.order_delivered_carrier_date AS DATE) = dshipped.full_date
        LEFT JOIN gold.v_dim_date ddelivered
        ON CAST(o.order_delivered_customer_date AS DATE) = ddelivered.full_date
        LEFT JOIN gold.v_dim_date destimated
        ON CAST(o.order_estimated_delivery_date AS DATE) = destimated.full_date;

        PRINT 'Truncating/Inserting gold.fact_reviews';
        TRUNCATE TABLE gold.fact_reviews;
        INSERT INTO gold.fact_reviews
        (
            review_id,
            order_id,
            customer_id,
            customer_key,
            review_creation_date_key,
            review_score,
            review_comment_title,
            review_comment_message,
            dwh_duplicate_review_flag,
            review_answer_date_key
        )
        SELECT
            r.review_id,
            r.order_id,
            o.customer_id,
            dc.customer_key,
            dd.date_key AS review_creation_date_key,
            r.review_score,
            r.review_comment_title,
            r.review_comment_message,
            r.dwh_duplicate_review_flag,
            danswer.date_key AS review_answer_date_key
        FROM silver.olist_order_reviews_dataset r
        LEFT JOIN silver.olist_orders_dataset o
        ON r.order_id = o.order_id
        LEFT JOIN gold.v_dim_customer dc
        ON o.customer_id = dc.customer_id
        LEFT JOIN gold.v_dim_date dd
        ON CAST(r.review_creation_date AS DATE) = dd.full_date
        LEFT JOIN gold.v_dim_date danswer
        ON CAST(r.review_answer_timestamp AS DATE) = danswer.full_date;

        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Loading Gold Layer is Completed';
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