#!/usr/bin/env python3
"""
Export key metrics from itunes.db to JSON for the HTML dashboard.
Run from project root after import_data.py: python3 scripts/export_dashboard_data.py
"""
import json
import os
import sqlite3

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB = os.path.join(ROOT, "itunes.db")
DASHBOARD_DIR = os.path.join(ROOT, "dashboard")

def main():
    os.chdir(ROOT)
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row

    data = {}

    # Monthly revenue (last 24 months)
    r = conn.execute("""
        SELECT strftime('%Y-%m', invoice_date) AS month, ROUND(SUM(total), 2) AS revenue
        FROM invoice
        WHERE invoice_date >= (SELECT date(MAX(invoice_date), '-24 months') FROM invoice)
        GROUP BY strftime('%Y-%m', invoice_date) ORDER BY month
    """)
    data["monthly_revenue"] = [{"month": row["month"], "revenue": row["revenue"]} for row in r]

    # Top 10 genres by revenue
    r = conn.execute("""
        SELECT g.name AS genre, ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
        FROM genre g JOIN track t ON t.genre_id = g.genre_id JOIN invoice_line il ON il.track_id = t.track_id
        GROUP BY g.genre_id, g.name ORDER BY revenue DESC LIMIT 10
    """)
    data["top_genres"] = [{"genre": row["genre"], "revenue": row["revenue"]} for row in r]

    # Top 10 countries by revenue
    r = conn.execute("""
        SELECT billing_country AS country, ROUND(SUM(total), 2) AS revenue
        FROM invoice GROUP BY billing_country ORDER BY revenue DESC LIMIT 10
    """)
    data["top_countries"] = [{"country": row["country"], "revenue": row["revenue"]} for row in r]

    # Top 10 customers by spend
    r = conn.execute("""
        SELECT c.first_name || ' ' || c.last_name AS name, ROUND(SUM(i.total), 2) AS total_spent
        FROM customer c JOIN invoice i ON i.customer_id = c.customer_id
        GROUP BY c.customer_id ORDER BY total_spent DESC LIMIT 10
    """)
    data["top_customers"] = [{"name": row["name"], "total_spent": row["total_spent"]} for row in r]

    # Top 10 artists by revenue
    r = conn.execute("""
        SELECT ar.name AS artist, ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
        FROM artist ar JOIN album al ON al.artist_id = ar.artist_id JOIN track t ON t.album_id = al.album_id
        JOIN invoice_line il ON il.track_id = t.track_id
        GROUP BY ar.artist_id ORDER BY revenue DESC LIMIT 10
    """)
    data["top_artists"] = [{"artist": row["artist"], "revenue": row["revenue"]} for row in r]

    # KPIs: total revenue, total customers, total invoices, avg invoice
    r = conn.execute("SELECT ROUND(SUM(total), 2) AS v FROM invoice").fetchone()
    data["total_revenue"] = r["v"]
    r = conn.execute("SELECT COUNT(DISTINCT customer_id) AS v FROM invoice").fetchone()
    data["total_customers"] = r["v"]
    r = conn.execute("SELECT COUNT(*) AS v FROM invoice").fetchone()
    data["total_invoices"] = r["v"]
    r = conn.execute("SELECT ROUND(AVG(total), 2) AS v FROM invoice").fetchone()
    data["avg_invoice"] = r["v"]

    conn.close()

    os.makedirs(DASHBOARD_DIR, exist_ok=True)
    out = os.path.join(DASHBOARD_DIR, "dashboard_data.json")
    with open(out, "w") as f:
        json.dump(data, f, indent=2)
    print(f"Written {out}")

    out_embed = os.path.join(DASHBOARD_DIR, "dashboard_data_embed.json")
    with open(out_embed, "w") as f:
        json.dump(data, f, separators=(",", ":"))
    print(f"Written {out_embed}")

if __name__ == "__main__":
    main()
