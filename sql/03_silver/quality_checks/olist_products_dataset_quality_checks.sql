USE olist_brazilian_ecommerce_dwh;
GO

-- CHECK FOR DUPLICATES
-- EXPECTED RESULT: NO RESULT
SELECT COUNT(*)
FROM bronze.olist_products_dataset
GROUP BY product_id
HAVING COUNT(*) > 1

-- CHECK FOR NULL VALUES
-- EXPECTED RESULT: NO RESULT
SELECT *
FROM bronze.olist_products_dataset
WHERE product_id IS NULL

SELECT *
FROM bronze.olist_products_dataset
WHERE product_category_name IS NULL

SELECT *
FROM bronze.olist_products_dataset
WHERE product_weight_g IS NULL