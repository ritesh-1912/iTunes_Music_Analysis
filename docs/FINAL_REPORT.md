# Apple iTunes Music Store Analysis – Final Report

## 1. Problem Statement and Business Goals

Apple iTunes operates a large digital music store with millions of tracks and customers worldwide. Leadership sought deeper insights into **customer behavior**, **music preferences**, and **sales performance** to improve product offerings, customer targeting, and operational efficiency.

**Business goals addressed:**

- Understand customer behavior and purchasing trends  
- Identify the most and least popular music genres, tracks, and artists  
- Evaluate sales performance by employees and customer regions  
- Analyze revenue trends across time and product types  
- Uncover growth opportunities (underutilized content, inactive customers)

---

## 2. Data and Schema

**Source:** Relational data provided as 11 CSV files in the `Dataset/` folder.

| Table           | Rows  | Description                          |
|----------------|-------|--------------------------------------|
| genre          | 25    | Music genres                         |
| media_type     | 5     | e.g. MPEG, AAC                       |
| artist         | 275   | Artists                              |
| album          | 347   | Albums (linked to artist)            |
| track          | 3,503 | Tracks (album, genre, media type)    |
| employee       | 9     | Staff (support reps, hierarchy)      |
| customer       | 59    | Customers (linked to support rep)   |
| invoice        | 614   | Invoices (customer, date, total)    |
| invoice_line   | 4,757 | Line items (invoice, track, qty)    |
| playlist       | 18    | Playlists                            |
| playlist_track  | 8,715 | Playlist–track many-to-many          |

**Design:** A single SQLite database (`itunes.db` at project root) with primary and foreign keys matching the above relationships. DDL is in `sql/schema.sql`; data is loaded via `scripts/import_data.py`.

---

## 3. Key Findings from Required Queries (Q1–Q15)

- **Q1 – Senior most employee:** Mohan Madan (Senior General Manager, L7).  
- **Q2 – Most invoices by country:** USA (131), then Canada (76), Brazil (61).  
- **Q3 – Top 3 invoice totals:** $23.76, $19.80, $19.80.  
- **Q4 – Best city for Music Festival:** Prague (highest sum of invoice totals: $273.24).  
- **Q5 – Best customer:** František Wichterlová (total spent $144.54).  
- **Q6 – Rock listeners:** 46 distinct customers purchased Rock; list returned ordered by email.  
- **Q7 – Top 10 rock bands (by track count):** Led Zeppelin, U2, Deep Purple, etc.  
- **Q8 – Tracks longer than average length:** 1,973 tracks; list with name and milliseconds, longest first.  
- **Q9 – Spend by customer and artist:** Full matrix of customer–artist spend for targeting and recommendations.  
- **Q10 – Most popular genre per country:** Rock is #1 in most countries; a few (e.g. Argentina) show Alternative & Punk.  
- **Q11 – Top customer per country:** One (or more in case of tie) top spender per country with amount spent.  
- **Q12 – Most popular artists:** By quantity purchased; Iron Maiden, U2, Metallica, etc.  
- **Q13 – Most popular song:** By purchase quantity (specific track and artist in query result).  
- **Q14 – Average price by media type:** MPEG has highest volume and revenue; Protected AAC next.  
- **Q15 – Most popular countries by revenue:** USA leads, followed by Canada, Brazil, France, Germany.

---

## 4. Exploratory and Advanced Analytics – Highlights

- **Monthly revenue:** Time series shows variability by month; useful for seasonality and forecasting.  
- **Revenue by genre:** Rock dominates; Metal, Alternative & Punk, and Latin follow.  
- **Customer segmentation:** Repeat vs one-time purchasers (count and share) identified via CTEs.  
- **Employee contribution:** Revenue and share per support rep, with running total (window function).  
- **Top tracks by revenue:** Top 5 tracks with rank.  
- **Genre by country:** Most popular genre per country with tie-handling (rank/CTE).  
- **Unpurchased tracks:** Tracks never sold (e.g. some Brazilian live albums); candidates for promotion or pruning.  
- **Average days between purchases:** ~132 days; informs retention and re-engagement campaigns.  
- **Revenue by media type:** MPEG dominates; AAC and other types smaller but present.

---

## 5. Recommendations

### Marketing

- **Focus on Rock and Metal:** Highest revenue and engagement; promote new releases and playlists in these genres.  
- **Target top countries:** USA, Canada, Brazil, France, Germany – prioritize campaigns and localization.  
- **Prague / high-value cities:** Use “best city” (Prague) and top cities for events or city-specific campaigns.  
- **Re-engagement:** Use “average days between purchases” and repeat vs one-time segments for email and offers to bring back dormant customers.

### Product

- **Highlight top artists and tracks:** Use Q12/Q13 and revenue-ranked tracks on homepage and recommendations.  
- **Genre mix:** Align catalog and recommendations with per-country popular genres (Q10).  
- **Underutilized content:** Promote or discount tracks/albums that have never been purchased (exploratory query).  
- **Media types:** Monitor shift to AAC/Protected formats; ensure pricing and quality align with demand.

### Operations

- **Support rep performance:** Use revenue-per-employee and share to balance workload and incentives.  
- **Regional focus:** Align support and marketing with revenue-by-country and top-customer-per-country.  
- **Pricing:** Use average price by media type and genre (Q14 and exploratory) to review price bands and discounts.

---

## 6. Deliverables Summary

| Deliverable              | Location |
|--------------------------|----------|
| Relational schema        | `sql/schema.sql` |
| Data import              | `scripts/import_data.py` |
| Required queries Q1–Q15  | `sql/itunes_analysis_queries.sql` |
| Exploratory & advanced   | `sql/exploratory_and_advanced_analytics.sql` |
| Web dashboard            | `dashboard/dashboard.html` (build with `scripts/build_dashboard_html.py`) |
| Power BI / Tableau data  | `exports/*.csv` (via `scripts/export_for_bi.py`) |
| Final report             | `docs/FINAL_REPORT.md` |

---

## 7. How to Reproduce

Run all commands from the **project root**:

1. **Database:** `python3 scripts/import_data.py` (creates `itunes.db` from `Dataset/*.csv`).  
2. **Queries:** `sqlite3 itunes.db < sql/itunes_analysis_queries.sql` and `sqlite3 itunes.db < sql/exploratory_and_advanced_analytics.sql`.  
3. **Dashboard:** `python3 scripts/export_dashboard_data.py` then `python3 scripts/build_dashboard_html.py`; open `dashboard/dashboard.html` in a browser.  
4. **Power BI / Tableau:** `python3 scripts/export_for_bi.py` and connect to the CSVs in `exports/`.
