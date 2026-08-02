USE olist_brazilian_ecommerce_dwh
GO

-- Q1. What is the total revenue generated from all delivered orders?
SELECT SUM(total_item_amount) AS total_revenue 
FROM gold.fact_order_items
WHERE order_status = 'delivered'

-- Q2. How many delivered orders were completed?
SELECT COUNT(DISTINCT order_id) AS delivered_orders_completed
FROM gold.fact_order_items
WHERE order_status = 'delivered'

-- Q3. How many items were sold by month?
SELECT d.[year], d.month_name, SUM(oi.quantity) AS items_sold
FROM gold.fact_order_items oi
INNER JOIN gold.dim_date d
ON oi.purchase_date_key = d.date_key
WHERE oi.order_status = 'delivered'
GROUP BY d.[year], d.month_name
ORDER BY d.[year], d.month_name

-- Q4. What are the top 10 product categories by revenue?
SELECT TOP 10
    p.product_category_name_english AS [category],
    SUM(oi.total_item_amount) AS revenue
FROM gold.fact_order_items oi
INNER JOIN gold.dim_product p
ON oi.product_id = p.product_id
WHERE oi.order_status = 'delivered'
GROUP BY p.product_category_name_english
ORDER BY SUM(oi.total_item_amount) DESC

-- Q5. Which product categories sold the most items?
SELECT TOP 10
    p.product_category_name_english AS [category],
    SUM(oi.quantity) AS items_sold
FROM gold.fact_order_items oi
INNER JOIN gold.dim_product p
ON oi.product_id = p.product_id
WHERE oi.order_status = 'delivered'
GROUP BY p.product_category_name_english
ORDER BY SUM(oi.quantity) DESC

-- Q6. What is the average selling price by product category?
SELECT TOP 10
    p.product_category_name_english AS [category],
    AVG(oi.price) AS avg_selling_price
FROM gold.fact_order_items oi
INNER JOIN gold.dim_product p
ON oi.product_id = p.product_id
WHERE oi.order_status = 'delivered'
GROUP BY p.product_category_name_english
ORDER BY AVG(oi.price) DESC

-- Q7. Which products generate the highest revenue?
SELECT TOP 20
    p.product_category_name_english AS [category],
    AVG(oi.total_item_amount) AS revenue
FROM gold.fact_order_items oi
INNER JOIN gold.dim_product p
ON oi.product_id = p.product_id
WHERE oi.order_status = 'delivered'
GROUP BY p.product_category_name_english
ORDER BY AVG(oi.total_item_amount) DESC

-- Q8. Which products have the highest number of reviews?
SELECT TOP 10
    p.product_category_name_english,
    COUNT(*) AS num_reviews
FROM gold.fact_order_items oi
INNER JOIN gold.fact_reviews r
ON oi.order_id = r.order_id
INNER JOIN gold.dim_product p
ON oi.product_id = p.product_id
WHERE oi.order_status = 'delivered'
GROUP BY p.product_category_name_english
ORDER BY COUNT(*) DESC

-- Q9. What is the average order item value?
SELECT AVG(total_item_amount)
FROM gold.fact_order_items
WHERE order_status = 'delivered'

-- Q10. Which months generated the highest revenue?
SELECT 
    d.[year], 
    d.month_name,
    SUM(oi.total_item_amount) AS revenue
FROM gold.fact_order_items oi
INNER JOIN gold.dim_date d
ON oi.purchase_date_key = d.date_key
WHERE oi.order_status = 'delivered'
GROUP BY d.[year], d.month_name
ORDER BY SUM(oi.total_item_amount) DESC, d.[year], d.month_name