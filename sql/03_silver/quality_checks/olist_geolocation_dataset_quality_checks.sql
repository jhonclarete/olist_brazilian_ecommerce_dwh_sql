USE olist_brazilian_ecommerce_dwh;
GO

-- CHECK FOR NULL VALUES
-- EXPECTED RESULT: NO RESULT
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_zip_code_prefix IS NULL

SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_lat IS NULL

SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_lng IS NULL

SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_city IS NULL

SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_state IS NULL


-- CHECK IF THERE ARE WHITESPACES, NOT STANDARDIZE TEXT
-- EXPECTED RESULT: NO RESULT
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_zip_code_prefix != TRIM(geolocation_zip_code_prefix);

SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_city != TRIM(geolocation_city);

SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_state != TRIM(geolocation_state);

SELECT
    geolocation_state
FROM silver.olist_geolocation_dataset
WHERE geolocation_state COLLATE Latin1_General_CS_AS != UPPER(geolocation_state);


-- CHECK IF LOCATION IS OUT OF BOUNDARY
-- Expected result: No result
SELECT 
    geolocation_lat,
    geolocation_city,
    geolocation_state
FROM silver.olist_geolocation_dataset
WHERE geolocation_lat NOT BETWEEN -33.8 AND 5.3

SELECT 
    geolocation_lng
FROM silver.olist_geolocation_dataset
WHERE geolocation_lng NOT BETWEEN -74.0 AND -34.7


-- CHECK IF THERE ARE mojibake
-- EXPECTED RESULT: NO RESULT
SELECT * 
FROM silver.olist_geolocation_dataset 
WHERE REGEXP_LIKE(geolocation_city, '(Ã[a-zA-Z0-9]|â€|æ—)', 'c');