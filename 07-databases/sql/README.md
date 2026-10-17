# SQL Tutorial

> SQL (Structured Query Language) is how you talk to relational databases. You describe **what** data you want; the database figures out **how** to get it.

All examples use the practice shop database. Load it first with the steps in [PostgreSQL › run it with Docker](../postgresql/README.md#run-postgresql-locally-with-docker), then connect with `psql`.

Tables: `customers`, `products`, `orders`, `order_items` (see [`01-schema.sql`](01-schema.sql)).

## 1. SELECT basics

```sql
SELECT * FROM customers;                               -- everything (avoid in production code)
SELECT name, country FROM customers;                   -- specific columns
SELECT name, price FROM products ORDER BY price DESC;  -- sort, highest first
SELECT name, price FROM products ORDER BY price DESC LIMIT 3;   -- top 3
SELECT DISTINCT country FROM customers;                -- unique values
SELECT name, price * 1.2 AS price_with_vat FROM products;       -- calculated column with an alias
```

## 2. Filtering with WHERE

```sql
SELECT * FROM customers WHERE country = 'UK';
SELECT * FROM products  WHERE price BETWEEN 30 AND 100;
SELECT * FROM products  WHERE category IN ('Audio', 'Video');
SELECT * FROM customers WHERE email LIKE '%@example.com';   -- % = any characters
SELECT * FROM orders    WHERE status <> 'cancelled' AND order_date >= '2026-06-01';
SELECT * FROM customers WHERE signed_up IS NOT NULL;        -- use IS NULL / IS NOT NULL, never = NULL
```

## 3. Aggregates and GROUP BY

```sql
SELECT COUNT(*) FROM orders;                                  -- how many orders?
SELECT status, COUNT(*) AS orders FROM orders GROUP BY status;
SELECT category, COUNT(*) AS products, ROUND(AVG(price), 2) AS avg_price
FROM products
GROUP BY category
ORDER BY avg_price DESC;
```
Aggregate functions: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`.

**WHERE vs HAVING:** `WHERE` filters rows *before* grouping; `HAVING` filters groups *after*.
```sql
SELECT customer_id, COUNT(*) AS order_count
FROM orders
WHERE status <> 'cancelled'
GROUP BY customer_id
HAVING COUNT(*) >= 2;
```

## 4. JOINs: combining tables

```sql
-- INNER JOIN: only rows that match in both tables
SELECT o.order_id, c.name, o.order_date, o.status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id;

-- LEFT JOIN: all customers, even those with no orders (their order columns are NULL)
SELECT c.name, o.order_id
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
ORDER BY c.name;

-- Find customers with NO orders
SELECT c.name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- Join four tables: what did each order contain?
SELECT o.order_id, c.name AS customer, p.name AS product, oi.quantity, oi.unit_price
FROM orders o
JOIN customers c    ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p     ON p.product_id = oi.product_id
ORDER BY o.order_id;
```

| Join | Returns |
|---|---|
| `INNER JOIN` | Only matching rows |
| `LEFT JOIN` | All rows from the left table + matches (NULL if none) |
| `RIGHT JOIN` | The mirror image (rarely used; swap the tables and use LEFT) |
| `FULL OUTER JOIN` | All rows from both sides |

## 5. Subqueries and CTEs

```sql
-- Products more expensive than the average
SELECT name, price FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- CTE (WITH): name an intermediate result for readability
WITH order_totals AS (
    SELECT order_id, SUM(quantity * unit_price) AS total
    FROM order_items
    GROUP BY order_id
)
SELECT o.order_id, c.name, ot.total
FROM order_totals ot
JOIN orders o    ON o.order_id = ot.order_id
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY ot.total DESC;
```

## 6. Window functions (powerful, often asked in interviews)

They calculate across related rows **without** collapsing them like GROUP BY does.
```sql
-- Rank products by price within each category
SELECT name, category, price,
       RANK() OVER (PARTITION BY category ORDER BY price DESC) AS rank_in_category
FROM products;

-- Running total of revenue by order date
WITH daily AS (
    SELECT o.order_date, SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY o.order_date
)
SELECT order_date, revenue,
       SUM(revenue) OVER (ORDER BY order_date) AS running_total
FROM daily;
```

## 7. Changing data

```sql
INSERT INTO products (name, category, price) VALUES ('HDMI Cable', 'Accessories', 12.00);
UPDATE products SET price = 79.00 WHERE name = 'Mechanical Keyboard';
DELETE FROM products WHERE name = 'HDMI Cable';
```
⚠️ **An `UPDATE` or `DELETE` without `WHERE` changes every row.** Run the matching `SELECT` first, and use a transaction:
```sql
BEGIN;
DELETE FROM orders WHERE status = 'cancelled';
-- check the result... then:
ROLLBACK;   -- or COMMIT;
```
(This particular delete also removes the order's items, thanks to `ON DELETE CASCADE` in the schema.)

## 8. Indexes and EXPLAIN

```sql
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 1;
CREATE INDEX idx_customers_country ON customers (country);
```
- `Seq Scan` = reads the whole table; fine for tiny tables, slow for big ones
- `Index Scan` = uses an index
- Index columns used in `WHERE`, `JOIN` and `ORDER BY` on large tables. Don't over-index: every index slows writes.

## 9. SQL injection (security!)

❌ Never build queries by pasting user input into strings:
```python
cur.execute(f"SELECT * FROM customers WHERE email = '{email}'")   # email = "' OR '1'='1"  → returns everyone
```
✅ Use **parameterized queries**: the driver sends data separately from the SQL:
```python
cur.execute("SELECT * FROM customers WHERE email = %s", (email,))
```

## 🏋️ Practice
Work through [`exercises.md`](exercises.md). Answers are included, but try first!

More practice online: https://sqlbolt.com/ · https://pgexercises.com/
