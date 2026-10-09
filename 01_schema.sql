CREATE DATABASE IF NOT EXISTS sales_db;
USE sales_db;
DROP TABLE IF EXISTS sales; DROP TABLE IF EXISTS customers; DROP TABLE IF EXISTS products; DROP TABLE IF EXISTS regions;

CREATE TABLE regions (region_id INT PRIMARY KEY, region_name VARCHAR(50), zone VARCHAR(20));
CREATE TABLE products (product_id INT PRIMARY KEY, product_name VARCHAR(100), category VARCHAR(50),
                       unit_price DECIMAL(10,2), margin_pct DECIMAL(5,2));
CREATE TABLE customers (customer_id INT PRIMARY KEY, customer_name VARCHAR(100), segment VARCHAR(30),
                        region_id INT, FOREIGN KEY (region_id) REFERENCES regions(region_id));
CREATE TABLE sales (order_id VARCHAR(20) PRIMARY KEY, order_date DATE, customer_id INT, product_id INT, region_id INT,
                    quantity INT, discount DECIMAL(4,2), sales_amount DECIMAL(12,2), profit DECIMAL(12,2), ship_mode VARCHAR(20),
                    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
                    FOREIGN KEY (product_id) REFERENCES products(product_id),
                    FOREIGN KEY (region_id) REFERENCES regions(region_id),
                    INDEX idx_date (order_date), INDEX idx_region (region_id), INDEX idx_product (product_id));
