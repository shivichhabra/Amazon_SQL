# Amazon SQL Project
Simulated Amazon-like e-commerce database using SQL.
 
The focus is on answering **business questions** (revenue, customer behavior, seller performance, operations) using **joins, CTEs, window functions, and time-based analysis**.

---

## Project Structure

- `ERD/` → ER diagram of the database
- `schema/01_create_tables.sql` → **High-level schema overview (intentionally abstracted)**
- `data/02_insert_sample_data.sql` → sample inserts (optional / lightweight)
- `queries/01_business_queries.sql` → 22 business questions + SQL solutions

---

## Business Questions Answered (22)

1. Top selling products  
2. Revenue by category + contribution %  
3. Average order value (AOV) per customer  
4. Monthly sales trend (last 2 years)  
5. Customers with no purchases  
6. Best-selling category by state  
7. Customer lifetime value (CLTV) + rank  
8. Inventory stock alerts (low stock)  
9. Shipping delays (> 4 days)  
10. Payment success rate  
11. Products never ordered  
12. Highest sales product in each category  
13. Products priced above category average  
14. Seller month-over-month growth  
15. Earliest & latest order dates  
16. Orders placed each day (2023)  
17. Orders in December 2023  
18. Weekend orders count  
19. Average order value per weekday  
20. Weekday with highest revenue  
21. Rank products by revenue within category  
22. Seller revenue percentile + performance tier

---

## Key Skills Demonstrated

- SQL joins (inner/left), aggregations, grouping
- CTEs for readable analysis pipelines
- Window functions: `RANK()`, `LAG()`, `PERCENT_RANK()`
- Time-series analysis: `DATE_TRUNC`, `EXTRACT`, intervals
- Business framing: translating questions → queries → insights

---

## Notes

- This is a **simulated dataset** created for learning and portfolio purposes.
- The schema is **intentionally simplified** to keep the focus on **analytics and querying**.
