-- This script creates views in the 'gold' schema, dropping existing views if they already exist.

USE olist_brazilian_ecommerce_dwh;
GO

CREATE OR ALTER PROCEDURE gold.setup_gold_tables
AS
BEGIN
    IF OBJECT_ID('gold.dim_customer', 'U') IS NOT NULL
	BEGIN
		DROP TABLE gold.dim_customer;
	END;

	CREATE TABLE gold.dim_customer
	(
        customer_key INT,
		customer_id NVARCHAR(32),
		customer_unique_id NVARCHAR(32),
		customer_zip_code_prefix NVARCHAR(5),
		customer_city NVARCHAR(50),
		customer_state NVARCHAR(2),
		dwh_zip_code_prefix_not_in_geolocation_flag BIT
	);

    IF OBJECT_ID('gold.dim_product', 'U') IS NOT NULL
	BEGIN
		DROP TABLE gold.dim_product;
	END;

	CREATE TABLE gold.dim_product
	(
        product_key INT,
		product_id NVARCHAR(32),
		product_category_name NVARCHAR(50),
        product_category_name_english NVARCHAR(50),
		product_name_lenght INT,
		product_description_lenght INT,
		product_photos_qty INT,
		product_weight_g INT,
		product_length_cm DECIMAL(10,2),
		product_height_cm DECIMAL(10,2),
		product_width_cm DECIMAL(10,2),
		dwh_category_name_not_in_category_flag BIT,
        dwh_invalid_product_weight_g_flag BIT,
	);

    IF OBJECT_ID('gold.dim_seller', 'U') IS NOT NULL
	BEGIN
		DROP TABLE gold.dim_seller;
	END;

	CREATE TABLE gold.dim_seller
	(
		seller_key INT,
        seller_id NVARCHAR(32),
		seller_zip_code_prefix NVARCHAR(5),
		seller_city NVARCHAR(50),
		seller_state NVARCHAR(2),
		dwh_zip_code_prefix_not_in_geolocation_flag BIT,
		dwh_city_quality_flag BIT
	);

    IF OBJECT_ID('gold.dim_date', 'U') IS NOT NULL
	BEGIN
		DROP TABLE gold.dim_date;
	END;

	CREATE TABLE gold.dim_date
	(
		date_key INT,
        full_date DATE,
        [year] SMALLINT,
        quarter SMALLINT,
        [month] SMALLINT,
        month_name NVARCHAR(30),
        [day] SMALLINT,
        day_of_week SMALLINT,
        day_name NVARCHAR(30),
        is_weekend BIT
	);

    IF OBJECT_ID('gold.fact_order_items', 'U') IS NOT NULL
	BEGIN
		DROP TABLE gold.fact_order_items;
	END;

	CREATE TABLE gold.fact_order_items
	(
		order_id NVARCHAR(32),
        order_item_id INT,
        customer_id NVARCHAR(32),
        customer_key INT,
        product_id NVARCHAR(32),
        product_key INT,
        seller_id NVARCHAR(32), 
        seller_key INT,
        purchase_date_key INT,
        order_status NVARCHAR(20),
        quantity SMALLINT,
        price DECIMAL(16,2),
        freight_value DECIMAL(16,2),
        total_item_amount DECIMAL(16,2)
	);

    IF OBJECT_ID('gold.fact_payments', 'U') IS NOT NULL
	BEGIN
		DROP TABLE gold.fact_payments;
	END;

	CREATE TABLE gold.fact_payments
	(
		order_id NVARCHAR(32),
        customer_id NVARCHAR(32),
        customer_key INT,
        purchase_date_key INT,
        payment_sequential SMALLINT,
        payment_type NVARCHAR(20),
        payment_installments INT,
        payment_value DECIMAL(16,2),
        payment_count SMALLINT,
        dwh_installments_less_than_zero_flag BIT
	);

    IF OBJECT_ID('gold.fact_delivery', 'U') IS NOT NULL
	BEGIN
		DROP TABLE gold.fact_delivery;
	END;

	CREATE TABLE gold.fact_delivery
	(
		order_id NVARCHAR(32),
        customer_id NVARCHAR(32),
        customer_key INT,
        purchase_date_key INT,
        approved_date_key INT,
        shipped_date_key INT,
        delivered_date_key INT,
        estimated_delivery_date_key INT,
        delivery_days SMALLINT,
        estimated_delivery_days SMALLINT,
        late_delivery_fla BIT,
        dwh_missing_approval_date_flag BIT,
        dwh_missing_carrier_date_flag BIT,
        dwh_missing_delivery_date_flag BIT,
        dwh_shipment_before_approval_flag BIT,
        dwh_delivery_before_shipment_flag BIT,
        delivery_status NVARCHAR(30),
        processing_days SMALLINT,
        shipping_days SMALLINT,
        shipping_to_customer_days SMALLINT
	);

    IF OBJECT_ID('gold.fact_reviews', 'U') IS NOT NULL
	BEGIN
		DROP TABLE gold.fact_reviews;
	END;

	CREATE TABLE gold.fact_reviews
	(
		review_id NVARCHAR(32),
        order_id NVARCHAR(32),
        customer_id NVARCHAR(32),
        customer_key INT,
        review_creation_date_key INT,
        review_score SMALLINT,
        review_comment_title NVARCHAR(40),
        review_comment_message NVARCHAR(400),
        dwh_duplicate_review_flag BIT,
        review_answer_date_key INT
	);
END