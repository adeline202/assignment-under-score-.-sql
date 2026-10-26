# SQL Assignment III – Inventory Management System

## 1. Project Overview
- **Title:** Inventory Management System
- **Student:** IRADUKUNDA Adeline
 – YOUR_STUDENT_ID: 202512742
- **Business idea:** A small shop that tracks the products it stocks, the category each product belongs to, and the supplier who delivers it.
- **DBMS:** PostgreSQL

## 2. Database and Table Design
**Database:** `yourname_studentid_inventory_system`

| Table | Purpose | Columns |
|---|---|---|
| categories | Groups products | category_id (PK), category_name, description |
| suppliers | Companies that supply products | supplier_id (PK), supplier_name, phone, email, city |
| products | Items in stock | product_id (PK), product_name, category_id (FK), supplier_id (FK), unit_price, quantity_in_stock, reorder_level |

**Keys:** Each primary key is auto-generated and uniquely identifies a row. In `products`, `category_id` points to `categories` and `supplier_id` points to `suppliers`, so a product cannot be saved with a category or supplier that does not exist.

**Relationships:** One category has many products, and one supplier supplies many products (both one-to-many). Keeping categories and suppliers in their own tables avoids repeating the same names and phone numbers in every product row.

**ERD (generated from pgAdmin 4):**

![ERD](erd.png)

## 3. Database and Table Creation
```sql
CREATE DATABASE adeline_202512742_inventory_system;

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
```
Constraints used: PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK and DEFAULT.

## 4. Initial Data Insertion
The full INSERT statements are in `assignment_iii.sql` (parents first, ids never typed by hand).
```sql
SELECT 'categories' AS table_name, COUNT(*) AS total FROM categories
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL SELECT 'products', COUNT(*) FROM products;
```
```
 categories |     5
 suppliers  |     5
 products   |     8
```
Every table has at least 5 rows, ids were generated automatically, and all foreign keys were accepted.

📸 *Screenshot here*

## 5. SQL Practical Tasks

### SELECT
**Q1.1 Basic retrieval** – show name, price and stock of products.
```sql
SELECT product_name, unit_price, quantity_in_stock FROM products;
```
Result: 8 rows (e.g. Wireless Mouse | 12000.00 | 45). It lists the main stock information.

**Q1.2 Conditional** – find products below their reorder level.
```sql
SELECT product_name, quantity_in_stock, reorder_level FROM products WHERE quantity_in_stock < reorder_level;
```
Result: Cooking Oil 3L | 8 | 15. Only one product needs restocking.

**Q1.3 Sorted** – most expensive to cheapest.
```sql
SELECT product_name, unit_price FROM products ORDER BY unit_price DESC;
```
Result: Office Chair (85000.00) comes first, Notebook A5 (1500.00) last.

### JOIN
**Q2.1 INNER JOIN** – products with their category.
```sql
SELECT p.product_name, c.category_name FROM products p
INNER JOIN categories c ON p.category_id = c.category_id;
```
Result: 8 rows. Only products that have a matching category appear.

**Q2.2 LEFT JOIN** – all categories, even without products.
```sql
SELECT c.category_name, p.product_name FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id;
```
Result: 9 rows. Cleaning Supplies shows an empty product because it has none yet, which INNER JOIN would hide.

**Q2.3 Multi-table JOIN** – product, category and supplier together.
```sql
SELECT p.product_name, c.category_name, s.supplier_name, s.city, p.quantity_in_stock
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers s ON p.supplier_id = s.supplier_id;
```
Result: 8 rows, e.g. Office Chair | Furniture | Musanze Furniture | Musanze | 12. It works as a full stock report.

### UPDATE
**Q3.1 Update one record** – new price for the Wireless Mouse.
```sql
UPDATE products SET unit_price = 12500.00 WHERE product_name = 'Wireless Mouse';
```
UPDATE 1. Verified with SELECT: price changed from 12000.00 to 12500.00.

**Q3.2 Update multiple records** – raise reorder level by 5 for Groceries (category 4).
```sql
UPDATE products SET reorder_level = reorder_level + 5 WHERE category_id = 4;
```
UPDATE 2. Rice 20 → 25 and Cooking Oil 15 → 20, confirmed with SELECT.

**Q3.3 Conditional update** – restock +50 for products below reorder level.
```sql
UPDATE products SET quantity_in_stock = quantity_in_stock + 50 WHERE quantity_in_stock < reorder_level;
```
UPDATE 1. Cooking Oil stock went from 8 to 58, confirmed with SELECT.

### ALTER TABLE
**Q4.1 Rename column** – `unit_price` to `price`.
```sql
ALTER TABLE products RENAME COLUMN unit_price TO price;
```
`SELECT product_name, price FROM products;` still returns all 8 rows with their old values.

**Q4.2 Change data type** – `NUMERIC(8,2)` to `NUMERIC(10,2)`.
```sql
ALTER TABLE products ALTER COLUMN price TYPE NUMERIC(10,2);
```
`information_schema` shows precision 10, scale 2. The new type is wider, so no data was lost.

**Q4.3 Add a column** – date the product was last restocked.
```sql
ALTER TABLE products ADD COLUMN last_restocked DATE;
```
The structure now shows `last_restocked | date`. I added it because it is useful for tracking stock.

### INSERT
**Q5.1 Single record**
```sql
INSERT INTO categories (category_name, description) VALUES ('Medical Supplies', 'First aid and basic medical items');
```
INSERT 0 1. The new category got id 6 automatically.

**Q5.2 Multiple records**
```sql
INSERT INTO suppliers (supplier_name, phone, email, city) VALUES
('Nyagatare Dairy Ltd','0788121212','dairy@nyagatare.rw','Nyagatare'),
('Kigali Office Depot','0788343434','sales@kdepot.rw','Kigali'),
('Rwamagana Stationers','0788565656','info@rwastat.rw','Rwamagana');
```
INSERT 0 3. The new suppliers got ids 6, 7 and 8.

**Q5.3 Related record** – product linked to existing category 5 and supplier 5.
```sql
INSERT INTO products (product_name, category_id, supplier_id, price, quantity_in_stock, reorder_level, last_restocked)
VALUES ('Laundry Detergent 1kg', 5, 5, 4500.00, 60, 15, CURRENT_DATE);
```
INSERT 0 1. A JOIN shows it linked to Cleaning Supplies and Rubavu Trading Co., so the foreign keys work.

📸 *Add a screenshot of each result from pgAdmin under each task.*

## 6. Conclusion
In this assignment I learned how to create a database and related tables, and how primary keys and foreign keys keep the data consistent. I practiced inserting and selecting data, combining tables with INNER and LEFT JOINs, and updating records safely by always using a WHERE condition and checking before and after. I also saw that ALTER TABLE changes the structure of a table, while UPDATE only changes the data.
