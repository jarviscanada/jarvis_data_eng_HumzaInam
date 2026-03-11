-- Author: Humza Inam

-- Q1: Show first 10 rows of the retail table
-- Returns a sample of the data to understand the table structure and content
SELECT * FROM retail LIMIT 10;

-- Q2: Check total number of records in the retail table
-- Returns: 1,067,371 rows
SELECT COUNT(*) FROM retail;

-- Q3: Count number of unique clients
-- Returns: 5,942 distinct customers
SELECT COUNT(DISTINCT customer_id) FROM retail;

-- Q4: Get the date range of invoices (earliest and latest invoice dates)
-- Returns: Min = 2009-12-01 07:45:00, Max = 2011-12-09 12:50:00
SELECT MAX(invoice_date), MIN(invoice_date) FROM retail;

-- Q5: Count number of unique SKUs/products (distinct stock codes)
-- Returns: 5,305 distinct products
SELECT COUNT(DISTINCT stock_code) FROM retail;

-- Q6: Calculate average invoice amount, excluding canceled orders (negative amounts)
-- Approach: 
--   1. Calculate total revenue per invoice (invoice_no grouped)
--   2. Filter out invoices with negative total (HAVING clause)
--   3. Calculate average across positive invoices
-- Returns: $523.30 average invoice amount
SELECT AVG(revenue) AS avg_invoice_amount
FROM (
    SELECT
        invoice_no,
        SUM(quantity * unit_price) AS revenue
    FROM retail
    GROUP BY invoice_no
    HAVING SUM(quantity * unit_price) > 0
);

-- Q7: Calculate total revenue across all transactions
-- Multiplies unit_price by quantity for each line item and sums them all
-- Returns: $19,287,250.48 total revenue
SELECT SUM(unit_price * quantity) AS total_revenue
FROM retail;

-- Q8 Calculate total revenue by year-month using TO_CHAR
-- Converts invoice_date to YYYYMM format (e.g., '201012')
-- Groups and sums revenue by month
SELECT 
    TO_CHAR(invoice_date, 'YYYYMM') AS yyyymm,
    SUM(unit_price * quantity) AS total_revenue
FROM retail
GROUP BY TO_CHAR(invoice_date, 'YYYYMM')
ORDER BY yyyymm;
