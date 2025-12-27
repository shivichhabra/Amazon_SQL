/* =========================================================
AMAZON SQL PROJECT — BUSINESS QUESTIONS (Q1–Q22)
SQL Dialect: PostgreSQL

Notes:
- total_sale is computed as (quantity * price_per_unit) in queries
========================================================= */

/* =========================
EDA (Quick Sanity Checks)
========================= */

-- EDA 1) Peek tables (limit to avoid huge output)
SELECT * FROM category LIMIT 20;
SELECT * FROM customers LIMIT 20;
SELECT * FROM inventory LIMIT 20;
SELECT * FROM order_items LIMIT 20;
SELECT * FROM orders LIMIT 20;
SELECT * FROM payments LIMIT 20;
SELECT * FROM products LIMIT 20;
SELECT * FROM sellers LIMIT 20;
SELECT * FROM shipping LIMIT 20;

-- EDA 2) Payment status values
SELECT DISTINCT payment_status
FROM payments;

-- EDA 3) Returned shipments
SELECT *
FROM shipping
WHERE return_date IS NOT NULL;

-- EDA 4) Shipping providers list
SELECT DISTINCT shipping_providers
FROM shipping;

-- EDA 5) Example: DHL shipments not returned
SELECT *
FROM shipping
WHERE shipping_providers = 'dhl'
  AND return_date IS NULL;



/* =========================================================
BUSINESS PROBLEMS
========================================================= */

-- Q1) Top Selling Products
-- Business Goal: Identify products with highest sales volume and revenue
SELECT
  p.product_id,
  p.product_name,
  ROUND(SUM(oi.quantity * oi.price_per_unit)::numeric, 2) AS total_sale,
  COUNT(*) AS line_item_count
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY line_item_count DESC, total_sale DESC;


-- Q2) Revenue by Category + Contribution %
-- Business Goal: Understand category revenue contribution to total revenue
SELECT 
  c.category_id,
  c.category_name,
  ROUND(SUM(oi.quantity * oi.price_per_unit)::numeric, 2) AS total_sale,
  ROUND(
    (SUM(oi.quantity * oi.price_per_unit)::numeric /
      NULLIF((SELECT SUM(quantity * price_per_unit)::numeric FROM order_items), 0)
    ) * 100
  , 2) AS contribution_percent
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN category c ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_sale DESC;


-- Q3) Avg Order Value (AOV) per Customer (min 5 orders)
-- Business Goal: Identify high-value customers based on average spend per order
SELECT 
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS full_name,
  ROUND(SUM(oi.quantity * oi.price_per_unit)::numeric, 2) AS total_spend,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(
    (SUM(oi.quantity * oi.price_per_unit)::numeric /
      NULLIF(COUNT(DISTINCT o.order_id), 0)
    ), 2
  ) AS avg_order_value
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, full_name
HAVING COUNT(DISTINCT o.order_id) > 5
ORDER BY avg_order_value DESC;


-- Q4) Monthly Sales Trend (last 2 years)
-- Business Goal: Track monthly revenue trend
SELECT
  EXTRACT(YEAR FROM o.order_date) AS year,
  EXTRACT(MONTH FROM o.order_date) AS month,
  ROUND(SUM(oi.quantity * oi.price_per_unit)::numeric, 2) AS total_sale
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY 1, 2
ORDER BY year, month;


-- Q5) Customers with No Purchases
-- Business Goal: Identify customers who never placed an order
SELECT COUNT(*) AS customers_with_no_orders
FROM customers
WHERE customer_id NOT IN (
  SELECT DISTINCT customer_id
  FROM orders
);


-- Q6) Best-selling Category by State (Top 1 per state)
-- Business Goal: Most popular category per state (by number of order items)
WITH ranking_table AS (
  SELECT
    c.state,
    ca.category_name,
    COUNT(oi.order_id) AS no_of_orders,
    RANK() OVER (PARTITION BY c.state ORDER BY COUNT(oi.order_id) DESC) AS rk
  FROM category ca
  JOIN products p ON p.category_id = ca.category_id
  JOIN order_items oi ON oi.product_id = p.product_id
  JOIN orders o ON o.order_id = oi.order_id
  JOIN customers c ON c.customer_id = o.customer_id
  GROUP BY c.state, ca.category_name
)
SELECT *
FROM ranking_table
WHERE rk = 1
ORDER BY state;


-- Q7) Customer Lifetime Value (CLTV) + Rank
-- Business Goal: Total spend per customer over all time
WITH cltv AS (
  SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    ROUND(SUM(oi.quantity * oi.price_per_unit)::numeric, 2) AS cltv
  FROM order_items oi
  JOIN orders o ON o.order_id = oi.order_id
  JOIN customers c ON c.customer_id = o.customer_id
  GROUP BY customer
)
SELECT
  customer,
  cltv,
  RANK() OVER (ORDER BY cltv DESC) AS rk
FROM cltv
ORDER BY rk, customer;


-- Q8) Inventory Stock Alerts (stock < 10)
-- Business Goal: Identify products at risk of stockout
SELECT 
  i.product_id,
  p.product_name,
  i.stock,
  i.warehouse_id,
  i.last_stock_date
FROM inventory i
JOIN products p ON p.product_id = i.product_id
WHERE i.stock < 10
ORDER BY i.stock ASC;


-- Q9) Shipping Delays (> 4 days from order date)
-- Business Goal: Find delayed shipments for operational review
SELECT
  CONCAT(c.first_name, ' ', c.last_name) AS customer,
  sel.seller_name,
  o.order_id,
  o.order_date,
  o.order_status,
  s.shipping_date,
  (s.shipping_date - o.order_date) AS days_to_ship
FROM shipping s
JOIN orders o ON o.order_id = s.order_id
JOIN sellers sel ON o.seller_id = sel.seller_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE (s.shipping_date - o.order_date) > 4
ORDER BY days_to_ship DESC;


-- Q10) Payment Success Rate (% by payment_status)
-- Business Goal: Payment reliability / failure rate
SELECT
  p.payment_status,
  COUNT(*) AS total_count,
  ROUND(
    COUNT(*)::numeric / NULLIF((SELECT COUNT(*) FROM payments)::numeric, 0) * 100
  , 2) AS percent_rate
FROM payments p
GROUP BY p.payment_status
ORDER BY percent_rate DESC;


-- Q11) Products Never Ordered
-- Business Goal: Identify dead inventory / products with zero demand
SELECT
  p.product_id,
  p.product_name
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.order_id IS NULL
ORDER BY p.product_id;


-- Q12) Highest Sales Product in Each Category
-- Business Goal: Best performing product per category
WITH ranking AS (
  SELECT
    c.category_name,
    p.product_id,
    p.product_name,
    ROUND(SUM(oi.quantity * oi.price_per_unit)::numeric, 2) AS total_sale,
    RANK() OVER (
      PARTITION BY c.category_name
      ORDER BY SUM(oi.quantity * oi.price_per_unit) DESC
    ) AS rk
  FROM products p
  JOIN category c ON c.category_id = p.category_id
  JOIN order_items oi ON oi.product_id = p.product_id
  GROUP BY c.category_name, p.product_id, p.product_name
)
SELECT *
FROM ranking
WHERE rk = 1
ORDER BY category_name, total_sale DESC;


-- Q13) Products with Avg Selling Price > Category Avg Selling Price
-- Business Goal: Premium products priced above category norms
WITH averages AS (
  SELECT
    c.category_name,
    p.product_id,
    p.product_name,
    AVG(oi.price_per_unit) AS avg_selling_price,
    AVG(AVG(oi.price_per_unit)) OVER (PARTITION BY c.category_name) AS category_avg_price
  FROM products p
  JOIN category c ON c.category_id = p.category_id
  JOIN order_items oi ON oi.product_id = p.product_id
  GROUP BY c.category_name, p.product_id, p.product_name
)
SELECT *
FROM averages
WHERE avg_selling_price > category_avg_price
ORDER BY category_name, avg_selling_price DESC;


-- Q14) Seller Month-over-Month Growth in Sales
-- Business Goal: Track seller performance growth trend
WITH monthly_sales AS (
  SELECT
    s.seller_id,
    s.seller_name,
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(oi.quantity * oi.price_per_unit) AS monthly_sale
  FROM sellers s
  JOIN orders o ON o.seller_id = s.seller_id
  JOIN order_items oi ON oi.order_id = o.order_id
  GROUP BY s.seller_id, s.seller_name, DATE_TRUNC('month', o.order_date)
)
SELECT 
  seller_id,
  seller_name,
  month,
  ROUND(monthly_sale::numeric, 2) AS monthly_sale,
  ROUND(LAG(monthly_sale) OVER (PARTITION BY seller_id ORDER BY month)::numeric, 2) AS previous_month_sale,
  ROUND(
    (monthly_sale::numeric - LAG(monthly_sale) OVER (PARTITION BY seller_id ORDER BY month)::numeric)
    / NULLIF(LAG(monthly_sale) OVER (PARTITION BY seller_id ORDER BY month)::numeric, 0)
    * 100
  , 2) AS growth_percent
FROM monthly_sales
ORDER BY seller_id, month;


-- Q15) Earliest and Latest Order Dates
-- Business Goal: Understand dataset coverage period
SELECT
  MIN(order_date) AS earliest_order_date,
  MAX(order_date) AS latest_order_date
FROM orders;


-- Q16) Number of Orders Placed Each Day (Year 2023)
-- Business Goal: Daily demand distribution
SELECT
  order_date,
  COUNT(order_id) AS total_orders
FROM orders
WHERE EXTRACT(YEAR FROM order_date) = 2023
GROUP BY order_date
ORDER BY order_date;


-- Q17) All Orders Placed in December 2023
-- Business Goal: Filter orders by time period
SELECT
  order_id,
  order_date
FROM orders
WHERE EXTRACT(YEAR FROM order_date) = 2023
  AND EXTRACT(MONTH FROM order_date) = 12
ORDER BY order_date;


-- Q18) Weekend Orders Count (Saturday & Sunday)
-- Business Goal: Weekend demand volume
SELECT
  CASE
    WHEN EXTRACT(DOW FROM order_date) = 6 THEN 'Saturday'
    WHEN EXTRACT(DOW FROM order_date) = 0 THEN 'Sunday'
  END AS day_name,
  COUNT(order_id) AS total_orders
FROM orders
WHERE EXTRACT(DOW FROM order_date) IN (0, 6)
GROUP BY day_name
ORDER BY total_orders DESC;


-- Q19) Average Order Value per Weekday (Mon–Sun)
-- Business Goal: Compare weekday spending
SELECT
  CASE EXTRACT(DOW FROM o.order_date)
    WHEN 1 THEN 'Monday'
    WHEN 2 THEN 'Tuesday'
    WHEN 3 THEN 'Wednesday'
    WHEN 4 THEN 'Thursday'
    WHEN 5 THEN 'Friday'
    WHEN 6 THEN 'Saturday'
    WHEN 0 THEN 'Sunday'
  END AS day_name,
  ROUND(AVG(oi.quantity * oi.price_per_unit)::numeric, 2) AS avg_sales
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY EXTRACT(DOW FROM o.order_date)
ORDER BY
  CASE
    WHEN EXTRACT(DOW FROM o.order_date) = 0 THEN 7
    ELSE EXTRACT(DOW FROM o.order_date)
  END;


-- Q20) Day of Week with Highest Revenue
-- Business Goal: Identify peak revenue day
WITH day_sales AS (
  SELECT
    CASE
      WHEN EXTRACT(DOW FROM o.order_date) = 1 THEN 'Monday'
      WHEN EXTRACT(DOW FROM o.order_date) = 2 THEN 'Tuesday'
      WHEN EXTRACT(DOW FROM o.order_date) = 3 THEN 'Wednesday'
      WHEN EXTRACT(DOW FROM o.order_date) = 4 THEN 'Thursday'
      WHEN EXTRACT(DOW FROM o.order_date) = 5 THEN 'Friday'
      WHEN EXTRACT(DOW FROM o.order_date) = 6 THEN 'Saturday'
      WHEN EXTRACT(DOW FROM o.order_date) = 0 THEN 'Sunday'
    END AS day_name,
    ROUND(SUM(oi.quantity * oi.price_per_unit)::numeric, 2) AS day_sale
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  GROUP BY day_name
)
SELECT *
FROM day_sales
ORDER BY day_sale DESC
LIMIT 1;


-- Q21) Rank Products by Revenue Within Each Category (RANK)
-- Business Goal: Identify top products per category
SELECT
  c.category_id,
  c.category_name,
  p.product_id,
  p.product_name,
  ROUND(SUM(oi.quantity * oi.price_per_unit)::numeric, 2) AS total_sale,
  RANK() OVER (
    PARTITION BY c.category_name
    ORDER BY SUM(oi.quantity * oi.price_per_unit) DESC
  ) AS rk
FROM products p
JOIN category c ON c.category_id = p.category_id
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY c.category_id, c.category_name, p.product_id, p.product_name
ORDER BY c.category_id, total_sale DESC;


-- Q22) Percentile Revenue per Seller + Performance Tier (PERCENT_RANK)
-- Business Goal: Segment sellers into performance buckets
WITH percentile AS (
  SELECT 
    s.seller_id,
    s.seller_name,
    ROUND(SUM(oi.quantity * oi.price_per_unit)::numeric, 4) AS revenue,
    PERCENT_RANK() OVER (ORDER BY SUM(oi.quantity * oi.price_per_unit)::numeric) AS percentile_revenue
  FROM sellers s
  JOIN orders o ON o.seller_id = s.seller_id
  JOIN order_items oi ON oi.order_id = o.order_id
  GROUP BY s.seller_id, s.seller_name
)
SELECT *,
  CASE
    WHEN percentile_revenue >= 0.9 THEN 'Elite'
    WHEN percentile_revenue >= 0.5 THEN 'Strong'
    ELSE 'Emerging'
  END AS performance
FROM percentile
ORDER BY percentile_revenue DESC;

