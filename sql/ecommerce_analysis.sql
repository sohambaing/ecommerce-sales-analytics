USE ecommerce_project;

-- 0. BASIC DATA CHECK


SELECT COUNT(*) AS total_rows
FROM ecommerce_sales;

-- 1. TOTAL REVENUE

SELECT
    ROUND(SUM(revenue), 2) AS total_revenue
FROM ecommerce_sales;

-- 2. TOTAL ORDERS


SELECT
    COUNT(*) AS total_orders
FROM ecommerce_sales;



-- 3. UNIQUE CUSTOMERS


SELECT
    COUNT(DISTINCT customer_id) AS unique_customers
FROM ecommerce_sales;



-- 4. AVERAGE ORDER VALUE (AOV)


SELECT
    ROUND(AVG(revenue), 2) AS avg_order_value
FROM ecommerce_sales;



-- 5. AVERAGE CUSTOMER RATING


SELECT
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM ecommerce_sales;



-- 6. AVERAGE DELIVERY TIME


SELECT
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days
FROM ecommerce_sales;



-- 7. REVENUE BY PRODUCT CATEGORY


SELECT
    product_category,
    ROUND(SUM(revenue), 2) AS revenue,
    COUNT(*) AS orders,
    ROUND(AVG(revenue), 2) AS aov
FROM ecommerce_sales
GROUP BY product_category
ORDER BY revenue DESC;

-- 8. REVENUE SHARE BY PRODUCT CATEGORY

WITH category_sales AS (
    SELECT
        product_category,
        SUM(revenue) AS revenue
    FROM ecommerce_sales
    GROUP BY product_category
)
SELECT
    product_category,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        100.0 * revenue / SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct
FROM category_sales
ORDER BY revenue DESC;



-- 9. REVENUE BY REGION


SELECT
    region,
    ROUND(SUM(revenue), 2) AS revenue,
    COUNT(*) AS orders,
    ROUND(AVG(revenue), 2) AS aov
FROM ecommerce_sales
GROUP BY region
ORDER BY revenue DESC;

-- 10. PAYMENT METHOD PERFORMANCE

SELECT
    payment_method,
    COUNT(*) AS orders,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(AVG(revenue), 2) AS aov,
    ROUND(AVG(customer_rating), 2) AS avg_rating
FROM ecommerce_sales
GROUP BY payment_method
ORDER BY revenue DESC;


-- 11. MONTHLY REVENUE


SELECT
    DATE_FORMAT(
        STR_TO_DATE(TRIM(order_date), '%c/%e/%Y'),
        '%Y-%m-01'
    ) AS month,
    ROUND(SUM(revenue), 2) AS revenue,
    COUNT(*) AS orders
FROM ecommerce_sales
GROUP BY
    DATE_FORMAT(
        STR_TO_DATE(TRIM(order_date), '%c/%e/%Y'),
        '%Y-%m-01'
    )
ORDER BY month;



-- 12. MONTHLY REVENUE + MoM GROWTH


WITH monthly AS (
    SELECT
        DATE_FORMAT(
            STR_TO_DATE(TRIM(order_date), '%c/%e/%Y'),
            '%Y-%m-01'
        ) AS month,
        SUM(revenue) AS revenue
    FROM ecommerce_sales
    GROUP BY
        DATE_FORMAT(
            STR_TO_DATE(TRIM(order_date), '%c/%e/%Y'),
            '%Y-%m-01'
        )
),
growth AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS prior_month_revenue
    FROM monthly
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(prior_month_revenue, 2) AS prior_month_revenue,
    ROUND(
        100.0 * (revenue - prior_month_revenue)
        / NULLIF(prior_month_revenue, 0),
        2
    ) AS mom_growth_pct
FROM growth
ORDER BY month;


-- 13. TOP 20 CUSTOMERS BY REVENUE


SELECT
    customer_id,
    COUNT(*) AS orders,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(AVG(revenue), 2) AS aov
FROM ecommerce_sales
GROUP BY customer_id
ORDER BY revenue DESC
LIMIT 20;



-- 14. REPEAT VS SINGLE-PURCHASE CUSTOMERS


WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(*) AS orders
    FROM ecommerce_sales
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN orders > 1 THEN 'Repeat'
        ELSE 'Single'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_share_pct
FROM customer_orders
GROUP BY customer_type
ORDER BY customer_type;



-- 15. CUSTOMER REVENUE RANKING


SELECT
    customer_id,
    ROUND(SUM(revenue), 2) AS revenue,
    RANK() OVER (
        ORDER BY SUM(revenue) DESC
    ) AS revenue_rank
FROM ecommerce_sales
GROUP BY customer_id
ORDER BY revenue_rank;



-- 16. CUMULATIVE REVENUE BY MONTH


WITH monthly AS (
    SELECT
        DATE_FORMAT(
            STR_TO_DATE(TRIM(order_date), '%c/%e/%Y'),
            '%Y-%m-01'
        ) AS month,
        SUM(revenue) AS revenue
    FROM ecommerce_sales
    GROUP BY
        DATE_FORMAT(
            STR_TO_DATE(TRIM(order_date), '%c/%e/%Y'),
            '%Y-%m-01'
        )
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        SUM(revenue) OVER (ORDER BY month),
        2
    ) AS cumulative_revenue
FROM monthly
ORDER BY month;


-- 17. AVERAGE DELIVERY TIME BY REGION


SELECT
    region,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    COUNT(*) AS orders
FROM ecommerce_sales
GROUP BY region
ORDER BY avg_delivery_days DESC;



-- 18. DELIVERY SPEED BAND VS CUSTOMER RATING


SELECT
    CASE
        WHEN delivery_days <= 3 THEN '1-3 days'
        WHEN delivery_days <= 7 THEN '4-7 days'
        ELSE '8+ days'
    END AS delivery_band,
    COUNT(*) AS orders,
    ROUND(AVG(customer_rating), 2) AS avg_rating
FROM ecommerce_sales
GROUP BY
    CASE
        WHEN delivery_days <= 3 THEN '1-3 days'
        WHEN delivery_days <= 7 THEN '4-7 days'
        ELSE '8+ days'
    END
ORDER BY
    CASE
        WHEN delivery_days <= 3 THEN 1
        WHEN delivery_days <= 7 THEN 2
        ELSE 3
    END;


-- 19. DISCOUNT BAND PERFORMANCE


SELECT
    CASE
        WHEN discount = 0 THEN '0%'
        WHEN discount <= 0.10 THEN '1-10%'
        WHEN discount <= 0.20 THEN '11-20%'
        WHEN discount <= 0.30 THEN '21-30%'
        ELSE '31-35%'
    END AS discount_band,
    COUNT(*) AS orders,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(AVG(revenue), 2) AS aov
FROM ecommerce_sales
GROUP BY
    CASE
        WHEN discount = 0 THEN '0%'
        WHEN discount <= 0.10 THEN '1-10%'
        WHEN discount <= 0.20 THEN '11-20%'
        WHEN discount <= 0.30 THEN '21-30%'
        ELSE '31-35%'
    END
ORDER BY
    CASE
        WHEN discount = 0 THEN 1
        WHEN discount <= 0.10 THEN 2
        WHEN discount <= 0.20 THEN 3
        WHEN discount <= 0.30 THEN 4
        ELSE 5
    END;

-- 20. DISCOUNT LEVEL VS AVERAGE QUANTITY AND REVENUE

SELECT
    ROUND(discount * 100) AS discount_pct,
    ROUND(AVG(quantity), 2) AS avg_quantity,
    ROUND(AVG(revenue), 2) AS avg_revenue
FROM ecommerce_sales
GROUP BY ROUND(discount * 100)
ORDER BY discount_pct;

-- 21. CATEGORY x REGION REVENUE MATRIX


SELECT
    product_category,
    region,
    ROUND(SUM(revenue), 2) AS revenue,
    COUNT(*) AS orders
FROM ecommerce_sales
GROUP BY product_category, region
ORDER BY revenue DESC;


-- 22. TOP CATEGORY IN EACH REGION


WITH category_region AS (
    SELECT
        region,
        product_category,
        SUM(revenue) AS revenue
    FROM ecommerce_sales
    GROUP BY region, product_category
),
ranked AS (
    SELECT
        region,
        product_category,
        revenue,
        ROW_NUMBER() OVER (
            PARTITION BY region
            ORDER BY revenue DESC
        ) AS rn
    FROM category_region
)
SELECT
    region,
    product_category,
    ROUND(revenue, 2) AS revenue
FROM ranked
WHERE rn = 1
ORDER BY region;


-- 23. MOST COMMON PAYMENT METHOD BY REGION

WITH payment_region AS (
    SELECT
        region,
        payment_method,
        COUNT(*) AS orders
    FROM ecommerce_sales
    GROUP BY region, payment_method
),
ranked AS (
    SELECT
        region,
        payment_method,
        orders,
        ROW_NUMBER() OVER (
            PARTITION BY region
            ORDER BY orders DESC, payment_method
        ) AS rn
    FROM payment_region
)
SELECT
    region,
    payment_method,
    orders
FROM ranked
WHERE rn = 1
ORDER BY region;


-- 24. QUARTERLY REVENUE

SELECT
    CONCAT(
        YEAR(STR_TO_DATE(TRIM(order_date), '%c/%e/%Y')),
        '-Q',
        QUARTER(STR_TO_DATE(TRIM(order_date), '%c/%e/%Y'))
    ) AS quarter,
    ROUND(SUM(revenue), 2) AS revenue
FROM ecommerce_sales
GROUP BY
    YEAR(STR_TO_DATE(TRIM(order_date), '%c/%e/%Y')),
    QUARTER(STR_TO_DATE(TRIM(order_date), '%c/%e/%Y'))
ORDER BY
    YEAR(STR_TO_DATE(TRIM(order_date), '%c/%e/%Y')),
    QUARTER(STR_TO_DATE(TRIM(order_date), '%c/%e/%Y'));


-- 25. HIGH-VALUE ORDERS

SELECT
    *
FROM ecommerce_sales
WHERE revenue >= 2000
ORDER BY revenue DESC;

-- 26. INVALID / UNPARSEABLE DATES CHECK


SELECT
    COUNT(*) AS invalid_order_dates
FROM ecommerce_sales
WHERE STR_TO_DATE(TRIM(order_date), '%Y-%m-%d') IS NULL;
