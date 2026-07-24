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
        
        -- TRUNCATE AND LOAD silver.olist_geolocation_dataset
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

        -- TRUNCATE AND LOAD silver.olist_sellers_dataset
        INSERT INTO silver.olist_sellers_dataset
        (
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state
        )
        SELECT 
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state
        FROM bronze.olist_sellers_dataset
        WHERE seller_zip_code_prefix IN (SELECT geolocation_zip_code_prefix FROM silver.olist_geolocation_dataset)

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