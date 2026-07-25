/*
This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
*/
USE olist_brazilian_ecommerce_dwh;
GO

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE @batch_start_time AS DATETIME, @batch_end_time AS DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';
        PRINT '------------------------------------------------';
        PRINT 'Loading Tables';
        PRINT '------------------------------------------------';
        
        PRINT 'Truncating/Inserting silver.olist_geolocation_dataset';
        TRUNCATE TABLE silver.olist_geolocation_dataset;
        INSERT INTO silver.olist_geolocation_dataset
        (
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state
        )
        SELECT
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state
        FROM 
        (
            SELECT
                geolocation_zip_code_prefix,
                ROUND(CAST(geolocation_lat AS DECIMAL(9,6)), 6) AS geolocation_lat,
                ROUND(CAST(geolocation_lng AS DECIMAL(9,6)), 6) AS geolocation_lng,
                LOWER(TRANSLATE(
                    TRIM(geolocation_city), 
                    N'áàâãäåāăąÁÀÂÃÄÅĀĂĄéèêëēĕėęěÉÈÊËĒĔĖĘĚíìîïīĭįÍÌÎÏĪĬĮóòôõöøōŏőÓÒÔÕÖØŌŎŐúùûüūŭůűųÚÙÛÜŪŬŮŰŲñńņňÑŃŅŇçćĉċčÇĆĈĊČ', 
                    N'aaaaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeeeiiiiiiiiiiiiiioooooooooooooooooouuuuuuuuuuuuuuuuunnnnunnnncccccccccc'
                )) AS geolocation_city,
                UPPER(TRIM(geolocation_state)) AS geolocation_state,
                ROW_NUMBER() 
                OVER
                (
                    PARTITION BY 
                        geolocation_zip_code_prefix, 
                        ROUND(CAST(geolocation_lat AS DECIMAL(9,6)), 6),
                        ROUND(CAST(geolocation_lng AS DECIMAL(9,6)), 6),
                        LOWER(TRANSLATE(
                            TRIM(geolocation_city), 
                            N'áàâãäåāăąÁÀÂÃÄÅĀĂĄéèêëēĕėęěÉÈÊËĒĔĖĘĚíìîïīĭįÍÌÎÏĪĬĮóòôõöøōŏőÓÒÔÕÖØŌŎŐúùûüūŭůűųÚÙÛÜŪŬŮŰŲñńņňÑŃŅŇçćĉċčÇĆĈĊČ', 
                            N'aaaaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeeeiiiiiiiiiiiiiioooooooooooooooooouuuuuuuuuuuuuuuuunnnnunnnncccccccccc')), 
                        UPPER(TRIM(geolocation_state))
                    ORDER BY 
                        (SELECT NULL)
                ) AS row_num
            FROM bronze.olist_geolocation_dataset
        )t
        WHERE row_num = 1
        AND (geolocation_lat BETWEEN -33.75 AND 5.27) 
        AND (geolocation_lng BETWEEN -73.99 AND -28.84)

        PRINT 'Truncating/Inserting silver.olist_sellers_dataset';
        TRUNCATE TABLE silver.olist_sellers_dataset;
        INSERT INTO silver.olist_sellers_dataset
        (
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state,
	        dwh_geolocation_missing_flag
        )
        SELECT 
            s.seller_id,
            s.seller_zip_code_prefix,
            LOWER(TRANSLATE(
                    TRIM(s.seller_city), 
                    N'áàâãäåāăąÁÀÂÃÄÅĀĂĄéèêëēĕėęěÉÈÊËĒĔĖĘĚíìîïīĭįÍÌÎÏĪĬĮóòôõöøōŏőÓÒÔÕÖØŌŎŐúùûüūŭůűųÚÙÛÜŪŬŮŰŲñńņňÑŃŅŇçćĉċčÇĆĈĊČ', 
                    N'aaaaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeeeiiiiiiiiiiiiiioooooooooooooooooouuuuuuuuuuuuuuuuunnnnunnnncccccccccc'
                )) AS seller_city,
            s.seller_state,
            CASE 
                WHEN g.geolocation_zip_code_prefix IS NULL THEN 1
                ELSE 0
            END AS dwh_geolocation_missing_flag
        FROM bronze.olist_sellers_dataset s
        LEFT JOIN silver.olist_geolocation_dataset g
        ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
        WHERE s.seller_city LIKE '%[^0-9]%'

        PRINT 'Truncating/Inserting silver.olist_product_category_name_translation_dataset';
        TRUNCATE TABLE silver.olist_product_category_name_translation_dataset;
        INSERT INTO silver.olist_product_category_name_translation_dataset
        (
            product_category_name,
            product_category_name_english
        )
        SELECT 
            LOWER(TRANSLATE(
                    TRIM(product_category_name), 
                    N'áàâãäåāăąÁÀÂÃÄÅĀĂĄéèêëēĕėęěÉÈÊËĒĔĖĘĚíìîïīĭįÍÌÎÏĪĬĮóòôõöøōŏőÓÒÔÕÖØŌŎŐúùûüūŭůűųÚÙÛÜŪŬŮŰŲñńņňÑŃŅŇçćĉċčÇĆĈĊČ', 
                    N'aaaaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeeeiiiiiiiiiiiiiioooooooooooooooooouuuuuuuuuuuuuuuuunnnnunnnncccccccccc'
                )) AS product_category_name,
            LOWER(TRANSLATE(
                    TRIM(product_category_name_english), 
                    N'áàâãäåāăąÁÀÂÃÄÅĀĂĄéèêëēĕėęěÉÈÊËĒĔĖĘĚíìîïīĭįÍÌÎÏĪĬĮóòôõöøōŏőÓÒÔÕÖØŌŎŐúùûüūŭůűųÚÙÛÜŪŬŮŰŲñńņňÑŃŅŇçćĉċčÇĆĈĊČ', 
                    N'aaaaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeeeiiiiiiiiiiiiiioooooooooooooooooouuuuuuuuuuuuuuuuunnnnunnnncccccccccc'
                )) AS product_category_name_english
        FROM bronze.olist_product_category_name_translation_dataset

        PRINT 'Truncating/Inserting silver.olist_products_dataset';
        TRUNCATE TABLE silver.olist_products_dataset;
        INSERT INTO silver.olist_products_dataset
        (
            product_id,
            product_category_name,
            product_name_lenght,
            product_description_lenght,
            product_photos_qty,
            product_weight_g,
            product_length_cm,
            product_height_cm,
            product_width_cm,
            dwh_category_name_missing_flag,
            dwh_category_translation_missing_flag,
            dwh_weight_outlier_flag,
            dwh_dimension_outlier_flag,
            dwh_photo_quantity_outlier_flag,
            dwh_name_length_outlier_flag
        )
        SELECT 
            p.product_id,
            p.product_category_name,
            CAST(p.product_name_lenght AS INT) AS product_name_lenght,
            CAST(p.product_description_lenght AS INT) AS product_description_lenght,
            CAST(p.product_photos_qty AS INT) AS product_photos_qty,
            CAST(p.product_weight_g AS INT) AS product_weight_g,
            ROUND(CAST(p.product_length_cm AS DECIMAL(10,2)), 2) AS product_length_cm,
            ROUND(CAST(p.product_height_cm AS DECIMAL(10,2)), 2) AS product_height_cm,
            ROUND(CAST(p.product_width_cm AS DECIMAL(10,2)), 2) AS product_width_cm,
            CASE 
                WHEN p.product_category_name IS NULL THEN 1
                ELSE 0
            END AS dwh_category_name_missing_flag,
            CASE 
                WHEN pc.product_category_name IS NULL THEN 1
                ELSE 0
            END AS dwh_category_translation_missing_flag,
            CASE 
                WHEN p.product_weight_g IS NOT NULL AND CAST(p.product_weight_g AS INT) <= 0 THEN 1
                ELSE 0
            END AS dwh_weight_outlier_flag,
            CASE 
                WHEN p.product_length_cm IS NOT NULL AND ROUND(CAST(p.product_length_cm AS DECIMAL(10,2)), 2) <= 0 THEN 1
                WHEN p.product_height_cm IS NOT NULL AND ROUND(CAST(p.product_height_cm AS DECIMAL(10,2)), 2) <= 0 THEN 1
                WHEN p.product_width_cm IS NOT NULL AND ROUND(CAST(p.product_width_cm AS DECIMAL(10,2)), 2) <= 0 THEN 1
                ELSE 0
            END AS dwh_dimension_outlier_flag,
            CASE 
                WHEN p.product_photos_qty IS NOT NULL AND CAST(p.product_photos_qty AS INT) < 0 THEN 1
                ELSE 0
            END AS dwh_photo_quantity_outlier_flag,
            CASE 
                WHEN p.product_name_lenght IS NOT NULL AND CAST(p.product_name_lenght AS INT) <= 0 THEN 1
                ELSE 0
            END AS dwh_name_length_outlier_flag
        FROM bronze.olist_products_dataset p
        LEFT JOIN silver.olist_product_category_name_translation_dataset pc
        ON p.product_category_name = pc.product_category_name

        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Loading silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST (DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';
    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURED DURING LOADING silver LAYER';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH
END