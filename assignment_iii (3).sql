-- =====================================================
-- ASSIGNMENT III: SQL TABLE MANIPULATION
-- Project: Inventory Management System (PostgreSQL)
-- Student: YOUR NAME | ID: YOUR_STUDENT_ID
-- =====================================================

-- =====================================================
-- 1. DATABASE CREATION
-- (replace yourname_studentid with your real name and ID)
-- =====================================================
CREATE DATABASE adeline_202512742_inventory_system;
-- connect to it (in psql). In pgAdmin just open a Query Tool on the new database.
\c yourname_studentid_inventory_system

-- =====================================================
-- 2. TABLE CREATION AND CONSTRAINTS
-- Parent tables first: categories, suppliers. Child table: products
-- =====================================================
CREATE TABLE categories (
    category_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description   VARCHAR(150)
);

CREATE TABLE suppliers (
    supplier_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_name VARCHAR(80) NOT NULL,
    phone         VARCHAR(15) NOT NULL UNIQUE,
    email         VARCHAR(80),
    city          VARCHAR(40) NOT NULL
);

CREATE TABLE products (
    product_id        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name      VARCHAR(80) NOT NULL,
    category_id       INT NOT NULL,
    supplier_id       INT NOT NULL,
    unit_price        NUMERIC(8,2) NOT NULL CHECK (unit_price >= 0),
    quantity_in_stock INT NOT NULL DEFAULT 0 CHECK (quantity_in_stock >= 0),
    reorder_level     SMALLINT NOT NULL DEFAULT 10,
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(category_id),
    CONSTRAINT fk_products_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- =====================================================
-- ERD: generate now in pgAdmin 4
-- (right-click database -> ERD For Database -> Download image) and save as erd.png
-- =====================================================

-- =====================================================
-- 3. INITIAL DATA INSERTION (parents first, ids are automatic)
-- =====================================================
INSERT INTO categories (category_name, description) VALUES
('Electronics',       'Computer accessories and gadgets'),
('Stationery',        'Paper, pens and office writing items'),
('Furniture',         'Office and home furniture'),
('Groceries',         'Food and household staples'),
('Cleaning Supplies', 'Soap, detergents and cleaning tools');

INSERT INTO suppliers (supplier_name, phone, email, city) VALUES
('TechSource Rwanda',    '0788111222', 'info@techsource.rw',  'Kigali'),
('Kigali Paper House',   '0788333444', 'sales@kpaper.rw',     'Kigali'),
('Musanze Furniture',    '0788555666', 'order@musanzef.rw',   'Musanze'),
('Huye Fresh Foods',     '0788777888', 'hello@huyefresh.rw',  'Huye'),
('Rubavu Trading Co.',   '0788999000', 'rubavu@trading.rw',   'Rubavu');

INSERT INTO products (product_name, category_id, supplier_id, unit_price, quantity_in_stock, reorder_level) VALUES
('Wireless Mouse',      1, 1, 12000.00,  45, 10),
('USB Flash Drive 32GB',1, 1,  8000.00, 120, 20),
('A4 Printing Paper',   2, 2,  6500.00, 300, 50),
('Ballpoint Pens Box',  2, 2,  2500.00, 150, 30),
('Office Chair',        3, 3, 85000.00,  12,  5),
('Rice 5kg Bag',        4, 4,  9000.00,  80, 20),
('Cooking Oil 3L',      4, 4, 11000.00,   8, 15),
('Notebook A5',         2, 2,  1500.00, 200, 40);

-- verify at least 5 rows per table
SELECT 'categories' AS table_name, COUNT(*) AS total FROM categories
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL SELECT 'products',  COUNT(*) FROM products;

-- =====================================================
-- 4. SELECT TASKS
-- =====================================================
-- Q1.1 Basic retrieval: show product names, prices and stock
SELECT product_name, unit_price, quantity_in_stock FROM products;

-- Q1.2 Conditional: products whose stock is below their reorder level
SELECT product_name, quantity_in_stock, reorder_level
FROM products
WHERE quantity_in_stock < reorder_level;

-- Q1.3 Sorted: products from most expensive to cheapest
SELECT product_name, unit_price FROM products ORDER BY unit_price DESC;

-- =====================================================
-- 5. JOIN TASKS
-- =====================================================
-- Q2.1 INNER JOIN: products with their category (only matching rows)
SELECT p.product_name, c.category_name
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id;

-- Q2.2 LEFT JOIN: all categories, even those with no products
SELECT c.category_name, p.product_name
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id;

-- Q2.3 Multi-table JOIN: product, category and supplier report
SELECT p.product_name, c.category_name, s.supplier_name, s.city, p.quantity_in_stock
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers  s ON p.supplier_id = s.supplier_id;

-- =====================================================
-- 6. UPDATE TASKS AND VERIFICATION
-- =====================================================
-- Q3.1 Update one record: change the price of the Wireless Mouse
SELECT product_name, unit_price FROM products WHERE product_name = 'Wireless Mouse';  -- before
UPDATE products SET unit_price = 12500.00 WHERE product_name = 'Wireless Mouse';
SELECT product_name, unit_price FROM products WHERE product_name = 'Wireless Mouse';  -- after

-- Q3.2 Update multiple records: raise reorder level by 5 for all Groceries
SELECT product_name, reorder_level FROM products WHERE category_id = 4;               -- before
UPDATE products SET reorder_level = reorder_level + 5 WHERE category_id = 4;
SELECT product_name, reorder_level FROM products WHERE category_id = 4;               -- after

-- Q3.3 Conditional update: restock (+50) every product below its reorder level
SELECT product_name, quantity_in_stock, reorder_level FROM products
WHERE quantity_in_stock < reorder_level;                                              -- before
UPDATE products SET quantity_in_stock = quantity_in_stock + 50
WHERE quantity_in_stock < reorder_level;
SELECT product_name, quantity_in_stock, reorder_level FROM products
WHERE product_name IN ('Cooking Oil 3L');                                             -- after

-- =====================================================
-- 7. ALTER TABLE TASKS AND VERIFICATION
-- =====================================================
-- Q4.1 Rename column unit_price -> price
ALTER TABLE products RENAME COLUMN unit_price TO price;
SELECT product_name, price FROM products;

-- Q4.2 Change data type of price: NUMERIC(8,2) -> NUMERIC(10,2) (safe, bigger range)
ALTER TABLE products ALTER COLUMN price TYPE NUMERIC(10,2);
SELECT column_name, data_type, numeric_precision, numeric_scale
FROM information_schema.columns
WHERE table_name = 'products' AND column_name = 'price';
SELECT product_name, price FROM products;

-- Q4.3 Add a column: date the product was last restocked
ALTER TABLE products ADD COLUMN last_restocked DATE;
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'products' ORDER BY ordinal_position;

-- =====================================================
-- 8. ADDITIONAL INSERT TASKS AND VERIFICATION
-- =====================================================
-- Q5.1 Insert a single record (new category)
INSERT INTO categories (category_name, description)
VALUES ('Medical Supplies', 'First aid and basic medical items');
SELECT * FROM categories WHERE category_name = 'Medical Supplies';

-- Q5.2 Insert multiple records (new suppliers)
INSERT INTO suppliers (supplier_name, phone, email, city) VALUES
('Nyagatare Dairy Ltd',  '0788121212', 'dairy@nyagatare.rw', 'Nyagatare'),
('Kigali Office Depot',  '0788343434', 'sales@kdepot.rw',    'Kigali'),
('Rwamagana Stationers', '0788565656', 'info@rwastat.rw',    'Rwamagana');
SELECT * FROM suppliers ORDER BY supplier_id DESC LIMIT 3;

-- Q5.3 Insert a related record: new product using existing category and supplier ids
INSERT INTO products (product_name, category_id, supplier_id, price, quantity_in_stock, reorder_level, last_restocked)
VALUES ('Laundry Detergent 1kg', 5, 5, 4500.00, 60, 15, CURRENT_DATE);
SELECT p.product_name, c.category_name, s.supplier_name, p.price
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers  s ON p.supplier_id = s.supplier_id
WHERE p.product_name = 'Laundry Detergent 1kg';
