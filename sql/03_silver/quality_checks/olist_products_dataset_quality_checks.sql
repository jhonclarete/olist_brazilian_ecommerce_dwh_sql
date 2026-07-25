USE olist_brazilian_ecommerce_dwh;
GO

-- product_id

-- Check for Nulls
SELECT *
FROM silver.olist_products_dataset
WHERE product_id IS NULL

-- Check if lenght is not 32
SELECT *
FROM silver.olist_products_dataset
WHERE LEN(product_id) != 32

-- Check for whitespaces
SELECT *
FROM silver.olist_products_dataset
WHERE product_id != TRIM(product_id)

-- Check blank values
SELECT *
FROM silver.olist_products_dataset
WHERE TRIM(product_id) = ''

-- Check for duplicates
SELECT
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    COUNT(*)
FROM silver.olist_products_dataset
GROUP BY 
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
HAVING COUNT(*) > 1


-- product_category_name

-- Check for Nulls
SELECT *
FROM silver.olist_products_dataset
WHERE product_category_name IS NULL

-- Check for whitespaces
SELECT *
FROM silver.olist_products_dataset
WHERE product_category_name != TRIM(product_category_name)

-- Check blank values
SELECT *
FROM silver.olist_products_dataset
WHERE TRIM(product_category_name) = ''

-- Check for uppercases
SELECT *
FROM silver.olist_products_dataset
WHERE product_category_name COLLATE Latin1_General_CS_AS = UPPER(product_category_name);

-- Check if there are mojibake
SELECT * 
FROM silver.olist_products_dataset
WHERE REGEXP_LIKE(product_category_name, '(Ã[a-zA-Z0-9]|â€|æ—)', 'c'); 