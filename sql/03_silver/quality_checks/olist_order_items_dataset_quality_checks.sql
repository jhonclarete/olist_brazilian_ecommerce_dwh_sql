USE olist_brazilian_ecommerce_dwh;
GO

-- Check for Nulls OR BLANKS OR WHITESPACES
SELECT *
FROM silver.olist_order_items_dataset
WHERE 
    order_id IS NULL
    OR TRIM(order_id) = ''
    OR order_id != TRIM(order_id)

-- Check for duplicates
SELECT 
    order_id, 
    order_item_id,
    COUNT(*)
FROM silver.olist_order_items_dataset
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1

-- order_id must exists in orders table
SELECT * FROM silver.olist_order_items_dataset oi
WHERE NOT EXISTS (SELECT 1 FROM silver.olist_orders_dataset o WHERE o.order_id = oi.order_id)

-- product_id must exists in products table
SELECT * FROM silver.olist_order_items_dataset oi
WHERE NOT EXISTS (SELECT 1 FROM silver.olist_products_dataset p WHERE p.product_id = oi.product_id)

-- seller_id must exists in seller table
SELECT * FROM silver.olist_order_items_dataset oi
WHERE NOT EXISTS (SELECT 1 FROM silver.olist_sellers_dataset s WHERE s.seller_id = oi.seller_id)

-- price and freight_value must be greater than or equal to 0
SELECT *
FROM silver.olist_order_items_dataset
WHERE CAST(freight_value AS decimal(16, 2)) < 0