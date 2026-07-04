-- NAME-SATYA SWARUP
-- ======================================
-- Step 1: Create Database
CREATE DATABASE superstore_db;
USE superstore_db;
-- ======================================
-- Step 2: Import CSV
-- ======================================
-- Select Table Data Import Wizard
-- Select the CSV file
-- Named as superstore_raw
-- Finish the import
-- ======================================
-- Step 3: Create Customers Table and Insert Data into Customers
-- ======================================
-- CREATE TABLE customers,orders,products 
-- insert data into the table by using SELECT DISTINCT
-- example-INSERT INTO customers
SELECT DISTINCT
    `Customer ID`,
    `Customer Name`,
    `Segment`,
    `Country`,
    `City`,
    `State`,
    `Postal Code`,
    `Region`
FROM superstore_raw;
-- ======================================
-- QUESTION 1-Find all orders where sales are greater than the average sales. (Subquery)  
-- ======================================
SELECT *
FROM orders
WHERE sales >
(
    SELECT AVG(sales)
    FROM orders
);
-- ======================================
-- QUESTION 2-Find the highest sales order for each customer. (Subquery)  
-- ======================================
SELECT *
FROM orders o
WHERE sales =
(
    SELECT MAX(sales)
    FROM orders
    WHERE customer_id = o.customer_id
);
-- ======================================
-- QUESTION 3-Calculate total sales for each customer. (CTE)  
-- ======================================
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)

SELECT *
FROM customer_sales;
-- ======================================
-- QUESTION 4- Find customers whose total sales are above average. (CTE + Subquery)  
-- ======================================
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)

SELECT *
FROM customer_sales
WHERE total_sales >
(
    SELECT AVG(total_sales)
    FROM customer_sales
);
-- ======================================
-- QUESTION 5-Rank all customers based on total sales. (Window Function)  
-- ======================================
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)

SELECT
    customer_id,
    total_sales,
    RANK() OVER (ORDER BY total_sales DESC) AS customer_rank
FROM customer_sales;
-- ======================================
-- QUESTION 6- Assign row numbers to each order within a customer. (Window Function + PARTITION BY)  
-- ======================================
SELECT
    customer_id,
    order_id,
    sales,
    ROW_NUMBER() OVER
    (
        PARTITION BY customer_id
        ORDER BY sales DESC
    ) AS row_num
FROM orders;
-- ======================================
-- QUESTION 7-Display top 3 customers based on total sales. (Window Function)  
-- ======================================
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)

SELECT *
FROM
(
    SELECT
        customer_id,
        total_sales,
        RANK() OVER (ORDER BY total_sales DESC) AS customer_rank
    FROM customer_sales
) ranked_customers
WHERE customer_rank <= 3;
-- ======================================
-- QUESTION- Final Combined Query 
-- ======================================
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
),
customer_details AS
(
    SELECT
        customer_id,
        MAX(customer_name) AS customer_name
    FROM customers
    GROUP BY customer_id
)

SELECT
    cd.customer_name,
    ROUND(cs.total_sales, 2) AS total_sales,
    RANK() OVER (ORDER BY cs.total_sales DESC) AS customer_rank
FROM customer_sales cs
JOIN customer_details cd
ON cs.customer_id = cd.customer_id
ORDER BY customer_rank;
-- ======================================
-- Mini Project:
-- QUESTION 1-Who are the top 5 customers?  
-- ======================================
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
),
customer_details AS
(
    SELECT
        customer_id,
        MAX(customer_name) AS customer_name
    FROM customers
    GROUP BY customer_id
)

SELECT
    cd.customer_name,
    ROUND(cs.total_sales,2) AS total_sales
FROM customer_sales cs
JOIN customer_details cd
ON cs.customer_id = cd.customer_id
ORDER BY total_sales DESC
LIMIT 5;
-- ======================================
-- QUESTION 2- Who are the bottom 5 customers?  
-- ======================================
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
),
customer_details AS
(
    SELECT
        customer_id,
        MAX(customer_name) AS customer_name
    FROM customers
    GROUP BY customer_id
)

SELECT
    cd.customer_name,
    ROUND(cs.total_sales,2) AS total_sales
FROM customer_sales cs
JOIN customer_details cd
ON cs.customer_id = cd.customer_id
ORDER BY total_sales ASC
LIMIT 5;
-- ======================================
-- QUESTION 3- Which customers made only one order?  
-- ======================================
WITH customer_details AS
(
    SELECT
        customer_id,
        MAX(customer_name) AS customer_name
    FROM customers
    GROUP BY customer_id
)

SELECT
    cd.customer_name,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customer_details cd
ON o.customer_id = cd.customer_id
GROUP BY cd.customer_name
HAVING COUNT(o.order_id) = 1;
-- ======================================
-- QUESTION 4- Which customers have above-average sales?  
-- ======================================
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
),
customer_details AS
(
    SELECT
        customer_id,
        MAX(customer_name) AS customer_name
    FROM customers
    GROUP BY customer_id
)

SELECT
    cd.customer_name,
    ROUND(cs.total_sales,2) AS total_sales
FROM customer_sales cs
JOIN customer_details cd
ON cs.customer_id = cd.customer_id
WHERE cs.total_sales >
(
    SELECT AVG(total_sales)
    FROM customer_sales
)
ORDER BY total_sales DESC;
-- ======================================
-- QUESTION 5- What is the highest order value per customer? 
-- ======================================
WITH customer_details AS
(
    SELECT
        customer_id,
        MAX(customer_name) AS customer_name
    FROM customers
    GROUP BY customer_id
)

SELECT
    cd.customer_name,
    MAX(o.sales) AS highest_order_value
FROM orders o
JOIN customer_details cd
ON o.customer_id = cd.customer_id
GROUP BY cd.customer_name
ORDER BY highest_order_value DESC;