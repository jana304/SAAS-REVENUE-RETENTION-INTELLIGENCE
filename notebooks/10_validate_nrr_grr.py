
from pathlib import Path
import sqlite3
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent.parent
DB_PATH = BASE_DIR / "data" / "saas_revenue.db"
SQL_PATH = BASE_DIR / "sql" / "12_nrr_grr_validation.sql"

if not DB_PATH.exists():
    raise FileNotFoundError(f"Database not found: {DB_PATH}")

if not SQL_PATH.exists():
    raise FileNotFoundError(f"SQL file not found: {SQL_PATH}")

query = SQL_PATH.read_text(encoding="utf-8")

with sqlite3.connect(DB_PATH) as connection:
    df = pd.read_sql_query(query, connection)

print("=" * 70)
print("MRR RECONCILIATION VALIDATION")
print("=" * 70)
print(df.tail(6).to_string(index=False))

print("\nRows checked:", len(df))

if len(df) > 1:
    differences = df["reconciliation_difference"].iloc[1:]
    tolerance = 0.02
    mismatches = (differences.abs() > tolerance).sum()

    print("Months with movement mismatches:", int(mismatches))

    if mismatches == 0:
        print("All checked months reconcile within $0.02.")
    else:
        print("Some months do not reconcile. Review the results above.")

print("\nValidation completed.")
