
from pathlib import Path
import pandas as pd

# Project data folder
DATA_DIR = Path("data/raw")

files = [
    "customers.csv",
    "invoices.csv",
    "plans.csv",
    "subscriptions.csv",
    "subscription_months.csv",
]

for filename in files:
    file_path = DATA_DIR / filename

    print("\n" + "=" * 60)
    print(f"FILE: {filename}")
    print("=" * 60)

    df = pd.read_csv(file_path)

    print(f"Rows: {df.shape[0]:,}")
    print(f"Columns: {df.shape[1]:,}")
    print("\nColumn names:")
    print(df.columns.tolist())

    print(f"\nDuplicate rows: {df.duplicated().sum():,}")
    print(f"Missing values: {df.isna().sum().sum():,}")

    print("\nMissing values by column:")
    print(df.isna().sum()[df.isna().sum() > 0])
