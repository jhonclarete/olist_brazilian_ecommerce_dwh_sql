USE olist_brazilian_ecommerce_dwh;
GO

-- Check for Nulls, blanks or whitespaces
SELECT *
FROM silver.olist_order_payments_dataset
WHERE 
    order_id IS NULL
    OR TRIM(order_id) = ''
    OR order_id != TRIM(order_id)

-- Check for duplicates
SELECT 
    order_id, 
    payment_sequential,
    COUNT(*)
FROM silver.olist_order_payments_dataset
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1

-- Check if payment_type not in lower case
SELECT * 
FROM silver.olist_order_payments_dataset
WHERE payment_type COLLATE Latin1_General_CS_AS != LOWER(payment_type)

-- Check if payment_installments is not less than or equal 0
-- ERROR
SELECT * 
FROM silver.olist_order_payments_dataset
WHERE CAST(payment_installments AS int) <= 0

-- Check if payment_value is not less than 0
SELECT * 
FROM silver.olist_order_payments_dataset
WHERE CAST(payment_value AS decimal(16, 2)) < 0