-- =============================================================================
-- Apple iTunes Music Store Analysis - Required Queries (Q1-Q15)
-- Run against itunes.db (SQLite) after running scripts/import_data.py
-- Usage from project root: sqlite3 itunes.db < sql/itunes_analysis_queries.sql
-- =============================================================================

-- Q1. Who is the senior most employee based on job title?
-- Interpreted as highest hierarchy level (levels column: L7 = most senior).
SELECT employee_id, first_name, last_name, title, levels
FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Q2. Which countries have the most Invoices?
SELECT billing_country AS country, COUNT(*) AS invoice_count
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC;

-- Q3. What are top 3 values of total invoice?
SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Q4. Which city has the best customers? (Highest sum of invoice totals - for Music Festival)
SELECT billing_city AS city, SUM(total) AS total_sales
FROM invoice
GROUP BY billing_city
ORDER BY total_sales DESC
LIMIT 1;

-- Q5. Who is the best customer? (The customer who has spent the most money)
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON i.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 1;

-- Q6. Rock Music listeners: email, first name, last name, Genre; ordered alphabetically by email
SELECT DISTINCT c.email, c.first_name, c.last_name, g.name AS genre
FROM customer c
JOIN invoice i ON i.customer_id = c.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email;

-- Q7. Top 10 rock bands (artists with most Rock tracks in dataset)
SELECT ar.name AS artist_name, COUNT(t.track_id) AS total_track_count
FROM artist ar
JOIN album al ON al.artist_id = ar.artist_id
JOIN track t ON t.album_id = al.album_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
GROUP BY ar.artist_id, ar.name
ORDER BY total_track_count DESC
LIMIT 10;

-- Q8. Tracks longer than average song length: Name and Milliseconds, longest first
SELECT t.name, t.milliseconds
FROM track t
WHERE t.milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY t.milliseconds DESC;

-- Q9. Amount spent by each customer on each artist: customer name, artist name, total spent
SELECT c.first_name || ' ' || c.last_name AS customer_name, ar.name AS artist_name, SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
JOIN invoice i ON i.customer_id = c.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN artist ar ON ar.artist_id = al.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, ar.artist_id, ar.name
ORDER BY total_spent DESC;

-- Q10. Most popular music Genre for each country (highest number of purchases).
-- For ties, return all genres that achieved the maximum.
WITH genre_purchases AS (
    SELECT i.billing_country AS country, g.name AS genre_name, COUNT(il.invoice_line_id) AS purchase_count
    FROM invoice i
    JOIN invoice_line il ON il.invoice_id = i.invoice_id
    JOIN track t ON t.track_id = il.track_id
    JOIN genre g ON g.genre_id = t.genre_id
    GROUP BY i.billing_country, g.genre_id, g.name
),
max_per_country AS (
    SELECT country, MAX(purchase_count) AS max_count FROM genre_purchases GROUP BY country
)
SELECT gp.country, gp.genre_name, gp.purchase_count
FROM genre_purchases gp
JOIN max_per_country m ON m.country = gp.country AND m.max_count = gp.purchase_count
ORDER BY gp.country, gp.purchase_count DESC;

-- Q11. Top customer per country (most spent). For ties, return all customers who spent that amount.
WITH customer_spend_by_country AS (
    SELECT c.customer_id, c.first_name, c.last_name, i.billing_country AS country, SUM(i.total) AS total_spent
    FROM customer c
    JOIN invoice i ON i.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
),
max_spend_per_country AS (
    SELECT country, MAX(total_spent) AS max_spent FROM customer_spend_by_country GROUP BY country
)
SELECT cs.country, cs.first_name || ' ' || cs.last_name AS top_customer, cs.total_spent AS amount_spent
FROM customer_spend_by_country cs
JOIN max_spend_per_country m ON m.country = cs.country AND m.max_spent = cs.total_spent
ORDER BY cs.country;

-- Q12. Most popular artists (by total quantity of tracks purchased)
SELECT ar.name AS artist_name, SUM(il.quantity) AS total_purchases
FROM artist ar
JOIN album al ON al.artist_id = ar.artist_id
JOIN track t ON t.album_id = al.album_id
JOIN invoice_line il ON il.track_id = t.track_id
GROUP BY ar.artist_id, ar.name
ORDER BY total_purchases DESC
LIMIT 10;

-- Q13. Most popular song (by total quantity purchased)
SELECT t.name AS track_name, ar.name AS artist_name, SUM(il.quantity) AS total_purchases
FROM track t
JOIN album al ON al.album_id = t.album_id
JOIN artist ar ON ar.artist_id = al.artist_id
JOIN invoice_line il ON il.track_id = t.track_id
GROUP BY t.track_id, t.name, ar.name
ORDER BY total_purchases DESC
LIMIT 1;

-- Q14. Average prices of different types of music (by media type)
SELECT mt.name AS media_type, ROUND(AVG(t.unit_price), 2) AS avg_price
FROM track t
JOIN media_type mt ON mt.media_type_id = t.media_type_id
GROUP BY mt.media_type_id, mt.name
ORDER BY avg_price DESC;

-- Q15. Most popular countries for music purchases (by total revenue)
SELECT billing_country AS country, ROUND(SUM(total), 2) AS total_revenue, COUNT(*) AS invoice_count
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue DESC;
