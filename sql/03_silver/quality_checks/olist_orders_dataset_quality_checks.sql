USE olist_brazilian_ecommerce_dwh;
GO

-- order_id
-- Check for Nulls
SELECT *
FROM silver.olist_orders_dataset
WHERE order_id IS NULL

-- Check blank values
SELECT *
FROM silver.olist_orders_dataset
WHERE TRIM(order_id) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_orders_dataset
WHERE order_id != TRIM(order_id)

-- Check length of seller_id
SELECT *
FROM silver.olist_orders_dataset
WHERE LEN(order_id) != 32

-- Check for non-numeric values
SELECT *
FROM silver.olist_orders_dataset
WHERE order_id LIKE '%^[0-9a-f]{32}$%'

-- Check for duplicates
SELECT COUNT(*) FROM silver.olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1


-- customer_id
-- Check for Nulls
SELECT *
FROM silver.olist_orders_dataset
WHERE customer_id IS NULL

-- Check blank values
SELECT *
FROM silver.olist_orders_dataset
WHERE TRIM(customer_id) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_orders_dataset
WHERE customer_id != TRIM(customer_id)

-- Check length of seller_id
SELECT *
FROM silver.olist_orders_dataset
WHERE LEN(customer_id) != 32

-- Check for non-numeric values
SELECT *
FROM silver.olist_orders_dataset
WHERE customer_id LIKE '%^[0-9a-f]{32}$%'

-- Check for duplicates
SELECT COUNT(*) FROM silver.olist_orders_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1

-- Check if customer_id not exists in customer dataset
SELECT *
FROM silver.olist_orders_dataset o
WHERE NOT EXISTS (SELECT 1 FROM silver.olist_customers_dataset c WHERE c.customer_id = o.customer_id)


-- order_status
-- Check for Nulls
SELECT *
FROM silver.olist_orders_dataset
WHERE order_status IS NULL

-- Check invalid status value
SELECT *
FROM silver.olist_orders_dataset
WHERE order_status NOT IN ('approved', 'canceled',
'created',
'delivered',
'invoiced',
'processing',
'shipped',
'unavailable')

-- Check for upperrcases
SELECT *
FROM silver.olist_orders_dataset
WHERE order_status COLLATE Latin1_General_CS_AS = UPPER(order_status);


-- order_purchase_timestamp

-- Check for Nulls
SELECT *
FROM silver.olist_orders_dataset
WHERE order_purchase_timestamp IS NULL

-- Check for datetime format
SELECT *
FROM silver.olist_orders_dataset
WHERE TRY_CAST(order_purchase_timestamp AS DATETIME2) IS NULL

-- Should not be before Olist business start date (2016)
SELECT *
FROM silver.olist_orders_dataset
WHERE YEAR(order_purchase_timestamp) < 2016

-- Cannot be greater than current date
SELECT *
FROM silver.olist_orders_dataset
WHERE order_purchase_timestamp > GETDATE()


-- order_approved_at
-- Must be >= order_purchase_timestamp
SELECT *
FROM silver.olist_orders_dataset
WHERE order_approved_at < order_purchase_timestamp

-- Cannot be greater than current date
SELECT *
FROM silver.olist_orders_dataset
WHERE order_approved_at > GETDATE()

-- Not Null if status is approved
SELECT *
FROM silver.olist_orders_dataset
WHERE order_status = 'approved' AND order_approved_at IS NULL

-- Check for datetime format
SELECT *
FROM silver.olist_orders_dataset
WHERE TRY_CAST(order_approved_at AS DATETIME2) IS NULL AND order_status = 'approved'


-- order_delivered_carrier_date
-- Should exist when status is delivered or shipped
-- ERROR
SELECT *
FROM silver.olist_orders_dataset
WHERE (order_status = 'delivered' OR order_status = 'shipped') AND order_delivered_carrier_date IS NULL

-- Must be >= order_approved_at
-- ERROR
SELECT *
FROM silver.olist_orders_dataset
WHERE order_delivered_carrier_date < order_approved_at

-- Cannot be greater than current date
SELECT *
FROM silver.olist_orders_dataset
WHERE order_delivered_carrier_date > GETDATE()

-- Check for datetime format
SELECT *
FROM silver.olist_orders_dataset
WHERE order_delivered_carrier_date IS NULL AND (order_status = 'delivered' OR order_status = 'shipped')


-- order_delivered_customer_date
-- Should exist only when status = delivered
-- ERROR
SELECT *
FROM silver.olist_orders_dataset
WHERE (order_status = 'delivered') AND order_delivered_customer_date IS NULL

-- Must be >= order_delivered_carrier_date
-- ERROR
SELECT *
FROM silver.olist_orders_dataset
WHERE order_delivered_customer_date < order_delivered_carrier_date

-- Cannot be greater than current date
SELECT *
FROM silver.olist_orders_dataset
WHERE order_delivered_customer_date > GETDATE()

-- Delivery date should not be before purchase date
SELECT *
FROM silver.olist_orders_dataset
WHERE order_delivered_customer_date < order_purchase_timestamp


-- order_estimated_delivery_date
-- Must not be NULL
SELECT *
FROM silver.olist_orders_dataset
WHERE order_estimated_delivery_date IS NULL

-- Should be >= purchase date
SELECT *
FROM silver.olist_orders_dataset
WHERE order_estimated_delivery_date < order_purchase_timestamp

-- Estimated delivery >= Actual delivery (when delivered)
SELECT *
FROM silver.olist_orders_dataset
WHERE order_estimated_delivery_date < order_delivered_customer_date

-- Check for datetime format
SELECT *
FROM silver.olist_orders_dataset
WHERE TRY_CAST(order_estimated_delivery_date AS DATETIME2) IS NULL