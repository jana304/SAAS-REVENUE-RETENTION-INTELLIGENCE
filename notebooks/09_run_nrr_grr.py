
from pathlib import Path
import sqlite3
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent.parent
DB_PATH = BASE_DIR / "data" / "saas_revenue.db"
SQL_PATH = BASE_DIR / "sql" / "11_nrr_grr_analysis.sql"
OUTPUT_DIR = BASE_DIR / "data" / "processed"
OUTPUT_PATH = OUTPUT_DIR / "nrr_grr_monthly.csv"

if not DB_PATH.exists():
    raise FileNotFoundError(f"Database not found: {DB_PATH}")

if not SQL_PATH.exists():
    raise FileNotFoundError(f"SQL file not found: {SQL_PATH}")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

query = SQL_PATH.read_text(encoding="utf-8")

with sqlite3.connect(DB_PATH) as connection:
    df = pd.read_sql_query(query, connection)

df.to_csv(OUTPUT_PATH, index=False)

print("=" * 70)
print("MONTHLY NRR AND GRR ANALYSIS")
print("=" * 70)
print(df.tail(6).to_string(index=False))
print("\nTotal rows:", len(df))
print("Exported to:", OUTPUT_PATH)
print("\nExport completed successfully.")
