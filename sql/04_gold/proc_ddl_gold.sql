-- This script creates views in the 'gold' schema, dropping existing views if they already exist.

USE olist_brazilian_ecommerce_dwh;
GO

CREATE OR ALTER PROCEDURE gold.setup_gold_views
AS
BEGIN
    DECLARE @batch_start_time AS DATETIME, @batch_end_time AS DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Gold Layer';
        PRINT '================================================';
        PRINT '------------------------------------------------';
        PRINT 'Loading Views';
        PRINT '------------------------------------------------';

        EXEC sp_executesql N'
        CREATE OR ALTER VIEW gold.v_dim_customer AS
        SELECT 
            ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
            *
        FROM silver.olist_customers_dataset;
        ';

        EXEC sp_executesql N'
        CREATE OR ALTER VIEW gold.v_dim_product AS
        SELECT 
            ROW_NUMBER() OVER (ORDER BY product_id) AS product_key, 
            p.*
        FROM silver.olist_products_dataset p
        LEFT JOIN silver.olist_product_category_name_translation_dataset pc
            ON p.product_category_name = pc.product_category_name
        ';

        EXEC sp_executesql N'
        CREATE OR ALTER VIEW gold.v_dim_seller AS
        SELECT 
            ROW_NUMBER() OVER (ORDER BY seller_id) AS seller_key,
            *
        FROM silver.olist_sellers_dataset
        ';

        EXEC sp_executesql N'
        CREATE OR ALTER VIEW gold.v_dim_date AS
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
        FROM calendar
        ';

        EXEC sp_executesql N'
        CREATE OR ALTER VIEW gold.v_fact_order_items AS
        SELECT
            oi.order_id,
            oi.order_item_id,
            dc.customer_key,
            dp.product_key,
            ds.seller_key,
            dd.date_key,
            o.order_status,
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
        ON CAST(o.order_purchase_timestamp AS DATE) = dd.full_date
        ';

        EXEC sp_executesql N'
        CREATE OR ALTER VIEW gold.v_fact_payments AS
        SELECT
            p.order_id,
            dc.customer_key,
            dd.date_key,
            p.payment_sequential,
            p.payment_type,
            p.payment_installments,
            p.payment_value,
            p.dwh_installments_less_than_zero_flag
        FROM silver.olist_order_payments_dataset p
        LEFT JOIN silver.olist_orders_dataset o
        ON p.order_id = o.order_id
        LEFT JOIN gold.v_dim_customer dc
        ON o.customer_id = dc.customer_id
        LEFT JOIN gold.v_dim_date dd
        ON CAST(o.order_purchase_timestamp AS DATE) = dd.full_date
        ';

        EXEC sp_executesql N'
        CREATE OR ALTER VIEW gold.v_fact_delivery AS
        SELECT
            o.order_id,
            dc.customer_key,
            -- Date dimension keys
            dpurchase.date_key AS purchase_date_key,
            dapproved.date_key AS approved_date_key,
            dshipped.date_key AS shipped_date_key,
            ddelivered.date_key AS delivered_date_key,
            destimated.date_key AS estimated_delivery_date_key,
            -- Actual delivery days
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
            -- Expected delivery days
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
            -- Late delivery flag
            CASE
                WHEN o.order_delivered_customer_date IS NOT NULL
                AND o.order_estimated_delivery_date IS NOT NULL
                AND o.order_delivered_customer_date >
                    o.order_estimated_delivery_date
                THEN 1
                ELSE 0
            END AS late_delivery_flag,
            -- Silver data quality flags
            o.dwh_missing_approval_date_flag,
            o.dwh_missing_carrier_date_flag,
            o.dwh_missing_delivery_date_flag,
            o.dwh_shipment_before_approval_flag,
            o.dwh_delivery_before_shipment_flag,
            -- Business delivery status
            CASE
                WHEN o.order_status != ''delivered''
                THEN ''NOT_DELIVERED''
                WHEN o.order_delivered_customer_date IS NULL
                THEN ''INVALID_DELIVERY_DATE''
                WHEN o.order_delivered_customer_date >
                    o.order_estimated_delivery_date
                THEN ''LATE''
                ELSE ''ON_TIME''
            END AS delivery_status
        FROM silver.olist_orders_dataset o
        -- Customer dimension
        LEFT JOIN gold.v_dim_customer dc
        ON o.customer_id = dc.customer_id
        -- Purchase date
        LEFT JOIN gold.v_dim_date dpurchase
        ON CAST(o.order_purchase_timestamp AS DATE) = dpurchase.full_date
        -- Approval date
        LEFT JOIN gold.v_dim_date dapproved ON CAST(o.order_approved_at AS DATE) = dapproved.full_date
        -- Carrier/shipped date
        LEFT JOIN gold.v_dim_date dshipped
        ON CAST(o.order_delivered_carrier_date AS DATE) = dshipped.full_date
        -- Delivered date
        LEFT JOIN gold.v_dim_date ddelivered
        ON CAST(o.order_delivered_customer_date AS DATE) = ddelivered.full_date
        -- Estimated delivery date
        LEFT JOIN gold.v_dim_date destimated
        ON CAST(o.order_estimated_delivery_date AS DATE) = destimated.full_date
        ';

        EXEC sp_executesql N'
        CREATE OR ALTER VIEW gold.v_fact_reviews AS
        SELECT
            r.review_id,
            r.order_id,
            dc.customer_key,
            dd.date_key,
            r.review_score,
            r.review_comment_title,
            r.review_comment_message,
            r.dwh_duplicate_review_flag
        FROM silver.olist_order_reviews_dataset r
        LEFT JOIN silver.olist_orders_dataset o
        ON r.order_id = o.order_id
        LEFT JOIN gold.v_dim_customer dc
        ON o.customer_id = dc.customer_id
        LEFT JOIN gold.v_dim_date dd
        ON CAST(r.review_creation_date AS DATE) = dd.full_date';

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