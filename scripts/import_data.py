#!/usr/bin/env python3
"""
Import iTunes CSV datasets into SQLite.
Run from project root: python3 scripts/import_data.py
"""
import csv
import os
import sqlite3

# Paths relative to project root (parent of scripts/)
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATABASE = os.path.join(ROOT, "itunes.db")
DATASET_DIR = os.path.join(ROOT, "Dataset")
SCHEMA_PATH = os.path.join(ROOT, "sql", "schema.sql")

def run_schema(conn):
    with open(SCHEMA_PATH, "r") as f:
        conn.executescript(f.read())
    conn.commit()

def import_csv(conn, table: str, filename: str, columns: list):
    path = os.path.join(DATASET_DIR, filename)
    placeholders = ",".join("?" for _ in columns)
    col_list = ",".join(columns)
    with open(path, "r", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        rows = [[row.get(c) or None for c in columns] for row in reader]
    conn.executemany(
        f"INSERT OR REPLACE INTO {table} ({col_list}) VALUES ({placeholders})",
        rows,
    )
    conn.commit()
    print(f"  {table}: {len(rows)} rows")

def main():
    os.chdir(ROOT)
    if not os.path.isdir(DATASET_DIR):
        print("Dataset/ folder not found.")
        return
    conn = sqlite3.connect(DATABASE)
    print("Applying schema...")
    run_schema(conn)
    print("Importing CSVs...")
    import_csv(conn, "genre", "genre.csv", ["genre_id", "name"])
    import_csv(conn, "media_type", "media_type.csv", ["media_type_id", "name"])
    import_csv(conn, "artist", "artist.csv", ["artist_id", "name"])
    import_csv(conn, "album", "album.csv", ["album_id", "title", "artist_id"])
    import_csv(conn, "employee", "employee.csv", [
        "employee_id", "last_name", "first_name", "title", "reports_to", "levels",
        "birthdate", "hire_date", "address", "city", "state", "country", "postal_code",
        "phone", "fax", "email"
    ])
    import_csv(conn, "track", "track.csv", [
        "track_id", "name", "album_id", "media_type_id", "genre_id", "composer",
        "milliseconds", "bytes", "unit_price"
    ])
    import_csv(conn, "customer", "customer.csv", [
        "customer_id", "first_name", "last_name", "company", "address", "city", "state",
        "country", "postal_code", "phone", "fax", "email", "support_rep_id"
    ])
    import_csv(conn, "invoice", "invoice.csv", [
        "invoice_id", "customer_id", "invoice_date", "billing_address", "billing_city",
        "billing_state", "billing_country", "billing_postal_code", "total"
    ])
    import_csv(conn, "invoice_line", "invoice_line.csv", [
        "invoice_line_id", "invoice_id", "track_id", "unit_price", "quantity"
    ])
    import_csv(conn, "playlist", "playlist.csv", ["playlist_id", "name"])
    import_csv(conn, "playlist_track", "playlist_track.csv", ["playlist_id", "track_id"])
    conn.close()
    print("Done.")

if __name__ == "__main__":
    main()
