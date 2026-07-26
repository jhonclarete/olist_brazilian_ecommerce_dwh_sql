USE olist_brazilian_ecommerce_dwh;
GO

-- Check if there are mojibake
SELECT * 
FROM silver.olist_product_category_name_translation_dataset
WHERE REGEXP_LIKE(product_category_name_english, '(Ã[a-zA-Z0-9]|â€|æ—)', 'c'); 

-- product_category_name
-- Check Nulls
SELECT *
FROM silver.olist_product_category_name_translation_dataset
WHERE product_category_name IS NULL

-- Check blank values
SELECT *
FROM silver.olist_product_category_name_translation_dataset
WHERE TRIM(product_category_name) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_product_category_name_translation_dataset
WHERE product_category_name != TRIM(product_category_name)

-- Check for upperrcases
SELECT *
FROM silver.olist_product_category_name_translation_dataset
WHERE product_category_name COLLATE Latin1_General_CS_AS = UPPER(product_category_name);

-- Check for duplicates
SELECT COUNT(*) FROM silver.olist_product_category_name_translation_dataset
GROUP BY product_category_name
HAVING COUNT(*) > 1


-- product_category_name_english
-- Check Nulls
SELECT *
FROM silver.olist_product_category_name_translation_dataset
WHERE product_category_name_english IS NULL

-- Check blank values
SELECT *
FROM silver.olist_product_category_name_translation_dataset
WHERE TRIM(product_category_name_english) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_product_category_name_translation_dataset
WHERE product_category_name_english != TRIM(product_category_name_english)

-- Check for upperrcases
SELECT *
FROM silver.olist_product_category_name_translation_dataset
WHERE product_category_name_english COLLATE Latin1_General_CS_AS = UPPER(product_category_name_english);

-- Check for duplicates
SELECT COUNT(*) FROM silver.olist_product_category_name_translation_dataset
GROUP BY product_category_name_english
HAVING COUNT(*) > 1