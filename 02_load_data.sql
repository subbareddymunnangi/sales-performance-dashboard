-- Edit the path to where you saved the data folder (use forward slashes on Windows)
-- If you get error 3948/2068, run:  SET GLOBAL local_infile = 1;  and connect with local-infile enabled.
USE sales_db;
LOAD DATA LOCAL INFILE 'C:/sales_dashboard/data/regions.csv'   INTO TABLE regions   FIELDS TERMINATED BY ',' IGNORE 1 LINES (region_id,region_name,zone);
LOAD DATA LOCAL INFILE 'C:/sales_dashboard/data/products.csv'  INTO TABLE products  FIELDS TERMINATED BY ',' IGNORE 1 LINES (product_id,product_name,category,unit_price,margin_pct);
LOAD DATA LOCAL INFILE 'C:/sales_dashboard/data/customers.csv' INTO TABLE customers FIELDS TERMINATED BY ',' IGNORE 1 LINES (customer_id,customer_name,segment,region_id);
LOAD DATA LOCAL INFILE 'C:/sales_dashboard/data/sales.csv'     INTO TABLE sales     FIELDS TERMINATED BY ',' IGNORE 1 LINES (order_id,order_date,customer_id,product_id,region_id,quantity,discount,sales_amount,profit,ship_mode);
SELECT 'regions',COUNT(*) FROM regions UNION ALL SELECT 'products',COUNT(*) FROM products
UNION ALL SELECT 'customers',COUNT(*) FROM customers UNION ALL SELECT 'sales',COUNT(*) FROM sales;
