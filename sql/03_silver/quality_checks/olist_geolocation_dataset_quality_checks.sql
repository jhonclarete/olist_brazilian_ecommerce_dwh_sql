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

-- Check duplicate record
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    LOWER(TRIM(geolocation_city)) COLLATE Latin1_General_100_CI_AI AS city_normalized,
    geolocation_state,
    COUNT(*) AS cnt
FROM silver.olist_geolocation_dataset
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    LOWER(TRIM(geolocation_city)) COLLATE Latin1_General_100_CI_AI,
    geolocation_state
HAVING COUNT(*) > 1;


-- geolocation_lat
-- Check NULLs
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_lat IS NULL

-- Check Lat range
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_lat < -33.75
OR geolocation_lat > 5.27;

-- Check 0 coordinate
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_lat = 0


-- geolocation_lng
-- Check NULLs
-- ERROR
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_lng IS NULL

-- Check Lng range
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_lng < -73.99
OR geolocation_lng > -34.79;

-- Check 0 coordinate
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_lng = 0


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

-- Check for invalid character
-- ERROR
SELECT *
FROM silver.olist_geolocation_dataset
WHERE geolocation_city LIKE '%[0-9]%';


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