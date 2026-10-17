-- Practice schema: a small online shop (PostgreSQL).
-- Load it with the instructions in ../postgresql/README.md

CREATE TABLE customers (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        TEXT NOT NULL,
    email       TEXT NOT NULL UNIQUE,
    country     TEXT NOT NULL,
    signed_up   DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE products (
    product_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name       TEXT NOT NULL,
    category   TEXT NOT NULL,
    price      NUMERIC(10, 2) NOT NULL CHECK (price >= 0)
);

CREATE TABLE orders (
    order_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers (customer_id),
    order_date  DATE NOT NULL,
    status      TEXT NOT NULL CHECK (status IN ('pending', 'shipped', 'delivered', 'cancelled'))
);

-- One row per product in an order. unit_price is copied at purchase time,
-- because the product's price may change later.
CREATE TABLE order_items (
    order_id   INT NOT NULL REFERENCES orders (order_id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products (product_id),
    quantity   INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

-- Foreign key columns are not indexed automatically in PostgreSQL.
CREATE INDEX idx_orders_customer_id ON orders (customer_id);
CREATE INDEX idx_order_items_product_id ON order_items (product_id);
