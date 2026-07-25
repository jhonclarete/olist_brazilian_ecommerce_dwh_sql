USE olist_brazilian_ecommerce_dwh;
GO

-- product_id

-- Check for Nulls
SELECT *
FROM bronze.olist_products_dataset
WHERE product_id IS NULL

-- Check if lenght is not 32
SELECT *
FROM bronze.olist_products_dataset
WHERE LEN(product_id) != 32

-- Check for whitespaces
SELECT *
FROM bronze.olist_products_dataset
WHERE product_id != TRIM(product_id)

-- Check blank values
SELECT *
FROM bronze.olist_products_dataset
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
FROM bronze.olist_products_dataset
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
FROM bronze.olist_products_dataset
WHERE product_category_name IS NULL

-- Check if product_category_name is available in Translation
SELECT *
FROM bronze.olist_products_dataset
WHERE product_category_name IN (SELECT product_category_name FROM silver.olist_product_category_name_translation_dataset)

-- Check for whitespaces
SELECT *
FROM bronze.olist_products_dataset
WHERE product_category_name != TRIM(product_category_name)

-- Check blank values
SELECT *
FROM bronze.olist_products_dataset
WHERE TRIM(product_category_name) = ''

-- Check for uppercases
SELECT *
FROM bronze.olist_products_dataset
WHERE product_category_name COLLATE Latin1_General_CS_AS = UPPER(product_category_name);

-- Check if there are mojibake
SELECT * 
FROM bronze.olist_products_dataset
WHERE REGEXP_LIKE(product_category_name, '(Ã[a-zA-Z0-9]|â€|æ—)', 'c'); 


-- product_name_lenght

-- Check for range value
SELECT * 
FROM bronze.olist_products_dataset
WHERE product_name_lenght <= 0


-- product_photos_qty

-- Check for range value
SELECT * 
FROM bronze.olist_products_dataset
WHERE product_photos_qty < 0

-- product_weight_g

-- Check for range value
SELECT * 
FROM bronze.olist_products_dataset
WHERE product_weight_g <= 0


-- product_length_cm

-- Check for range value
SELECT * 
FROM bronze.olist_products_dataset
WHERE product_length_cm <= 0


-- product_height_cm

-- Check for range value
SELECT * 
FROM bronze.olist_products_dataset
WHERE product_height_cm <= 0


-- product_width_cm

-- Check for range value
SELECT * 
FROM bronze.olist_products_dataset
WHERE product_width_cm <= 0


/*invalid_measurement_flag
category_translation_missing_flag

weight_outlier_flag
dimension_outlier_flag
photo_quantity_outlier_flag
name_length_outlier_flag
description_length_outlier_flag*/