# Apple iTunes Music Store Analysis

End-to-end SQL-based analytical pipeline for the iTunes music store: relational schema, data import, required SQL queries (Q1–Q15), exploratory and advanced analytics, and dashboards.

**Repository:** [github.com/ritesh-1912/iTunes_Music_Analysis](https://github.com/ritesh-1912/iTunes_Music_Analysis)

## Clone and run

```bash
git clone https://github.com/ritesh-1912/iTunes_Music_Analysis.git
cd iTunes_Music_Analysis
```

## Requirements

- **Python 3.6+** (for import and export scripts)
- **SQLite 3** (included with Python)
- A modern browser (for the HTML dashboard)

## Quick Start

Run all commands from the **project root**:

```bash
# 1. Create database and load CSVs
python3 scripts/import_data.py

# 2. Run required queries (Q1–Q15)
sqlite3 itunes.db < sql/itunes_analysis_queries.sql

# 3. Run exploratory and advanced analytics
sqlite3 itunes.db < sql/exploratory_and_advanced_analytics.sql

# 4. Build and view dashboard
python3 scripts/export_dashboard_data.py
python3 scripts/build_dashboard_html.py
# Open dashboard/dashboard.html in a browser
```

## Project Structure

```
├── README.md                 # This file
├── itunes.db                 # SQLite database (created by import script)
├── Dataset/                  # CSV source data (11 files)
├── sql/                      # SQL files
│   ├── schema.sql            # DDL: tables, keys, indexes
│   ├── itunes_analysis_queries.sql   # Required Q1–Q15 submission queries
│   └── exploratory_and_advanced_analytics.sql
├── scripts/                  # Python scripts (run from project root)
│   ├── import_data.py        # Creates itunes.db and loads CSVs
│   ├── export_dashboard_data.py
│   ├── build_dashboard_html.py
│   └── export_for_bi.py       # Exports CSVs for Power BI / Tableau
├── dashboard/                # Web dashboard
│   ├── dashboard.html        # Open in browser after building
│   ├── dashboard_data.json
│   └── dashboard_data_embed.json
├── exports/                  # Power BI / Tableau CSV exports
│   ├── monthly_revenue.csv
│   ├── revenue_by_genre.csv
│   ├── revenue_by_country.csv
│   └── customer_spend.csv
└── docs/
    └── FINAL_REPORT.md       # Insights and recommendations
```

## Database

- **Engine:** SQLite 3  
- **File:** `itunes.db` (at project root, created by `scripts/import_data.py`)  
- **Tables:** artist, album, track, genre, media_type, employee, customer, invoice, invoice_line, playlist, playlist_track  

To inspect interactively:

```bash
sqlite3 itunes.db
```

## Dashboards

- **HTML (Chart.js):** Run `scripts/export_dashboard_data.py` and `scripts/build_dashboard_html.py`, then open `dashboard/dashboard.html`. No server needed.
- **Power BI / Tableau:** Run `python3 scripts/export_for_bi.py`, then connect to the CSVs in `exports/`.

## Submission Deliverables

- **SQL:** `sql/itunes_analysis_queries.sql` (Q1–Q15)
- **Dashboard:** `dashboard/dashboard.html` and/or Power BI/Tableau using `exports/`
- **Report:** `docs/FINAL_REPORT.md`

## References

- Project brief: `Project Title_ Apple iTunes Music Analysis.docx`
- Presentation: `Itunes Apple Music Store Analysis.pptx`
