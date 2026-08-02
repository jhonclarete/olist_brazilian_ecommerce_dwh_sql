# Olist Brazilian E-commerce Data Warehouse

## Overview

This project implements a SQL-based data warehouse solution using the Brazilian E-Commerce Public Dataset by Olist. The entire data warehouse pipeline is developed using SQL, including database initialization, table creation, data loading, transformation processes, and analytical data modeling.

The project follows the Medallion Architecture approach, organizing data into three layers:

- Bronze Layer - Raw data ingestion layer
- Silver Layer - Cleaned and transformed data layer
- Gold Layer - Business-ready analytical data layer

The primary objective of this project is to design and build a structured data warehouse using SQL and perform business analysis using the curated datasets available in the Gold Layer.

## Dataset Reference
The original dataset was published by Olist and made publicly available through Kaggle for educational and analytical purposes.

Source: [Kaggle - Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data)

## Technology Stack
- SQL Server Database
- SQL DDL (Data Definition Language)
- SQL Stored Procedures
- SQL Data Transformation
- SQL Data Warehouse Modeling
- Medallion Architecture
- SQL-based Data Analytics

## Data Warehouse Loading Process
The complete data warehouse pipeline is executed using SQL scripts in the following order:

### Step 1: Initialize Database
Creates the database environment.

Script: sql/01_database_setup/init_database.sql

---

### Step 2: Create Bronze Layer

Creates Bronze Layer tables and stored procedures.

Script: sql/02_bronze/proc_ddl_bronze.sql

---

### Step 3: Load Bronze Layer

Loads raw Olist dataset into Bronze Layer tables.

Script: sql/02_bronze/proc_load_bronze.sql

---

### Step 4: Create Silver Layer

Creates Silver Layer tables and transformation procedures.

Script: sql/03_silver/proc_ddl_silver.sql

---

### Step 5: Load Silver Layer

Transforms and loads data from Bronze Layer into Silver Layer.

Script: sql/03_silver/proc_load_silver.sql

---

### Step 6: Create Gold Layer

Creates analytical tables for business analysis.

Script: sql/04_gold/proc_ddl_gold.sql

---

### Step 7: Load Gold Layer

Loads data from silver to gold.

Script: sql/04_gold/proc_load_gold.sql

---

### Step 8: Load Gold Layer

Executes the whole loading process from Bronze to Silver to Gold.

Script: runscript.sql

## Data Analysis

Business analysis is performed directly using the Gold Layer SQL tables.

The business questions used for analysis are documented in:

docs/business_questions.md

The corresponding SQL analysis scripts are located in:

sql/05_analysis/