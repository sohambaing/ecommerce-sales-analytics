-- E-Commerce Sales & Business Performance Analytics
-- Tool: MySQL

-- 1. View the dataset
SELECT *
FROM ecommerce_sales;

-- 2. Total revenue
SELECT ROUND(SUM(net_revenue), 2) AS total_revenue
FROM ecommerce_sales;

-- 3. Total orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM ecommerce_sales;

-- 4. Unique customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM ecommerce_sales;

-- 5. Average Order Value
SELECT ROUND(AVG(order_revenue), 2) AS average_order_value
FROM (
SELECT order_id, SUM(net_revenue) AS order_revenue
FROM ecommerce_sales
GROUP BY order_id
) AS order_summary;

-- 6. Revenue by category
SELECT
product_category,
ROUND(SUM(net_revenue), 2) AS total_revenue
FROM ecommerce_sales
GROUP BY product_category
ORDER BY total_revenue DESC;

-- 7. Revenue by region
SELECT
region,
ROUND(SUM(net_revenue), 2) AS total_revenue
FROM ecommerce_sales
GROUP BY region
ORDER BY total_revenue DESC;
