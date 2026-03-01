-- =============================================================================
-- Apple iTunes Music Store - Exploratory & Advanced Analytics
-- Uses CTEs, window functions, subqueries for business insights
-- Usage from project root: sqlite3 itunes.db < sql/exploratory_and_advanced_analytics.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- EXPLORATORY: Revenue and sales summaries
-- -----------------------------------------------------------------------------

-- Monthly revenue trend (last 24 months from latest invoice)
SELECT strftime('%Y-%m', invoice_date) AS month, ROUND(SUM(total), 2) AS revenue, COUNT(*) AS invoices
FROM invoice
WHERE invoice_date >= (SELECT date(MAX(invoice_date), '-24 months') FROM invoice)
GROUP BY strftime('%Y-%m', invoice_date)
ORDER BY month;

-- Revenue by genre (total and share)
SELECT g.name AS genre, ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue, COUNT(il.invoice_line_id) AS units_sold
FROM genre g
JOIN track t ON t.genre_id = g.genre_id
JOIN invoice_line il ON il.track_id = t.track_id
GROUP BY g.genre_id, g.name
ORDER BY revenue DESC;

-- Customer count and revenue by country
SELECT billing_country AS country, COUNT(DISTINCT customer_id) AS customers, ROUND(SUM(total), 2) AS revenue
FROM invoice
GROUP BY billing_country
ORDER BY revenue DESC;

-- Average invoice value and payment concentration
SELECT ROUND(AVG(total), 2) AS avg_invoice_value, ROUND(MIN(total), 2) AS min_total, ROUND(MAX(total), 2) AS max_total
FROM invoice;

-- -----------------------------------------------------------------------------
-- ADVANCED: Window functions and CTEs
-- -----------------------------------------------------------------------------

-- Customer lifetime value with rank (window function)
WITH customer_totals AS (
    SELECT c.customer_id, c.first_name || ' ' || c.last_name AS customer_name, SUM(i.total) AS total_spent
    FROM customer c
    JOIN invoice i ON i.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT customer_id, customer_name, total_spent,
       RANK() OVER (ORDER BY total_spent DESC) AS spend_rank,
       ROUND(100.0 * total_spent / SUM(total_spent) OVER (), 2) AS pct_of_total_revenue
FROM customer_totals
ORDER BY spend_rank
LIMIT 15;

-- Repeat vs one-time purchasers (CTE + aggregation)
WITH purchase_counts AS (
    SELECT customer_id, COUNT(DISTINCT invoice_id) AS num_invoices
    FROM invoice
    GROUP BY customer_id
)
SELECT
    CASE WHEN num_invoices = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
    COUNT(*) AS customer_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM purchase_counts), 1) AS pct
FROM purchase_counts
GROUP BY CASE WHEN num_invoices = 1 THEN 'One-time' ELSE 'Repeat' END;

-- Revenue per employee (sales support) with running total (window)
WITH emp_revenue AS (
    SELECT e.employee_id, e.first_name || ' ' || e.last_name AS emp_name, SUM(i.total) AS total_revenue
    FROM employee e
    JOIN customer c ON c.support_rep_id = e.employee_id
    JOIN invoice i ON i.customer_id = c.customer_id
    GROUP BY e.employee_id, e.first_name, e.last_name
)
SELECT emp_name, total_revenue,
       ROUND(SUM(total_revenue) OVER (ORDER BY total_revenue DESC), 2) AS running_total,
       ROUND(100.0 * total_revenue / SUM(total_revenue) OVER (), 1) AS pct_contribution
FROM emp_revenue;

-- Top 5 tracks by revenue (subquery for rank)
SELECT track_name, artist_name, revenue, revenue_rank
FROM (
    SELECT t.name AS track_name, ar.name AS artist_name,
           ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue,
           RANK() OVER (ORDER BY SUM(il.unit_price * il.quantity) DESC) AS revenue_rank
    FROM track t
    JOIN album al ON al.album_id = t.album_id
    JOIN artist ar ON ar.artist_id = al.artist_id
    JOIN invoice_line il ON il.track_id = t.track_id
    GROUP BY t.track_id, t.name, ar.name
) sub
WHERE revenue_rank <= 5;

-- Genre popularity by country (CTE: count purchases per country per genre, then rank)
WITH country_genre_purchases AS (
    SELECT i.billing_country AS country, g.name AS genre_name, COUNT(il.invoice_line_id) AS purchases
    FROM invoice i
    JOIN invoice_line il ON il.invoice_id = i.invoice_id
    JOIN track t ON t.track_id = il.track_id
    JOIN genre g ON g.genre_id = t.genre_id
    GROUP BY i.billing_country, g.genre_id, g.name
),
ranked AS (
    SELECT country, genre_name, purchases, RANK() OVER (PARTITION BY country ORDER BY purchases DESC) AS rk
    FROM country_genre_purchases
)
SELECT country, genre_name, purchases, rk
FROM ranked
WHERE rk = 1
ORDER BY purchases DESC;

-- Tracks/albums never purchased (subquery: anti-join)
SELECT t.track_id, t.name AS track_name, al.title AS album_title, ar.name AS artist_name
FROM track t
JOIN album al ON al.album_id = t.album_id
JOIN artist ar ON ar.artist_id = al.artist_id
WHERE t.track_id NOT IN (SELECT track_id FROM invoice_line)
LIMIT 20;

-- Average time between purchases per customer (date difference)
WITH customer_invoices AS (
    SELECT customer_id, invoice_date, LAG(invoice_date) OVER (PARTITION BY customer_id ORDER BY invoice_date) AS prev_date
    FROM invoice
),
gaps AS (
    SELECT customer_id, julianday(invoice_date) - julianday(prev_date) AS days_between
    FROM customer_invoices
    WHERE prev_date IS NOT NULL
)
SELECT ROUND(AVG(days_between), 1) AS avg_days_between_purchases
FROM gaps;

-- Revenue by media type (exploratory)
SELECT mt.name AS media_type, ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue, SUM(il.quantity) AS units_sold
FROM media_type mt
JOIN track t ON t.media_type_id = mt.media_type_id
JOIN invoice_line il ON il.track_id = t.track_id
GROUP BY mt.media_type_id, mt.name
ORDER BY revenue DESC;
