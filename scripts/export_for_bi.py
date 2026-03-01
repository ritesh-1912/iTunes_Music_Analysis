#!/usr/bin/env python3
"""Export key views to CSV for Power BI / Tableau. Run from project root after import_data.py."""
import csv
import os
import sqlite3

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB = os.path.join(ROOT, "itunes.db")
OUT_DIR = os.path.join(ROOT, "exports")

def run(conn, sql, path):
    cur = conn.execute(sql)
    cols = [d[0] for d in cur.description]
    rows = cur.fetchall()
    os.makedirs(OUT_DIR, exist_ok=True)
    with open(os.path.join(OUT_DIR, path), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(cols)
        w.writerows(rows)
    print(f"  {path}: {len(rows)} rows")

def main():
    os.chdir(ROOT)
    conn = sqlite3.connect(DB)
    print("Exporting for Power BI / Tableau...")
    run(conn, """
        SELECT strftime('%Y-%m', invoice_date) AS month, ROUND(SUM(total), 2) AS revenue, COUNT(*) AS invoices
        FROM invoice GROUP BY strftime('%Y-%m', invoice_date) ORDER BY month
    """, "monthly_revenue.csv")
    run(conn, """
        SELECT g.name AS genre, ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue, SUM(il.quantity) AS units_sold
        FROM genre g JOIN track t ON t.genre_id = g.genre_id JOIN invoice_line il ON il.track_id = t.track_id
        GROUP BY g.genre_id, g.name ORDER BY revenue DESC
    """, "revenue_by_genre.csv")
    run(conn, """
        SELECT billing_country AS country, ROUND(SUM(total), 2) AS revenue, COUNT(DISTINCT customer_id) AS customers
        FROM invoice GROUP BY billing_country ORDER BY revenue DESC
    """, "revenue_by_country.csv")
    run(conn, """
        SELECT c.first_name || ' ' || c.last_name AS customer_name, i.billing_country, ROUND(SUM(i.total), 2) AS total_spent
        FROM customer c JOIN invoice i ON i.customer_id = c.customer_id GROUP BY c.customer_id, i.billing_country ORDER BY total_spent DESC
    """, "customer_spend.csv")
    conn.close()
    print("Done. Connect Power BI/Tableau to CSVs in exports/")

if __name__ == "__main__":
    main()
