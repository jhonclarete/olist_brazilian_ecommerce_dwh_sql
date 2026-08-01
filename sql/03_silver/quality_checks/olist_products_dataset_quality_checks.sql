USE olist_brazilian_ecommerce_dwh;
GO

-- Check for duplicate product_id
SELECT 
    product_id,
    COUNT(*) 
FROM silver.olist_products_dataset
GROUP BY product_id
HAVING 
    COUNT(*) > 1 

-- Check string value for Nulls, whitespace, blank
SELECT * FROM silver.olist_products_dataset
WHERE 
    product_category_name IS NULL
    OR product_category_name != TRIM(product_category_name)
    OR TRIM(product_category_name) = '' 

-- Check Length of IDs
SELECT * FROM silver.olist_products_dataset
WHERE LEN(product_id) != 32

-- Check if category exists in category translation
SELECT *
FROM silver.olist_products_dataset p
WHERE NOT EXISTS (SELECT 1 FROM silver.olist_product_category_name_translation_dataset ct WHERE ct.product_category_name = p.product_category_name)
AND P.product_category_name IS NOT NULL

-- Check if category name is in Lower Case
SELECT * 
FROM silver.olist_products_dataset
WHERE product_category_name COLLATE Latin1_General_CS_AS != LOWER(product_category_name)

-- Check for mojibake text
SELECT distinct product_category_name
FROM silver.olist_products_dataset
WHERE product_category_name LIKE '%[0-9]%';

SELECT DISTINCT 
    product_category_name
FROM silver.olist_products_dataset
WHERE 
    -- 1. Finds capital letters or accents glued inside a lowercase sequence (e.g., "MaceiÃ³")
    product_category_name COLLATE Latin1_General_BIN LIKE '%[a-z][ÃÂÊÓãéíóúç]% '
    -- 2. Finds loose floating mathematical/subscript characters 
    OR product_category_name LIKE '%[³²ºª¶§†‡]%'
    -- 3. Finds broken multi-byte question marks or text boxes
    OR product_category_name LIKE '%?%';

-- Check for negative or 0 value
SELECT *
FROM silver.olist_products_dataset
WHERE CAST(product_weight_g AS int) <= 0