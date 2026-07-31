USE olist_brazilian_ecommerce_dwh;
GO

-- Check for duplicates
SELECT 
    order_id, 
    COUNT(*)
FROM silver.olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1 OR order_id IS NULL

-- Check for whitespaces or blanks
SELECT *
FROM silver.olist_orders_dataset
WHERE 
    TRIM(order_status) = ''
    OR order_status != TRIM(order_status)

-- Check for nulls
SELECT *
FROM silver.olist_orders_dataset
WHERE order_status IS NULL

-- Check if customer_id exists in Customer Table
SELECT *
FROM silver.olist_orders_dataset o
WHERE NOT EXISTS (SELECT 1 FROM silver.olist_customers_dataset c WHERE c.customer_id = o.customer_id)

-- Check if order_status not in lower case
SELECT *
FROM silver.olist_orders_dataset
WHERE order_status COLLATE Latin1_General_CS_AS != LOWER(order_status);

-- Missing purchase timestamp
SELECT *
FROM silver.olist_orders_dataset
WHERE order_purchase_timestamp IS NULL

-- Missing Approval timestamp
SELECT *
FROM silver.olist_orders_dataset
WHERE 
    order_approved_at IS NULL
    AND order_status NOT IN ('canceled', 'unavailable', 'created')

-- Missing Carrier timestamp
SELECT *
FROM silver.olist_orders_dataset
WHERE
    order_delivered_carrier_date IS NULL
    AND order_status IN ('delivered', 'shipped')

-- Missing Delivery date
SELECT *
FROM silver.olist_orders_dataset
WHERE
    order_delivered_customer_date IS NULL
    AND order_status IN ('delivered')

-- Missing Estimated Delivery Date
SELECT *
FROM silver.olist_orders_dataset
WHERE
    order_estimated_delivery_date IS NULL

-- Purchase before approval
SELECT *
FROM silver.olist_orders_dataset
WHERE CAST(order_approved_at AS datetime2) < CAST(order_purchase_timestamp AS datetime2) 

-- Approval before Shipment
SELECT *
FROM silver.olist_orders_dataset
WHERE CAST(order_delivered_carrier_date AS datetime2) < CAST(order_approved_at AS datetime2) 

-- Shipment before Delivery
SELECT *
FROM silver.olist_orders_dataset
WHERE CAST(order_delivered_customer_date AS datetime2) < CAST(order_delivered_carrier_date AS datetime2) 

-- Purchase before delivery
SELECT *
FROM silver.olist_orders_dataset
WHERE CAST(order_delivered_customer_date AS datetime2) < CAST(order_purchase_timestamp AS datetime2) 