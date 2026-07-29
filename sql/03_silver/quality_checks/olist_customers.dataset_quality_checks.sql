USE olist_brazilian_ecommerce_dwh;
GO

-- Check for duplicate customer_id
SELECT 
    customer_id,
    COUNT(*) 
FROM silver.olist_customers_dataset
GROUP BY customer_id
HAVING 
    COUNT(*) > 1 

-- Check string value for Nulls, whitespace, blank
SELECT * FROM silver.olist_customers_dataset
WHERE 
    customer_zip_code_prefix IS NULL
    OR customer_zip_code_prefix != TRIM(customer_zip_code_prefix)
    OR TRIM(customer_zip_code_prefix) = '' 

-- Check Length of IDs
SELECT * FROM silver.olist_customers_dataset
WHERE LEN(customer_unique_id) != 32    

-- Check for validity of Prefix code
SELECT * 
FROM silver.olist_customers_dataset
WHERE LEN(TRIM(customer_zip_code_prefix)) != 5

-- Check if zip code exists in Geolocation
SELECT *
FROM silver.olist_customers_dataset c
WHERE NOT EXISTS (SELECT 1 FROM silver.olist_geolocation_dataset g WHERE g.geolocation_zip_code_prefix = c.customer_zip_code_prefix)

-- Check if city is in Lower Case
SELECT * 
FROM silver.olist_customers_dataset
WHERE customer_city COLLATE Latin1_General_CS_AS != LOWER(customer_city)

-- Check if state is in Upper Case
SELECT * 
FROM silver.olist_customers_dataset
WHERE customer_state COLLATE Latin1_General_CS_AS != UPPER(customer_state)

-- Check if state is valid
SELECT *
from silver.olist_customers_dataset
WHERE customer_state NOT IN ('RS','CE','PE','AL','PI','MG','DF','TO',
'RR','SE','PA','GO','RO','ES','RJ','AC','SP','AM',
'PR','MT','PB','MA','AP','MS','SC','RN','BA')

-- Check for mojibake text
SELECT distinct customer_city
FROM silver.olist_customers_dataset
WHERE customer_city LIKE '%[0-9]%';

SELECT DISTINCT 
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM silver.olist_customers_dataset
WHERE 
    -- 1. Finds capital letters or accents glued inside a lowercase sequence (e.g., "MaceiÃ³")
    customer_city COLLATE Latin1_General_BIN LIKE '%[a-z][ÃÂÊÓãéíóúç]% '
    -- 2. Finds loose floating mathematical/subscript characters 
    OR customer_city LIKE '%[³²ºª¶§†‡]%'
    -- 3. Finds broken multi-byte question marks or text boxes
    OR customer_city LIKE '%?%';