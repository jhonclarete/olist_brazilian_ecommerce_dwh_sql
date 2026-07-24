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
            ROUND(CAST(geolocation_lat AS DECIMAL(9,6)), 6) AS geolocation_lat,
            ROUND(CAST(geolocation_lng AS DECIMAL(9,6)), 6) AS geolocation_lng,
            UPPER(TRANSLATE(geolocation_city, 
                        N'áàâãäåāăąÁÀÂÃÄÅĀĂĄéèêëēĕėęěÉÈÊËĒĔĖĘĚíìîïīĭįÍÌÎÏĪĬĮóòôõöøōŏőÓÒÔÕÖØŌŎŐúùûüūŭůűųÚÙÛÜŪŬŮŰŲñńņňÑŃŅŇçćĉċčÇĆĈĊČ', 
                        N'aaaaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeeeiiiiiiiiiiiiiioooooooooooooooooouuuuuuuuuuuuuuuuunnnnunnnncccccccccc')) AS geolocation_city,
            geolocation_state
        FROM bronze.olist_geolocation_dataset
        WHERE (geolocation_lat BETWEEN -33.8 AND 5.3) 
        AND (geolocation_lng BETWEEN -74.0 AND -34.7)

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