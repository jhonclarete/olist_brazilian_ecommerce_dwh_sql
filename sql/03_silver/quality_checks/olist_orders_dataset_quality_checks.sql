USE olist_brazilian_ecommerce_dwh;
GO

-- order_id

-- Check for Nulls
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_id IS NULL

-- Check blank values
SELECT *
FROM bronze.olist_orders_dataset
WHERE TRIM(order_id) = ''

-- Check for whitespaces
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_id != TRIM(order_id)

-- Check length of seller_id
SELECT *
FROM bronze.olist_orders_dataset
WHERE LEN(order_id) != 32

-- Check for non-numeric values
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_id LIKE '%^[0-9a-f]{32}$%'

-- Check for duplicates
SELECT COUNT(*) FROM bronze.olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1


-- customer_id

-- Check for Nulls
SELECT *
FROM bronze.olist_orders_dataset
WHERE customer_id IS NULL

-- Check blank values
SELECT *
FROM bronze.olist_orders_dataset
WHERE TRIM(customer_id) = ''

-- Check for whitespaces
SELECT *
FROM bronze.olist_orders_dataset
WHERE customer_id != TRIM(customer_id)

-- Check length of seller_id
SELECT *
FROM bronze.olist_orders_dataset
WHERE LEN(customer_id) != 32

-- Check for non-numeric values
SELECT *
FROM bronze.olist_orders_dataset
WHERE customer_id LIKE '%^[0-9a-f]{32}$%'

-- Check for duplicates
SELECT COUNT(*) FROM bronze.olist_orders_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1

-- Check if customer_id not exists in customer dataset
SELECT *
FROM bronze.olist_orders_dataset
WHERE customer_id NOT IN (SELECT customer_id FROM silver.olist_customers_dataset)


-- order_status

-- Check for Nulls
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_status IS NULL

-- Check invalid status value
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_status NOT IN ('approved', 'canceled',
'created',
'delivered',
'invoiced',
'processing',
'shipped',
'unavailable')

-- Check for upperrcases
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_status COLLATE Latin1_General_CS_AS = UPPER(order_status);


-- order_purchase_timestamp

-- Check for Nulls
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_purchase_timestamp IS NULL

-- Check for datetime format
SELECT *
FROM bronze.olist_orders_dataset
WHERE TRY_CAST(order_purchase_timestamp AS DATETIME2) IS NULL

-- Should not be before Olist business start date (2016)
SELECT *
FROM bronze.olist_orders_dataset
WHERE YEAR(CAST(order_purchase_timestamp AS DATETIME2)) < 2016

-- Cannot be greater than current date
SELECT *
FROM bronze.olist_orders_dataset
WHERE CAST(order_purchase_timestamp AS DATETIME2) > GETDATE()


-- order_approved_at

-- Must be >= order_purchase_timestamp
SELECT *
FROM bronze.olist_orders_dataset
WHERE CAST(order_approved_at AS DATETIME2) < CAST(order_purchase_timestamp AS DATETIME2)

-- Cannot be greater than current date
SELECT *
FROM bronze.olist_orders_dataset
WHERE CAST(order_approved_at AS DATETIME2) > GETDATE()

-- Not Null if status is approved
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_approved_at = 'approved' AND order_approved_at IS NULL

-- Check for datetime format
SELECT *
FROM bronze.olist_orders_dataset
WHERE TRY_CAST(order_approved_at AS DATETIME2) IS NULL


-- order_delivered_carrier_date

-- Should exist when status is shipped or delivered
SELECT *
FROM bronze.olist_orders_dataset
WHERE (order_delivered_carrier_date = 'shipped' OR order_delivered_carrier_date = 'delivered') AND order_approved_at IS NULL

-- Must be >= order_approved_at
SELECT *
FROM bronze.olist_orders_dataset
WHERE CAST(order_delivered_carrier_date AS DATETIME2) < CAST(order_approved_at AS DATETIME2)

-- Cannot be greater than current date
SELECT *
FROM bronze.olist_orders_dataset
WHERE CAST(order_delivered_carrier_date AS DATETIME2) > GETDATE()

-- Check for datetime format
SELECT *
FROM bronze.olist_orders_dataset
WHERE TRY_CAST(order_delivered_carrier_date AS DATETIME2) IS NULL


-- order_delivered_customer_date

-- Should exist only when status = delivered
SELECT *
FROM bronze.olist_orders_dataset
WHERE (order_delivered_customer_date = 'delivered') AND order_approved_at IS NULL

-- Must be >= order_delivered_carrier_date
SELECT *
FROM bronze.olist_orders_dataset
WHERE CAST(order_delivered_customer_date AS DATETIME2) < CAST(order_delivered_carrier_date AS DATETIME2)

-- Cannot be greater than current date
SELECT *
FROM bronze.olist_orders_dataset
WHERE CAST(order_delivered_customer_date AS DATETIME2) > GETDATE()

-- Delivery date should not be before purchase date
SELECT *
FROM bronze.olist_orders_dataset
WHERE CAST(order_delivered_customer_date AS DATETIME2) < CAST(order_purchase_timestamp AS DATETIME2)


-- order_estimated_delivery_date

-- Must not be NULL
SELECT *
FROM bronze.olist_orders_dataset
WHERE order_estimated_delivery_date IS NULL

-- Should be >= purchase date
SELECT *
FROM bronze.olist_orders_dataset
WHERE CAST(order_estimated_delivery_date AS DATETIME2) < CAST(order_purchase_timestamp AS DATETIME2)

-- Estimated delivery should be before or equal to actual delivery (when delivered)
SELECT *
FROM bronze.olist_orders_dataset
WHERE CAST(order_estimated_delivery_date AS DATETIME2) < CAST(order_delivered_customer_date AS DATETIME2)

-- Check for datetime format
SELECT *
FROM bronze.olist_orders_dataset
WHERE TRY_CAST(order_estimated_delivery_date AS DATETIME2) IS NULL