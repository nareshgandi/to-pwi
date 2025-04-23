create user retailuser with password 'postgres';
create user retailread with password 'retailread';
create extension pg_buffercache;

create database restoreretail with owner retailuser;;
create database retaildb with owner retailuser;

\c retaildb retailuser;

create schema retail;


CREATE TABLE retail.stores (
    store_id SERIAL PRIMARY KEY,
    store_name TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    opened_on DATE
);

CREATE TABLE retail.categories (
    category_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE retail.products (
    product_id SERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price > 0),
	category_id INT
);

ALTER TABLE retail.products
ADD CONSTRAINT fk_product_category
FOREIGN KEY (category_id) REFERENCES retail.categories(category_id);

ALTER TABLE retail.products
ADD CONSTRAINT chk_price_positive CHECK (price > 0);

CREATE TABLE retail.customers (
    customer_id SERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    created_on TIMESTAMP DEFAULT NOW()
);

CREATE TABLE retail.inventory (
    store_id INT REFERENCES retail.stores,
    product_id INT REFERENCES retail.products,
    stock INT NOT NULL CHECK (stock >= 0),
    last_updated TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (store_id, product_id)
);

CREATE TABLE retail.sales (
    sale_id SERIAL,
    store_id INT REFERENCES retail.stores,
    product_id INT REFERENCES retail.products,
    customer_id INT REFERENCES retail.customers,
    quantity INT NOT NULL CHECK (quantity > 0),
    total_amount NUMERIC(10,2),
    sale_date DATE NOT NULL,
    PRIMARY KEY (sale_id, sale_date)
) PARTITION BY RANGE (sale_date);

-- Example partitions (create more as needed)
CREATE TABLE retail.sales_2025_01 PARTITION OF retail.sales
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE retail.sales_2025_02 PARTITION OF retail.sales
FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE INDEX idx_sales_customer ON retail.sales(customer_id);
CREATE INDEX idx_inventory_last_updated ON retail.inventory(last_updated);
CREATE INDEX idx_products_category ON retail.products(category);

CREATE VIEW retail.v_customer_purchases AS
SELECT 
    c.customer_id, c.full_name,
    COUNT(s.sale_id) AS total_orders,
    SUM(s.total_amount) AS total_spent
FROM retail.customers c
JOIN retail.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.full_name;

CREATE VIEW retail.v_low_stock AS
SELECT 
    i.store_id, s.store_name, i.product_id, p.product_name, i.stock
FROM retail.inventory i
JOIN retail.products p ON i.product_id = p.product_id
JOIN retail.stores s ON i.store_id = s.store_id
WHERE i.stock < 10;

CREATE MATERIALIZED VIEW retail.mv_monthly_sales_summary AS
SELECT 
    DATE_TRUNC('month', sale_date) AS month,
    store_id,
    SUM(total_amount) AS monthly_revenue
FROM retail.sales
GROUP BY month, store_id;

CREATE OR REPLACE PROCEDURE retail.restock_product(p_store_id INT, p_product_id INT, p_qty INT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE retail.inventory
    SET stock = stock + p_qty,
        last_updated = NOW()
    WHERE store_id = p_store_id AND product_id = p_product_id;
    
    IF NOT FOUND THEN
        INSERT INTO retail.inventory(store_id, product_id, stock)
        VALUES (p_store_id, p_product_id, p_qty);
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE retail.record_sale(
    p_store_id INT, p_product_id INT, p_customer_id INT, p_quantity INT, p_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    unit_price NUMERIC(10,2);
BEGIN
    SELECT price INTO unit_price FROM retail.products WHERE product_id = p_product_id;

    INSERT INTO retail.sales(store_id, product_id, customer_id, quantity, total_amount, sale_date)
    VALUES (p_store_id, p_product_id, p_customer_id, p_quantity, unit_price * p_quantity, p_date);

    UPDATE retail.inventory
    SET stock = stock - p_quantity, last_updated = NOW()
    WHERE store_id = p_store_id AND product_id = p_product_id;
END;
$$;


-- Categories
INSERT INTO retail.categories (name, description) VALUES
('Personal Care', 'Shampoos, soaps, hygiene products'),
('Groceries', 'Food items and essentials'),
('Electronics', 'Mobile phones, gadgets, accessories'),
('Beverages', 'Soft drinks, juices, and bottled water');

-- Stores
INSERT INTO retail.stores(store_name, city, state, opened_on)
VALUES ('Central Mart', 'Hyderabad', 'TS', '2020-01-15'),
       ('North Hub', 'Delhi', 'DL', '2021-06-01');

-- Products
INSERT INTO retail.products(product_name, category, price)
VALUES ('Shampoo', 'Personal Care', 120.00),
       ('Notebook', 'Stationery', 40.00),
       ('Biscuits', 'Food', 25.00);

-- Customers
INSERT INTO retail.customers(full_name, email)
VALUES ('Alice Kumar', 'alice@example.com'),
       ('Rahul Singh', 'rahul@example.com');

-- Inventory
INSERT INTO retail.inventory(store_id, product_id, stock)
VALUES (1, 1, 50), (1, 2, 20), (2, 1, 30), (2, 3, 100);

-- Sales
CALL retail.record_sale(1, 1, 1, 2, '2025-01-10');
CALL retail.record_sale(2, 3, 2, 5, '2025-02-05');
CALL retail.restock_product(1, 1, 10);

REFRESH MATERIALIZED VIEW retail.mv_monthly_sales_summary;

grant connect on database retaildb to retailread;
grant usage on schema retail to  retailread;
grant select on all tables in schema retail to retailread;








