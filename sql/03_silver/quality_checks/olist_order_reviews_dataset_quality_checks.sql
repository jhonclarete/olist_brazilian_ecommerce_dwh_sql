USE olist_brazilian_ecommerce_dwh;
GO

-- Check for Nulls, blanks, and whitespaces
SELECT *
FROM silver.olist_order_reviews_dataset
WHERE   
    review_id IS NULL
    OR TRIM(review_id) = ''
    OR review_id != TRIM(review_id)

-- Check for duplicate review_id
SELECT review_id, COUNT(*)
FROM silver.olist_order_reviews_dataset
GROUP BY review_id
HAVING COUNT(*) > 1

-- Check if order_id exists in orders table
SELECT *
FROM silver.olist_order_reviews_dataset orev
WHERE NOT EXISTS (SELECT 1 FROM silver.olist_orders_dataset o WHERE o.order_id = orev.order_id)

-- review_score must be between 1 and 5
SELECT *
FROM silver.olist_order_reviews_dataset
WHERE CAST(review_score AS int) NOT BETWEEN 1 AND 5 

-- Check if review_creation_date is earlier than purchase date
SELECT *
FROM silver.olist_order_reviews_dataset orev
WHERE NOT EXISTS (SELECT 1 FROM silver.olist_orders_dataset o WHERE CAST(o.order_purchase_timestamp AS datetime2) > CAST(orev.review_creation_date AS datetime2))