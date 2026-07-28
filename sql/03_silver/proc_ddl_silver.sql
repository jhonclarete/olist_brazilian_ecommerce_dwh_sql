-- This script creates tables in the 'silver' schema, dropping existing tables if they already exist.

USE olist_brazilian_ecommerce_dwh;
GO

CREATE OR ALTER PROCEDURE silver.setup_silver_tables
AS
BEGIN
	IF OBJECT_ID('silver.olist_product_category_name_translation_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE silver.olist_product_category_name_translation_dataset;
	END;

	CREATE TABLE silver.olist_product_category_name_translation_dataset
	(
		product_category_name NVARCHAR(50),
		product_category_name_english NVARCHAR(50),
		dwh_created_date DATETIME2 DEFAULT GETDATE()
	);

	IF OBJECT_ID('silver.olist_geolocation_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE silver.olist_geolocation_dataset;
	END;

	CREATE TABLE silver.olist_geolocation_dataset
	(
		geolocation_zip_code_prefix NVARCHAR(5),
		geolocation_lat DECIMAL(19, 15),
		geolocation_lng DECIMAL(19, 15),
		geolocation_city NVARCHAR(50),
		geolocation_state NVARCHAR(2),
		dwh_lat_outside_brazil_flag BIT,
		dwh_lng_outside_brazil_flag BIT,
		dwh_created_date DATETIME2 DEFAULT GETDATE()
	);

	IF OBJECT_ID('silver.olist_customers_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE silver.olist_customers_dataset;
	END;

	CREATE TABLE silver.olist_customers_dataset
	(
		customer_id NVARCHAR(32),
		customer_unique_id NVARCHAR(32),
		customer_zip_code_prefix NVARCHAR(5),
		customer_city NVARCHAR(50),
		customer_state NVARCHAR(2),
		dwh_zip_code_prefix_not_in_geolocation_flag BIT,
		dwh_created_date DATETIME2 DEFAULT GETDATE()
	);

	IF OBJECT_ID('silver.olist_sellers_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE silver.olist_sellers_dataset;
	END;

	CREATE TABLE silver.olist_sellers_dataset
	(
		seller_id NVARCHAR(32),
		seller_zip_code_prefix NVARCHAR(5),
		seller_city NVARCHAR(50),
		seller_state NVARCHAR(2),
		dwh_zip_code_prefix_not_in_geolocation_flag BIT,
		dwh_city_quality_flag BIT,
		dwh_created_date DATETIME2 DEFAULT GETDATE()
	);

	IF OBJECT_ID('silver.olist_order_items_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE silver.olist_order_items_dataset;
	END;

	CREATE TABLE silver.olist_order_items_dataset
	(
		order_id NVARCHAR(50),
		order_item_id INT,
		product_id NVARCHAR(50),
		seller_id NVARCHAR(50),
		shipping_limit_date DATETIME2(0),
		price DECIMAL(16,2),
		freight_value DECIMAL(16,2),
		dwh_missing_order_id_flag BIT,
		dwh_missing_order_item_id_flag BIT,
		dwh_missing_product_id_flag BIT,
		dwh_missing_seller_id_flag BIT,
		dwh_invalid_price_flag BIT,
		dwh_invalid_freight_value_flag BIT,
		dwh_product_id_not_in_product_flag BIT,
		dwh_seller_id_not_in_seller_flag BIT,
		dwh_created_date DATETIME2 DEFAULT GETDATE()
	);

	IF OBJECT_ID('silver.olist_order_payments_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE silver.olist_order_payments_dataset;
	END;

	CREATE TABLE silver.olist_order_payments_dataset
	(
		order_id NVARCHAR(50),
		payment_sequential INT,
		payment_type NVARCHAR(20),
		payment_installments INT,
		payment_value DECIMAL(16,2),
		dwh_missing_order_id_flag BIT,
        dwh_invalid_payment_type_flag BIT,
        dwh_invalid_installments_flag BIT,
        dwh_invalid_payment_flag BIT,
        dwh_order_id_not_in_orders_flag BIT,
		dwh_created_date DATETIME2 DEFAULT GETDATE()
	);

	IF OBJECT_ID('silver.olist_order_reviews_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE silver.olist_order_reviews_dataset;
	END;

	CREATE TABLE silver.olist_order_reviews_dataset
	(
		review_id NVARCHAR(50),
		order_id NVARCHAR(50),
		review_score INT,
		review_comment_title NVARCHAR(40),
		review_comment_message NVARCHAR(400),
		review_creation_date DATETIME2(0),
		review_answer_timestamp DATETIME2(0),
		dwh_created_date DATETIME2 DEFAULT GETDATE()
	);

	IF OBJECT_ID('silver.olist_orders_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE silver.olist_orders_dataset;
	END;

	CREATE TABLE silver.olist_orders_dataset
	(
		order_id NVARCHAR(32),
		customer_id NVARCHAR(32),
		order_status NVARCHAR(20),
		order_purchase_timestamp DATETIME2(0),
		order_approved_at DATETIME2(0),
		order_delivered_carrier_date DATETIME2(0),
		order_delivered_customer_date DATETIME2(0),
		order_estimated_delivery_date DATETIME2(0),
		dwh_missing_order_id_flag BIT,
		dwh_missing_customer_id_flag BIT,
		dwh_missing_order_status_flag BIT,
		dwh_customer_id_not_in_customer_table_flag BIT,
		dwh_invalid_order_status_flag BIT,
		dwh_missing_purchase_date_flag BIT,
        dwh_missing_estimated_delivery_date_flag BIT,
        dwh_payment_not_approved_flag BIT,
        dwh_not_shipped_flag BIT,
        dwh_not_delivered_flag BIT,
        dwh_delivered_flag BIT,
        dwh_late_delivery_flag BIT,
        dwh_early_delivery_flag BIT,
        dwh_on_time_delivery_flag BIT,
		dwh_created_date DATETIME2 DEFAULT GETDATE()
	);

	IF OBJECT_ID('silver.olist_products_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE silver.olist_products_dataset;
	END;

	CREATE TABLE silver.olist_products_dataset
	(
		product_id NVARCHAR(32),
		product_category_name NVARCHAR(50),
		product_name_lenght INT,
		product_description_lenght INT,
		product_photos_qty INT,
		product_weight_g INT,
		product_length_cm DECIMAL(10,2),
		product_height_cm DECIMAL(10,2),
		product_width_cm DECIMAL(10,2),
		dwh_missing_product_id_flag BIT,
        dwh_missing_category_flag BIT,
        dwh_invalid_dimension_flag BIT,
        dwh_invalid_weight_flag BIT,
        dwh_category_name_not_in_category BIT,
		dwh_created_date DATETIME2 DEFAULT GETDATE()
	);
END