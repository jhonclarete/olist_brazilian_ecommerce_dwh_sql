USE olist_brazilian_ecommerce_dwh;
GO

-- Check for duplicate record
-- ERROR
SELECT 
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng, 
    geolocation_city COLLATE Latin1_General_CI_AI AS geolocation_city,
    geolocation_state, 
    COUNT(*)
FROM silver.olist_geolocation_dataset
GROUP BY 
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng, 
    geolocation_city COLLATE Latin1_General_CI_AI,
    geolocation_state
HAVING
    COUNT(*) > 1

-- Check if Lat and Lng are valid values
SELECT *
FROM silver.olist_geolocation_dataset
WHERE
    (CAST(geolocation_lat AS decimal(19, 15)) < -90 AND CAST(geolocation_lat AS decimal(19, 15)) > 90)
    OR (CAST(geolocation_lng AS decimal(19, 15)) < -180 AND CAST(geolocation_lng AS decimal(19, 15)) > 180)
    OR geolocation_lat IS NULL
    or geolocation_lng is NULL

-- Check if Lat are within Brazil
SELECT *
FROM silver.olist_geolocation_dataset
WHERE CAST(geolocation_lat AS decimal(19, 15)) < -33.75 OR CAST(geolocation_lat AS decimal(19, 15)) > 5.27


-- Check if Lng are within Brazil
SELECT *
FROM silver.olist_geolocation_dataset
WHERE CAST(geolocation_lng AS decimal(19, 15)) < -73.98 OR CAST(geolocation_lng AS decimal(19, 15)) > -28.85

-- Check for Nulls or Empty data or unwanted spaces
SELECT * 
FROM silver.olist_geolocation_dataset
WHERE 
    geolocation_city IS NULL
    OR TRIM(geolocation_city) = ''
    OR geolocation_city != TRIM(geolocation_city)

-- Check if city is in Lower Case
SELECT * 
FROM silver.olist_geolocation_dataset
WHERE geolocation_city COLLATE Latin1_General_CS_AS != LOWER(geolocation_city)

-- Check if state is in Upper Case
SELECT * 
FROM silver.olist_geolocation_dataset
WHERE geolocation_state COLLATE Latin1_General_CS_AS != UPPER(geolocation_state)

-- Check if state is valid
SELECT *
from silver.olist_geolocation_dataset
WHERE geolocation_state NOT IN ('RS','CE','PE','AL','PI','MG','DF','TO',
'RR','SE','PA','GO','RO','ES','RJ','AC','SP','AM',
'PR','MT','PB','MA','AP','MS','SC','RN','BA')

-- Check for validity of Prefix code
SELECT * 
FROM silver.olist_geolocation_dataset
WHERE LEN(TRIM(geolocation_zip_code_prefix)) != 5

-- Check for mojibake text
SELECT distinct geolocation_city
FROM silver.olist_geolocation_dataset
WHERE geolocation_city LIKE '%[0-9]%';

SELECT DISTINCT 
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state
FROM silver.olist_geolocation_dataset
WHERE 
    -- 1. Finds capital letters or accents glued inside a lowercase sequence (e.g., "MaceiÃ³")
    geolocation_city COLLATE Latin1_General_BIN LIKE '%[a-z][ÃÂÊÓãéíóúç]% '
    -- 2. Finds loose floating mathematical/subscript characters 
    OR geolocation_city LIKE '%[³²ºª¶§†‡]%'
    -- 3. Finds broken multi-byte question marks or text boxes
    OR geolocation_city LIKE '%?%';

    