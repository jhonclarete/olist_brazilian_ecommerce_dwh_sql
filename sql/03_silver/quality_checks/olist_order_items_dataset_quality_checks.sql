USE olist_brazilian_ecommerce_dwh;
GO

-- order_id

-- Check for Nulls
SELECT *
FROM silver.olist_order_items_dataset
WHERE order_id IS NULL

-- Check blank values
SELECT *
FROM silver.olist_order_items_dataset
WHERE TRIM(order_id) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_order_items_dataset
WHERE order_id != TRIM(order_id)

-- Check length of seller_id
SELECT *
FROM silver.olist_order_items_dataset
WHERE LEN(order_id) != 32

-- Check for non-numeric values
SELECT *
FROM silver.olist_order_items_dataset
WHERE order_id LIKE '%^[0-9a-f]{32}$%'

-- Matches corresponding order in orders table
SELECT * FROM silver.olist_order_items_dataset oi
WHERE NOT EXISTS (SELECT 1 FROM silver.olist_orders_dataset o WHERE o.order_id = oi.order_id)


-- order_item_id

-- Not null
SELECT *
FROM silver.olist_order_items_dataset
WHERE order_item_id IS NULL

-- Positive Integer
SELECT *
FROM silver.olist_order_items_dataset
WHERE order_item_id <= 0

-- No duplicate (order_id, order_item_id) combinations
SELECT order_id, order_item_id, COUNT(*)
FROM silver.olist_order_items_dataset
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1

-- Swquential check
SELECT *
FROM
(
    SELECT
        order_id,
        order_item_id,

        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY order_item_id
        ) AS expected_item_id

    FROM silver.olist_order_items_dataset
) x

WHERE order_item_id != expected_item_id;



-- product_id

-- Not null
SELECT *
FROM silver.olist_order_items_dataset
WHERE product_id IS NULL

-- Check blank values
SELECT *
FROM silver.olist_order_items_dataset
WHERE TRIM(product_id) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_order_items_dataset
WHERE product_id != TRIM(product_id)

-- Matches corresponding product in products table
SELECT * FROM silver.olist_order_items_dataset oi
WHERE NOT EXISTS (SELECT 1 FROM silver.olist_products_dataset p WHERE p.product_id = oi.product_id)


-- seller_id

-- Not null
SELECT *
FROM silver.olist_order_items_dataset
WHERE seller_id IS NULL

-- Check blank values
SELECT *
FROM silver.olist_order_items_dataset
WHERE TRIM(seller_id) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_order_items_dataset
WHERE seller_id != TRIM(seller_id)

-- Matches corresponding product in products table
SELECT * FROM silver.olist_order_items_dataset oi
WHERE NOT EXISTS (SELECT 1 FROM silver.olist_sellers_dataset s WHERE s.seller_id = oi.seller_id)


-- shipping_limit_date

-- Valid timestamp
SELECT *
FROM silver.olist_order_items_dataset
WHERE TRY_CAST(shipping_limit_date AS DATETIME2) IS NULL

-- Reasonable data range
SELECT *
FROM silver.olist_order_items_dataset oi
INNER JOIN silver.olist_orders_dataset o
ON oi.order_id = o.order_id
WHERE CAST(oi.shipping_limit_date AS datetime2) < o.order_purchase_timestamp
AND o.order_delivered_carrier_date > CAST(oi.shipping_limit_date AS datetime2)


-- price

-- Not Null
SELECT *
FROM silver.olist_order_items_dataset
WHERE price IS NULL

-- Greater than or equal to 0
SELECT *
FROM silver.olist_order_items_dataset
WHERE CAST(price AS decimal(10, 2)) < 0