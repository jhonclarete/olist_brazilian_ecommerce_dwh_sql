USE olist_brazilian_ecommerce_dwh;
GO

-- geolocation_zip_code_prefix

-- Check for NULL Values
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_zip_code_prefix IS NULL

-- Check blank values
SELECT *
FROM silver.olist_geolocation_dataset
WHERE TRIM(geolocation_zip_code_prefix) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_zip_code_prefix != TRIM(geolocation_zip_code_prefix);

-- Check ZIP prefix length; Brazilian CEP prefix should have 5 digits.
SELECT *
FROM silver.olist_geolocation_dataset
WHERE LEN(geolocation_zip_code_prefix) != 5

-- Check for non-numeric values
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_zip_code_prefix LIKE '%[^0-9]%'

-- Count duplicate ZIP prefixes
SELECT 
    geolocation_zip_code_prefix,
    ROUND(CAST(geolocation_lat AS DECIMAL(9,6)), 6) AS geolocation_lat,
    ROUND(CAST(geolocation_lng AS DECIMAL(9,6)), 6) AS geolocation_lng,
    LOWER(TRIM(geolocation_city)) COLLATE Latin1_General_100_CI_AI AS geolocation_city,
    geolocation_state,
    COUNT(*)
FROM silver.olist_geolocation_dataset
GROUP BY
    geolocation_zip_code_prefix,
    ROUND(CAST(geolocation_lat AS DECIMAL(9,6)), 6),
    ROUND(CAST(geolocation_lng AS DECIMAL(9,6)), 6),
    LOWER(TRIM(geolocation_city)) COLLATE Latin1_General_100_CI_AI,
    geolocation_state
HAVING COUNT(*) > 1
ORDER BY geolocation_zip_code_prefix;


-- geolocation_lat

-- Check NULLs
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_lat IS NULL


-- geolocation_lng

-- Check NULLs
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_lng IS NULL


-- geolocation_city

-- Check NULLs
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_city IS NULL

-- Check blank values
SELECT *
FROM silver.olist_geolocation_dataset
WHERE TRIM(geolocation_city) = ''

-- Check leading/trailing spaces
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_city != TRIM(geolocation_city);

-- Check for uppercases
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_city COLLATE Latin1_General_CS_AS = UPPER(geolocation_city);

-- Check if there are mojibake
SELECT * 
FROM silver.olist_geolocation_dataset
WHERE REGEXP_LIKE(geolocation_city, '(Ã[a-zA-Z0-9]|â€|æ—)', 'c'); 


-- geolocation_state

-- Check NULLs
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_state IS NULL

-- Check blank values
SELECT *
FROM silver.olist_geolocation_dataset
WHERE TRIM(geolocation_state) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_state != TRIM(geolocation_state);

-- Check for lowercases
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_state COLLATE Latin1_General_CS_AS = LOWER(geolocation_state);

-- Check length
SELECT *
FROM silver.olist_geolocation_dataset
WHERE LEN(geolocation_state) != 2;

-- Find invalid state codes
SELECT DISTINCT geolocation_state
FROM silver.olist_geolocation_dataset
WHERE geolocation_state NOT IN (
'AC','AL','AP','AM','BA','CE','DF','ES','GO',
'MA','MT','MS','MG','PA','PB','PR','PE','PI',
'RJ','RN','RS','RO','RR','SC','SP','SE','TO'
);