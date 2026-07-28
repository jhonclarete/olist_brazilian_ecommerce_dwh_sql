USE olist_brazilian_ecommerce_dwh;
GO

-- Check for duplicate seller_id
SELECT 
    seller_id,
    COUNT(*) 
FROM silver.olist_sellers_dataset
GROUP BY seller_id
HAVING 
    COUNT(*) > 1 

-- Check string value for Nulls, whitespace, blank
SELECT * FROM silver.olist_sellers_dataset
WHERE 
    seller_state IS NULL
    OR seller_state != TRIM(seller_state)
    OR TRIM(seller_state) = '' 

-- Check for validity of Prefix code
SELECT * 
FROM silver.olist_sellers_dataset
WHERE LEN(TRIM(seller_zip_code_prefix)) != 5

-- Check if zip code exists in Geolocation
SELECT *
FROM silver.olist_sellers_dataset s
WHERE NOT EXISTS (SELECT 1 FROM silver.olist_geolocation_dataset g WHERE g.geolocation_zip_code_prefix = s.seller_zip_code_prefix)

-- Check if city is in Lower Case
SELECT * 
FROM silver.olist_sellers_dataset
WHERE seller_city COLLATE Latin1_General_CS_AS != LOWER(seller_city)

-- Check if state is in Upper Case
SELECT * 
FROM silver.olist_sellers_dataset
WHERE seller_state COLLATE Latin1_General_CS_AS != UPPER(seller_state)

-- Check if state is valid
SELECT *
from silver.olist_sellers_dataset
WHERE seller_state NOT IN ('RS','CE','PE','AL','PI','MG','DF','TO',
'RR','SE','PA','GO','RO','ES','RJ','AC','SP','AM',
'PR','MT','PB','MA','AP','MS','SC','RN','BA')

-- Check for mojibake text
SELECT distinct seller_city, dwh_city_quality_flag
FROM silver.olist_sellers_dataset
WHERE seller_city LIKE '%[0-9]%';

SELECT DISTINCT 
    seller_zip_code_prefix,
    seller_city,
    seller_state,
    dwh_city_quality_flag
FROM silver.olist_sellers_dataset
WHERE 
    -- 1. Finds capital letters or accents glued inside a lowercase sequence (e.g., "MaceiÃ³")
    seller_city COLLATE Latin1_General_BIN LIKE '%[a-z][ÃÂÊÓãéíóúç]% '
    -- 2. Finds loose floating mathematical/subscript characters 
    OR seller_city LIKE '%[³²ºª¶§†‡]%'
    -- 3. Finds broken multi-byte question marks or text boxes
    OR seller_city LIKE '%?%';