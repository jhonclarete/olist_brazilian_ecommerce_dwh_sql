USE olist_brazilian_ecommerce_dwh;
GO

-- Check for duplicates
SELECT 
    order_id, 
    COUNT(*)
FROM bronze.olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1 OR order_id IS NULL

-- Check for whitespaces or blanks
SELECT *
FROM bronze.olist_orders_dataset
WHERE 
    TRIM(order_status) = ''
    OR order_status != TRIM(order_status)

-- Check for nulls
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_status IS NULL

-- Check if customer_id exists in Customer Table
SELECT *
FROM bronze.olist_orders_dataset o
WHERE NOT EXISTS (SELECT 1 FROM silver.olist_customers_dataset c WHERE c.customer_id = o.customer_id)

-- Check if order_status not in lower case
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_status COLLATE Latin1_General_CS_AS != LOWER(order_status);

-- Missing timestamp checks
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_purchase_timestamp IS NULL

SELECT *
FROM bronze.olist_orders_dataset
WHERE 
    order_approved_at IS NULL
    AND order_status NOT IN ('canceled', 'unavailable', 'created')






-- Approval timestamp cannot be earlier than purchase timestamp
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_approved_at < order_purchase_timestamp

-- Carrier delivery date cannot be earlier than purchase date
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_delivered_carrier_date < order_purchase_timestamp

-- Customer delivery date cannot be earlier than shipped date
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_delivered_customer_date < order_delivered_carrier_date

-- Estimated delivery date should be after purchase date
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_delivered_customer_date < order_delivered_carrier_date

