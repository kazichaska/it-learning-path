-- Sample data for the practice schema. IDs are generated in insertion order (1, 2, 3, ...).

INSERT INTO customers (name, email, country, signed_up) VALUES
    ('Alice Johnson',  'alice@example.com',  'USA',     '2026-01-15'),  -- 1
    ('Bilal Ahmed',    'bilal@example.com',  'UK',      '2026-02-03'),  -- 2
    ('Chen Wei',       'chen@example.com',   'Canada',  '2026-02-20'),  -- 3
    ('Dana Smith',     'dana@example.com',   'USA',     '2026-03-11'),  -- 4
    ('Elif Kaya',      'elif@example.com',   'Germany', '2026-04-02'),  -- 5
    ('Farhana Rahman', 'farhana@example.com','UK',      '2026-05-19'),  -- 6
    ('Gabriel Silva',  'gabriel@example.com','Brazil',  '2026-06-07'),  -- 7
    ('Hana Sato',      'hana@example.com',   'Japan',   '2026-09-30');  -- 8 (no orders yet)

INSERT INTO products (name, category, price) VALUES
    ('Mechanical Keyboard', 'Accessories', 89.00),   -- 1
    ('Wireless Mouse',      'Accessories', 29.00),   -- 2
    ('27" Monitor',         'Displays',   249.00),   -- 3
    ('USB-C Hub',           'Accessories', 39.00),   -- 4
    ('Laptop Stand',        'Accessories', 45.00),   -- 5
    ('Noise-Cancelling Headphones', 'Audio', 199.00),-- 6
    ('Webcam 1080p',        'Video',       59.00),   -- 7
    ('Portable SSD 1TB',    'Storage',    109.00);   -- 8 (never ordered)

INSERT INTO orders (customer_id, order_date, status) VALUES
    (1, '2026-02-01', 'delivered'),   -- 1
    (1, '2026-05-14', 'delivered'),   -- 2
    (2, '2026-03-09', 'delivered'),   -- 3
    (3, '2026-03-22', 'cancelled'),   -- 4
    (3, '2026-06-30', 'delivered'),   -- 5
    (4, '2026-04-18', 'shipped'),     -- 6
    (5, '2026-07-04', 'delivered'),   -- 7
    (6, '2026-08-12', 'pending'),     -- 8
    (7, '2026-09-01', 'delivered'),   -- 9
    (1, '2026-09-21', 'shipped'),     -- 10
    (2, '2026-10-02', 'pending'),     -- 11
    (5, '2026-10-05', 'shipped');     -- 12

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 89.00),
    (1, 2, 1, 29.00),
    (2, 3, 2, 239.00),   -- bought during a sale
    (3, 6, 1, 199.00),
    (4, 7, 1, 59.00),
    (5, 4, 2, 39.00),
    (5, 5, 1, 45.00),
    (6, 3, 1, 249.00),
    (6, 1, 1, 89.00),
    (7, 2, 3, 29.00),
    (8, 6, 1, 199.00),
    (9, 5, 1, 45.00),
    (9, 4, 1, 39.00),
    (10, 7, 1, 59.00),
    (11, 1, 2, 89.00),
    (12, 6, 1, 189.00);
