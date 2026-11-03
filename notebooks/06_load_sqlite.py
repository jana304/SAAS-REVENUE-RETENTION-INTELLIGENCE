
from pathlib import Path
import sqlite3
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data" / "processed"
DB_PATH = BASE_DIR / "data" / "saas_revenue.db"

files = {
    "customers": "customers.csv",
    "invoices": "invoices.csv",
    "plans": "plans.csv",
    "subscriptions": "subscriptions.csv",
    "subscription_months": "subscription_months.csv",
}

with sqlite3.connect(DB_PATH) as connection:
    for table_name, filename in files.items():
        file_path = DATA_DIR / filename
        df = pd.read_csv(file_path)

        df.to_sql(
            table_name,
            connection,
            if_exists="replace",
            index=False,
        )

        count = pd.read_sql_query(
            f"SELECT COUNT(*) AS row_count FROM {table_name}",
            connection,
        )["row_count"][0]

        print(f"{table_name}: {count:,} rows loaded")

print(f"\nSQLite database created at:\n{DB_PATH}")
