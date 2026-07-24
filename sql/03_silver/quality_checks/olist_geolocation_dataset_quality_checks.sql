USE olist_brazilian_ecommerce_dwh;
GO

-- Check for NULL values in geolocation_zip_code_prefix
-- Expected result: No result
SELECT 
    geolocation_zip_code_prefix
FROM silver.olist_geolocation_dataset
WHERE geolocation_zip_code_prefix IS NULL

-- Check for white spaces in geolocation_zip_code_prefix
-- Expected result: No result
SELECT
    geolocation_zip_code_prefix
FROM silver.olist_geolocation_dataset
WHERE geolocation_zip_code_prefix != TRIM(geolocation_zip_code_prefix);

-- Check for NULL values in geolocation_lat
-- Expected result: No result
SELECT 
    geolocation_lat
FROM silver.olist_geolocation_dataset
WHERE geolocation_lat IS NULL

-- Check if geolocation_lat is out of Boundary
-- Expected result: No result
SELECT 
    geolocation_lat,
    geolocation_city,
    geolocation_state
FROM silver.olist_geolocation_dataset
WHERE geolocation_lat NOT BETWEEN -33.8 AND 5.3

-- Check for NULL values in geolocation_lng
-- Expected result: No result
SELECT 
    geolocation_lng
FROM silver.olist_geolocation_dataset
WHERE geolocation_lat IS NULL

-- Check if geolocation_lng is out of Boundary
-- Expected result: No result
SELECT 
    geolocation_lng
FROM silver.olist_geolocation_dataset
WHERE geolocation_lng NOT BETWEEN -74.0 AND -34.7

-- Check for NULL values in geolocation_city
-- Expected result: No result
SELECT 
    geolocation_city
FROM silver.olist_geolocation_dataset
WHERE geolocation_city IS NULL

-- Check for white spaces in geolocation_city
-- Expected result: No result
SELECT
    geolocation_city
FROM silver.olist_geolocation_dataset
WHERE geolocation_city != TRIM(geolocation_city);

-- Check for white spaces in geolocation_state
-- Expected result: No result
SELECT
    geolocation_state
FROM silver.olist_geolocation_dataset
WHERE geolocation_state != TRIM(geolocation_state);

-- Check for lower case in geolocation_state
-- Expected result: No result
SELECT
    geolocation_state
FROM silver.olist_geolocation_dataset
WHERE geolocation_state COLLATE Latin1_General_CS_AS != UPPER(geolocation_state);

-- Check for mojibake geolocation_state
-- Expected result: No result
SELECT * 
FROM silver.olist_geolocation_dataset 
WHERE REGEXP_LIKE(geolocation_city, '(Ã[a-zA-Z0-9]|â€|æ—)', 'c'); 

-- Check for NULL values in geolocation_state
-- Expected result: No result
SELECT * 
FROM silver.olist_geolocation_dataset 
WHERE geolocation_state IS NULL