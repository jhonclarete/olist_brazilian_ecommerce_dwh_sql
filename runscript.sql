USE olist_brazilian_ecommerce_dwh
GO

EXECUTE bronze.setup_bronze_tables;
EXECUTE bronze.load_bronze;

EXECUTE silver.setup_silver_tables;
EXECUTE silver.load_silver;

EXECUTE gold.setup_gold_views;