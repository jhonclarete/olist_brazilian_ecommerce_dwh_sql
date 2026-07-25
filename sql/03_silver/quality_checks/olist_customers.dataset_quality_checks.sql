USE olist_brazilian_ecommerce_dwh;
GO

-- customer_id

-- Check Nulls
SELECT *
FROM silver.olist_customers_dataset
WHERE customer_id IS NULL

-- Check blank values
SELECT *
FROM silver.olist_customers_dataset
WHERE TRIM(customer_id) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_customers_dataset
WHERE customer_id != TRIM(customer_id)

-- Check length of customer_id
SELECT *
FROM silver.olist_customers_dataset
WHERE LEN(customer_id) != 32

-- Check for non-numeric values
SELECT *
FROM silver.olist_customers_dataset
WHERE customer_id LIKE '%^[0-9a-f]{32}$%'

-- Check for duplicates
SELECT COUNT(*) FROM silver.olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1


-- customer_unique_id

-- Check Nulls
SELECT *
FROM silver.olist_customers_dataset
WHERE customer_unique_id IS NULL

-- Check blank values
SELECT *
FROM silver.olist_customers_dataset
WHERE TRIM(customer_unique_id) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_customers_dataset
WHERE customer_unique_id != TRIM(customer_unique_id)

-- Check length of customer_unique_id
SELECT *
FROM silver.olist_customers_dataset
WHERE LEN(customer_unique_id) != 32

-- Check for non-numeric values
SELECT *
FROM silver.olist_customers_dataset
WHERE customer_unique_id LIKE '%^[0-9a-f]{32}$%'


-- customer_zip_code_prefix

-- Check for NULL Values
SELECT *
FROM silver.olist_customers_dataset
WHERE customer_zip_code_prefix IS NULL

-- Check blank values
SELECT *
FROM silver.olist_customers_dataset
WHERE TRIM(customer_zip_code_prefix) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_customers_dataset
WHERE customer_zip_code_prefix != TRIM(customer_zip_code_prefix);

-- Check ZIP prefix length; Brazilian CEP prefix should have 5 digits.
SELECT *
FROM silver.olist_customers_dataset
WHERE LEN(customer_zip_code_prefix) != 5

-- Check for non-numeric values
SELECT *
FROM silver.olist_customers_dataset
WHERE customer_zip_code_prefix LIKE '%[^0-9]%'


-- customer_city

-- Check NULLs
SELECT *
FROM silver.olist_customers_dataset
WHERE customer_city IS NULL

-- Check blank values
SELECT *
FROM silver.olist_customers_dataset
WHERE TRIM(customer_city) = ''

-- Check leading/trailing spaces
SELECT *
FROM silver.olist_customers_dataset
WHERE customer_city != TRIM(customer_city);

-- Check for uppercases
SELECT *
FROM silver.olist_customers_dataset
WHERE customer_city COLLATE Latin1_General_CS_AS = UPPER(customer_city);

-- Check if there are mojibake
SELECT * 
FROM silver.olist_customers_dataset
WHERE REGEXP_LIKE(customer_city, '(Ã[a-zA-Z0-9]|â€|æ—)', 'c'); 


-- customer_state

-- Check NULLs
SELECT *
FROM silver.olist_customers_dataset
WHERE customer_state IS NULL

-- Check blank values
SELECT *
FROM silver.olist_customers_dataset
WHERE TRIM(customer_state) = ''

-- Check for whitespaces
SELECT *
FROM silver.olist_customers_dataset
WHERE customer_state != TRIM(customer_state);

-- Check for lowercases
SELECT *
FROM silver.olist_customers_dataset
WHERE customer_state COLLATE Latin1_General_CS_AS = LOWER(customer_state);

-- Check length
SELECT *
FROM silver.olist_customers_dataset
WHERE LEN(customer_state) != 2;

-- Find invalid state codes
SELECT DISTINCT customer_state
FROM silver.olist_customers_dataset
WHERE customer_state NOT IN (
'AC','AL','AP','AM','BA','CE','DF','ES','GO',
'MA','MT','MS','MG','PA','PB','PR','PE','PI',
'RJ','RN','RS','RO','RR','SC','SP','SE','TO'
);
