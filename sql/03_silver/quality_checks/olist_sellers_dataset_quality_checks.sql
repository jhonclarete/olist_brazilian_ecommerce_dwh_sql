use olist_brazilian_ecommerce_dwh;
GO

-- seller_id

-- Check Nulls
SELECT *
FROM silver.olist_sellers_dataset
WHERE seller_id IS NULL

-- Check blank values
SELECT *
FROM silver.olist_sellers_dataset
WHERE TRIM(seller_id) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_sellers_dataset
WHERE seller_id != TRIM(seller_id)

-- Check length of seller_id
SELECT *
FROM silver.olist_sellers_dataset
WHERE LEN(seller_id) != 32

-- Check for non-numeric values
SELECT *
FROM silver.olist_sellers_dataset
WHERE seller_id LIKE '%^[0-9a-f]{32}$%'

-- Check for duplicates
SELECT COUNT(*) FROM silver.olist_sellers_dataset
GROUP BY seller_id
HAVING COUNT(*) > 1


-- seller_zip_code_prefix

-- Check for NULL Values
SELECT *
FROM silver.olist_sellers_dataset
WHERE seller_zip_code_prefix IS NULL

-- Check blank values
SELECT *
FROM silver.olist_sellers_dataset
WHERE TRIM(seller_zip_code_prefix) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_sellers_dataset
WHERE seller_zip_code_prefix != TRIM(seller_zip_code_prefix);

-- Check ZIP prefix length; Brazilian CEP prefix should have 5 digits.
SELECT *
FROM silver.olist_sellers_dataset
WHERE LEN(seller_zip_code_prefix) != 5

-- Check for non-numeric values
SELECT *
FROM silver.olist_sellers_dataset
WHERE seller_zip_code_prefix LIKE '%[^0-9]%'

-- Check if seller_zip_code_prefix exists in geolocation
SELECT * 
FROM silver.olist_sellers_dataset
WHERE seller_zip_code_prefix NOT IN (SELECT geolocation_zip_code_prefix FROM silver.olist_geolocation_dataset)


-- geolocation_city

-- Check NULLs
SELECT *
FROM silver.olist_sellers_dataset
WHERE seller_city IS NULL

-- Check blank values
SELECT *
FROM silver.olist_sellers_dataset
WHERE TRIM(seller_city) = ''

-- Check leading/trailing spaces
SELECT *
FROM silver.olist_sellers_dataset
WHERE seller_city != TRIM(seller_city);

-- Check if there are mojibake
SELECT * 
FROM silver.olist_sellers_dataset
WHERE REGEXP_LIKE(seller_city, '(Ã[a-zA-Z0-9]|â€|æ—)', 'c'); 

-- Check for upperrcases
SELECT *
FROM silver.olist_sellers_dataset
WHERE seller_city COLLATE Latin1_General_CS_AS = UPPER(seller_city);

-- Check for non letter seller_city
SELECT *
FROM silver.olist_sellers_dataset
WHERE seller_city NOT LIKE '%[^0-9]%';


-- seller_state

-- Check NULLs
SELECT *
FROM silver.olist_sellers_dataset
WHERE seller_state IS NULL

-- Check blank values
SELECT *
FROM silver.olist_sellers_dataset
WHERE TRIM(seller_state) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_sellers_dataset
WHERE seller_state != TRIM(seller_state);

-- Check for lowercases
SELECT *
FROM silver.olist_sellers_dataset
WHERE seller_state COLLATE Latin1_General_CS_AS = LOWER(seller_state);

-- Check length
SELECT *
FROM silver.olist_sellers_dataset
WHERE LEN(seller_state) != 2;

-- Find invalid state codes
SELECT DISTINCT seller_state
FROM silver.olist_sellers_dataset
WHERE seller_state NOT IN (
'AC','AL','AP','AM','BA','CE','DF','ES','GO',
'MA','MT','MS','MG','PA','PB','PR','PE','PI',
'RJ','RN','RS','RO','RR','SC','SP','SE','TO'
);