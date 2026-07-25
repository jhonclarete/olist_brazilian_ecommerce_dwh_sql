-- This script creates tables in the 'bronze' schema, dropping existing tables if they already exist.

USE olist_brazilian_ecommerce_dwh;
GO

CREATE OR ALTER PROCEDURE bronze.setup_bronze_tables
AS
BEGIN
	IF OBJECT_ID('bronze.olist_customers_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE bronze.olist_customers_dataset;
	END;

	CREATE TABLE bronze.olist_customers_dataset
	(
		customer_id NVARCHAR(32),
		customer_unique_id NVARCHAR(32),
		customer_zip_code_prefix NVARCHAR(5),
		customer_city NVARCHAR(50),
		customer_state NVARCHAR(2)
	);

	IF OBJECT_ID('bronze.olist_geolocation_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE bronze.olist_geolocation_dataset;
	END;

	CREATE TABLE bronze.olist_geolocation_dataset
	(
		geolocation_zip_code_prefix NVARCHAR(5),
		geolocation_lat NVARCHAR(25),
		geolocation_lng NVARCHAR(25),
		geolocation_city NVARCHAR(50),
		geolocation_state NVARCHAR(2)
	);

	IF OBJECT_ID('bronze.olist_order_items_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE bronze.olist_order_items_dataset;
	END;

	CREATE TABLE bronze.olist_order_items_dataset
	(
		order_id NVARCHAR(32),
		order_item_id NVARCHAR(20),
		product_id NVARCHAR(32),
		seller_id NVARCHAR(32),
		shipping_limit_date NVARCHAR(50),
		price NVARCHAR(20),
		freight_value NVARCHAR(20)
	);

	IF OBJECT_ID('bronze.olist_order_payments_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE bronze.olist_order_payments_dataset;
	END;

	CREATE TABLE bronze.olist_order_payments_dataset
	(
		order_id NVARCHAR(32),
		payment_sequential NVARCHAR(20),
		payment_type NVARCHAR(20),
		payment_installments NVARCHAR(20),
		payment_value NVARCHAR(20)
	);

	IF OBJECT_ID('bronze.olist_order_reviews_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE bronze.olist_order_reviews_dataset;
	END;

	CREATE TABLE bronze.olist_order_reviews_dataset
	(
		review_id NVARCHAR(32),
		order_id NVARCHAR(32),
		review_score NVARCHAR(20),
		review_comment_title NVARCHAR(40),
		review_comment_message NVARCHAR(400),
		review_creation_date NVARCHAR(20),
		review_answer_timestamp NVARCHAR(20)
	);

	IF OBJECT_ID('bronze.olist_orders_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE bronze.olist_orders_dataset;
	END;

	CREATE TABLE bronze.olist_orders_dataset
	(
		order_id NVARCHAR(32),
		customer_id NVARCHAR(32),
		order_status NVARCHAR(20),
		order_purchase_timestamp NVARCHAR(50),
		order_approved_at NVARCHAR(50),
		order_delivered_carrier_date NVARCHAR(50),
		order_delivered_customer_date NVARCHAR(50),
		order_estimated_delivery_date NVARCHAR(50)
	);

	IF OBJECT_ID('bronze.olist_products_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE bronze.olist_products_dataset;
	END;

	CREATE TABLE bronze.olist_products_dataset
	(
		product_id NVARCHAR(32),
		product_category_name NVARCHAR(50),
		product_name_lenght NVARCHAR(20),
		product_description_lenght NVARCHAR(20),
		product_photos_qty NVARCHAR(20),
		product_weight_g NVARCHAR(20),
		product_length_cm NVARCHAR(20),
		product_height_cm NVARCHAR(20),
		product_width_cm NVARCHAR(20)
	);

	IF OBJECT_ID('bronze.olist_sellers_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE bronze.olist_sellers_dataset;
	END;

	CREATE TABLE bronze.olist_sellers_dataset
	(
		seller_id NVARCHAR(32),
		seller_zip_code_prefix NVARCHAR(5),
		seller_city NVARCHAR(50),
		seller_state NVARCHAR(2)
	);

	IF OBJECT_ID('bronze.olist_product_category_name_translation_dataset', 'U') IS NOT NULL
	BEGIN
		DROP TABLE bronze.olist_product_category_name_translation_dataset;
	END;

	CREATE TABLE bronze.olist_product_category_name_translation_dataset
	(
		product_category_name NVARCHAR(50),
		product_category_name_english NVARCHAR(50),
	);
END