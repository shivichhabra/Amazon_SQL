# Dataset Information — Amazon SQL (Simulated)

## Overview
This dataset simulates an Amazon-like e-commerce platform for SQL analytics practice.  
It supports analysis across:
- sales & revenue
- customer ordering behavior
- seller performance
- payments, shipping, and returns
- inventory / stock risk

## Entities (Tables)
- **customers**: customer profile + state
- **sellers**: seller directory
- **category**: product categories
- **products**: product catalog (linked to category)
- **orders**: order header (customer, seller, status, date)
- **order_items**: order lines (product, quantity, price_per_unit)
- **payments**: payment details + status per order
- **shipping**: shipping provider, shipping date, return date
- **inventory**: stock availability by product and warehouse

## Key Columns Used in Analysis
- `orders.order_date` for time-based trends (`EXTRACT`, `DATE_TRUNC`)
- `order_items.quantity`, `order_items.price_per_unit` to compute sales
- `customers.state` for geographic breakdown
- `shipping.shipping_date`, `shipping.return_date` for delays/returns
- `payments.payment_status` for success rate
- `inventory.stock` for low stock alerts

## Assumptions
- Sales is computed as: **quantity × price_per_unit**
- Each order can have multiple order items
- Payment and shipping records are at the order level
- Inventory is tracked at product level per warehouse

## Data Source
Simulated / synthetic dataset created for portfolio use (not real Amazon data).

