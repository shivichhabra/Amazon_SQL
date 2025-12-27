/*
=========================================================
SCHEMA OVERVIEW (INTENTIONALLY ABSTRACTED)

This project uses a simulated Amazon-like relational schema.

Tables:
- customers (customer_id, first_name, last_name, state)
- sellers (seller_id, seller_name)
- category (category_id, category_name)
- products (product_id, product_name, category_id, price)
- orders (order_id, order_date, customer_id, seller_id, order_status)
- order_items (order_item_id, order_id, product_id, quantity, price_per_unit)
- payments (payment_id, order_id, payment_status, payment_mode)
- shipping (shipping_id, order_id, shipping_date, return_date, provider)
- inventory (inventory_id, product_id, stock, warehouse_id)

Note:
- Schema is simplified for analytical querying
- Focus of this project is business analytics using SQL
=========================================================
*/

