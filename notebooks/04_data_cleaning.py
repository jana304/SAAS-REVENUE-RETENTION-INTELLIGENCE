
from pathlib import Path
import pandas as pd

RAW_DIR = Path("data/raw")
PROCESSED_DIR = Path("data/processed")
PROCESSED_DIR.mkdir(parents=True, exist_ok=True)

files = [
    "customers.csv",
    "invoices.csv",
    "plans.csv",
    "subscriptions.csv",
    "subscription_months.csv",
]

# Date columns that use DD-MM-YYYY
day_first_dates = {
    "customers.csv": ["signup_date", "churn_date"],
    "invoices.csv": [
        "invoice_date",
        "billing_period_start",
        "billing_period_end",
    ],
    "plans.csv": ["launched_date"],
    "subscriptions.csv": ["start_date", "end_date"],
    "subscription_months.csv": ["month_start_date"],
}

# Columns that represent a month, such as 2024-01
month_dates = {
    "invoices.csv": ["invoice_month"],
    "subscription_months.csv": ["period_month"],
}

for filename in files:
    print(f"\nProcessing {filename}...")

    df = pd.read_csv(RAW_DIR / filename)
    original_rows = len(df)

    df = df.drop_duplicates().copy()

    for column in day_first_dates.get(filename, []):
        df[column] = pd.to_datetime(
            df[column],
            format="%d-%m-%Y",
            errors="coerce",
        )

    for column in month_dates.get(filename, []):
        df[column] = pd.to_datetime(
            df[column].astype("string"),
            format="%Y-%m",
            errors="coerce",
        )

    output_path = PROCESSED_DIR / filename
    df.to_csv(output_path, index=False, date_format="%Y-%m-%d")

    print("Rows saved:", len(df))
    print("Duplicates removed:", original_rows - len(df))
    print("Saved to:", output_path)

print("\nCorrected cleaning completed.")
