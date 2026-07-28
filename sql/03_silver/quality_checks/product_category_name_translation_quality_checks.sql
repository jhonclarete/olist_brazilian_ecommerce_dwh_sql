USE olist_brazilian_ecommerce_dwh;
GO

-- Check for duplicates
SELECT 
    product_category_name COLLATE Latin1_General_100_CI_AI AS product_category_name, 
    product_category_name_english COLLATE Latin1_General_100_CI_AI AS product_category_name_english, COUNT(*) 
FROM silver.olist_product_category_name_translation_dataset
GROUP BY 
    product_category_name COLLATE Latin1_General_100_CI_AI, 
    product_category_name_english COLLATE Latin1_General_100_CI_AI
HAVING COUNT(*) > 1

SELECT 
    product_category_name_english COLLATE Latin1_General_100_CI_AI AS product_category_name_english, 
    product_category_name COLLATE Latin1_General_100_CI_AI AS product_category_name, COUNT(*) 
FROM silver.olist_product_category_name_translation_dataset
GROUP BY 
    product_category_name_english COLLATE Latin1_General_100_CI_AI, 
    product_category_name COLLATE Latin1_General_100_CI_AI
HAVING COUNT(*) > 1

-- Check for Nulls or empty
SELECT 
    * 
FROM silver.olist_product_category_name_translation_dataset 
WHERE 
    product_category_name IS NULL 
    OR TRIM(product_category_name_english) = ''