#!/usr/bin/env python3
"""Build dashboard.html with embedded JSON. Run from project root after export_dashboard_data.py."""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DASHBOARD_DIR = os.path.join(ROOT, "dashboard")

def main():
    os.chdir(ROOT)
    data_path = os.path.join(DASHBOARD_DIR, "dashboard_data.json")
    with open(data_path) as f:
        data = json.load(f)
    embedded = json.dumps(data, separators=(",", ":"))

    html = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>iTunes Music Store – Analytics Dashboard</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <style>
    * { box-sizing: border-box; }
    body { font-family: 'Segoe UI', system-ui, sans-serif; margin: 0; padding: 20px; background: #0f1419; color: #e6edf3; }
    h1 { font-size: 1.5rem; margin-bottom: 24px; }
    .kpis { display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 16px; margin-bottom: 24px; }
    .kpi { background: #161b22; border: 1px solid #30363d; border-radius: 8px; padding: 16px; text-align: center; }
    .kpi .value { font-size: 1.5rem; font-weight: 700; color: #58a6ff; }
    .kpi .label { font-size: 0.8rem; color: #8b949e; margin-top: 4px; }
    .charts { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 24px; }
    .chart-box { background: #161b22; border: 1px solid #30363d; border-radius: 8px; padding: 16px; }
    .chart-box h2 { font-size: 1rem; margin: 0 0 12px; }
    .chart-box canvas { max-height: 260px; }
  </style>
</head>
<body>
  <h1>Apple iTunes Music Store – Analytics Dashboard</h1>
  <div class="kpis">
    <div class="kpi"><div class="value" id="kpi-revenue">-</div><div class="label">Total Revenue ($)</div></div>
    <div class="kpi"><div class="value" id="kpi-customers">-</div><div class="label">Customers</div></div>
    <div class="kpi"><div class="value" id="kpi-invoices">-</div><div class="label">Invoices</div></div>
    <div class="kpi"><div class="value" id="kpi-avg">-</div><div class="label">Avg Invoice ($)</div></div>
  </div>
  <div class="charts">
    <div class="chart-box"><h2>Monthly Revenue</h2><canvas id="chart-monthly"></canvas></div>
    <div class="chart-box"><h2>Top Genres by Revenue</h2><canvas id="chart-genres"></canvas></div>
    <div class="chart-box"><h2>Top Countries by Revenue</h2><canvas id="chart-countries"></canvas></div>
    <div class="chart-box"><h2>Top Customers by Spend</h2><canvas id="chart-customers"></canvas></div>
    <div class="chart-box"><h2>Top Artists by Revenue</h2><canvas id="chart-artists"></canvas></div>
  </div>
  <script>
    window.DASHBOARD_DATA = """ + embedded + """;
    const d = window.DASHBOARD_DATA;
    document.getElementById('kpi-revenue').textContent = d.total_revenue;
    document.getElementById('kpi-customers').textContent = d.total_customers;
    document.getElementById('kpi-invoices').textContent = d.total_invoices;
    document.getElementById('kpi-avg').textContent = d.avg_invoice;
    const opts = { responsive: true, maintainAspectRatio: true };
    new Chart(document.getElementById('chart-monthly'), { type: 'line', data: { labels: d.monthly_revenue.map(x => x.month), datasets: [{ label: 'Revenue ($)', data: d.monthly_revenue.map(x => x.revenue), borderColor: '#58a6ff', fill: false }] }, options: opts });
    new Chart(document.getElementById('chart-genres'), { type: 'bar', data: { labels: d.top_genres.map(x => x.genre), datasets: [{ label: 'Revenue ($)', data: d.top_genres.map(x => x.revenue), backgroundColor: '#238636' }] }, options: { ...opts, indexAxis: 'y' } });
    new Chart(document.getElementById('chart-countries'), { type: 'bar', data: { labels: d.top_countries.map(x => x.country), datasets: [{ label: 'Revenue ($)', data: d.top_countries.map(x => x.revenue), backgroundColor: '#8957e5' }] }, options: { ...opts, indexAxis: 'y' } });
    new Chart(document.getElementById('chart-customers'), { type: 'bar', data: { labels: d.top_customers.map(x => x.name), datasets: [{ label: 'Spent ($)', data: d.top_customers.map(x => x.total_spent), backgroundColor: '#d29922' }] }, options: { ...opts, indexAxis: 'y' } });
    new Chart(document.getElementById('chart-artists'), { type: 'bar', data: { labels: d.top_artists.map(x => x.artist), datasets: [{ label: 'Revenue ($)', data: d.top_artists.map(x => x.revenue), backgroundColor: '#da3633' }] }, options: { ...opts, indexAxis: 'y' } });
  </script>
</body>
</html>
"""
    out_path = os.path.join(DASHBOARD_DIR, "dashboard.html")
    with open(out_path, "w") as f:
        f.write(html)
    print(f"Written {out_path}")

if __name__ == "__main__":
    main()
