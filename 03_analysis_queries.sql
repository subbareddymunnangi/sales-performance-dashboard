USE sales_db;

-- Flat view for Tableau (multi-table JOINs)
CREATE OR REPLACE VIEW vw_sales_dashboard AS
SELECT s.order_id, s.order_date, YEAR(s.order_date) AS order_year, MONTH(s.order_date) AS order_month,
       r.region_name, r.zone, c.customer_id, c.segment, p.product_name, p.category,
       s.ship_mode, s.quantity, s.discount, s.sales_amount, s.profit
FROM sales s
JOIN regions r   ON s.region_id   = r.region_id
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p  ON s.product_id  = p.product_id;

-- 1. Headline KPIs
SELECT COUNT(*) orders, ROUND(SUM(sales_amount)) revenue, ROUND(SUM(profit)) profit,
       ROUND(SUM(profit)/SUM(sales_amount)*100,2) profit_margin_pct, ROUND(AVG(sales_amount),2) avg_order_value
FROM vw_sales_dashboard;

-- 2. Regional performance with revenue rank
SELECT region_name, ROUND(SUM(sales_amount)) revenue, ROUND(SUM(profit)) profit,
       RANK() OVER (ORDER BY SUM(sales_amount) DESC) revenue_rank
FROM vw_sales_dashboard GROUP BY region_name;

-- 3. Monthly sales + YoY growth (MySQL 8+)
WITH monthly AS (
  SELECT order_year yr, order_month mo, SUM(sales_amount) revenue FROM vw_sales_dashboard GROUP BY 1,2)
SELECT yr, mo, ROUND(revenue) revenue,
       ROUND(LAG(revenue,12) OVER (ORDER BY yr,mo)) prev_year_revenue,
       ROUND((revenue/LAG(revenue,12) OVER (ORDER BY yr,mo)-1)*100,2) yoy_growth_pct
FROM monthly ORDER BY yr,mo;

-- 4. 3-month moving average
WITH monthly AS (
  SELECT DATE_FORMAT(order_date,'%Y-%m-01') month_start, SUM(sales_amount) revenue FROM sales GROUP BY 1)
SELECT month_start, ROUND(revenue) revenue,
       ROUND(AVG(revenue) OVER (ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)) moving_avg_3m
FROM monthly ORDER BY month_start;

-- 5. Top 5 products per category
SELECT * FROM (
  SELECT category, product_name, ROUND(SUM(sales_amount)) revenue,
         ROW_NUMBER() OVER (PARTITION BY category ORDER BY SUM(sales_amount) DESC) rn
  FROM vw_sales_dashboard GROUP BY category, product_name) t WHERE rn<=5;

-- 6. Segment x category profit margin
SELECT segment, category, ROUND(SUM(profit)/SUM(sales_amount)*100,2) margin_pct
FROM vw_sales_dashboard GROUP BY segment, category ORDER BY segment, margin_pct DESC;

-- 7. Discount impact on profit
SELECT discount, COUNT(*) orders, ROUND(SUM(profit)/SUM(sales_amount)*100,2) margin_pct
FROM vw_sales_dashboard GROUP BY discount ORDER BY discount;
