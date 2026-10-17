# SQL Exercises

Use the practice shop database ([schema](01-schema.sql), [data](02-seed.sql)). Try each one before opening the answer. Then compare your output with the answer query's output.

## Level 1: basics

1. List all products in the `Accessories` category, cheapest first.
2. How many customers are there in each country?
3. List orders placed in or after June 2026 that are not cancelled.

<details><summary>Answers</summary>

```sql
-- 1
SELECT name, price FROM products WHERE category = 'Accessories' ORDER BY price;

-- 2
SELECT country, COUNT(*) AS customers FROM customers GROUP BY country ORDER BY customers DESC;

-- 3
SELECT * FROM orders WHERE order_date >= '2026-06-01' AND status <> 'cancelled' ORDER BY order_date;
```
</details>

## Level 2: joins

4. Show every order with the customer's name and the order status.
5. Which customers have never placed an order?
6. Which products have never been ordered?
7. List each product with the total quantity sold (exclude cancelled orders).

<details><summary>Answers</summary>

```sql
-- 4
SELECT o.order_id, c.name, o.status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_id;

-- 5
SELECT c.name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- 6
SELECT p.name
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL;

-- 7
SELECT p.name,
       COALESCE(SUM(CASE WHEN o.status <> 'cancelled' THEN oi.quantity END), 0) AS units_sold
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN orders o       ON o.order_id = oi.order_id
GROUP BY p.name
ORDER BY units_sold DESC;
```
(Exercise 7 is tricky: `LEFT JOIN` keeps products that were never ordered, and the `CASE` counts only items from orders that weren't cancelled. `COALESCE` turns "no rows" (NULL) into 0.)
</details>

## Level 3: aggregation

8. What is the total value of each order? (Sum of `quantity × unit_price`.)
9. Which customers have spent more than $300 in total (excluding cancelled orders)?
10. What's the revenue per product category (excluding cancelled orders)?

<details><summary>Answers</summary>

```sql
-- 8
SELECT order_id, SUM(quantity * unit_price) AS order_total
FROM order_items
GROUP BY order_id
ORDER BY order_id;

-- 9
SELECT c.name, SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
JOIN orders o       ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status <> 'cancelled'
GROUP BY c.name
HAVING SUM(oi.quantity * oi.unit_price) > 300
ORDER BY total_spent DESC;

-- 10
SELECT p.category, SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders o   ON o.order_id = oi.order_id
WHERE o.status <> 'cancelled'
GROUP BY p.category
ORDER BY revenue DESC;
```
</details>

## Level 4: interview-style

11. For each customer, show their most recent order date.
12. Rank customers by total spend (excluding cancelled orders) using a window function.
13. Find orders where any item was sold below the product's current list price (a discount was given).
14. Write a transaction that marks order 8 as `shipped`, then roll it back. Verify nothing changed.

<details><summary>Answers</summary>

```sql
-- 11
SELECT c.name, MAX(o.order_date) AS last_order
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.name
ORDER BY last_order DESC;

-- 12
WITH spend AS (
    SELECT c.name, SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM customers c
    JOIN orders o       ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY c.name
)
SELECT name, total_spent, RANK() OVER (ORDER BY total_spent DESC) AS spend_rank
FROM spend;

-- 13
SELECT DISTINCT oi.order_id, p.name, oi.unit_price, p.price AS list_price
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
WHERE oi.unit_price < p.price;

-- 14
BEGIN;
UPDATE orders SET status = 'shipped' WHERE order_id = 8;
SELECT order_id, status FROM orders WHERE order_id = 8;   -- shows 'shipped' inside the transaction
ROLLBACK;
SELECT order_id, status FROM orders WHERE order_id = 8;   -- back to 'pending'
```
</details>

## Bonus: design

15. The shop wants to store **multiple shipping addresses per customer** and record which address each order was shipped to. Write the `CREATE TABLE` statement(s) and any `ALTER TABLE` needed.

<details><summary>One possible answer</summary>

```sql
CREATE TABLE addresses (
    address_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers (customer_id),
    line1       TEXT NOT NULL,
    city        TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    country     TEXT NOT NULL
);

ALTER TABLE orders ADD COLUMN shipping_address_id INT REFERENCES addresses (address_id);
```
</details>
