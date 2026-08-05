# E-Commerce Price Tracker

**How to automatically track product prices over time and detect the best moment to buy?**

Data engineering pipeline that scrapes e-commerce prices daily (Mercado Livre), stores historical data, and feeds an interactive Power BI dashboard for trend analysis and purchase decisions.

## Key Highlights

| Feature | Detail |
|---------|--------|
| Source | Mercado Livre (meta tag extraction) |
| Automation | Windows Task Scheduler + batch scripts |
| Storage | Excel/Pandas with automatic history append |
| Visualization | Power BI dashboard with price trends |

## Stack

`Python` · `BeautifulSoup` · `Requests` · `Pandas` · `Power BI` · `Windows Task Scheduler`

## Pipeline

1. **Extract** — Python scraper pulls prices from product pages via meta tags
2. **Store** — Appends to historical Excel base with deduplication
3. **Automate** — Task Scheduler runs the script daily without intervention
4. **Visualize** — Power BI dashboard shows price variation over time

## Project Structure

```
├── scripts/          # Python scraping scripts
├── dataset/          # Historical price data (Excel)
├── dashboard/        # Power BI dashboard files
└── README.md
```

## How to Run

```bash
git clone https://github.com/guilhermehrsilva/ecommerce-price-tracker.git
cd ecommerce-price-tracker
pip install pandas requests beautifulsoup4
python scripts/scraper.py
```

Automate with Windows Task Scheduler pointing to the included `.bat` file for daily execution.
