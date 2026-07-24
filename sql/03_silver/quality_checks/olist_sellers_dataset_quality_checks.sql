use olist_brazilian_ecommerce_dwh;
GO

-- CHECK FOR DUPLICATES
-- EXPECTED RESULT: NO RESULT
SELECT COUNT(*) FROM silver.olist_sellers_dataset
GROUP BY seller_id
HAVING COUNT(*) > 1


-- CHECK FOR NULL VALUES
-- EXPECTED RESULT: NO RESULT
SELECT * 
FROM silver.olist_sellers_dataset 
WHERE seller_id IS NULL

SELECT * 
FROM silver.olist_sellers_dataset 
WHERE seller_zip_code_prefix IS NULL

SELECT * 
FROM silver.olist_sellers_dataset 
WHERE seller_city IS NULL

SELECT * 
FROM silver.olist_sellers_dataset 
WHERE seller_state IS NULL


-- CHECK IF THERE ARE ZIP CODE PREFIX IN SELLER THAT NOT EXISTS IN GEOLOCATION
-- EXPECTED RESULT: NO RESULT
SELECT * FROM silver.olist_sellers_dataset
WHERE seller_zip_code_prefix NOT IN (SELECT geolocation_zip_code_prefix FROM silver.olist_geolocation_dataset)


-- CHECK IF THERE ARE mojibake
-- EXPECTED RESULT: NO RESULT
SELECT * 
FROM silver.olist_sellers_dataset 
WHERE REGEXP_LIKE(seller_city, '(Ã[a-zA-Z0-9]|â€|æ—)', 'c'); 


-- CHECK IF THERE ARE WHITESPACES
-- EXPECTED RESULT: NO RESULT
SELECT *
FROM silver.olist_sellers_dataset 
WHERE seller_id != TRIM(seller_id);

SELECT *
FROM silver.olist_sellers_dataset 
WHERE seller_zip_code_prefix != TRIM(seller_zip_code_prefix);

SELECT *
FROM silver.olist_sellers_dataset 
WHERE seller_city != TRIM(seller_city);

SELECT *
FROM silver.olist_sellers_dataset 
WHERE seller_state != TRIM(seller_state);