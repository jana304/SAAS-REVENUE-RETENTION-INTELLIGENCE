
from pathlib import Path
import pandas as pd

DATA_DIR = Path("data/raw")

customers = pd.read_csv(DATA_DIR / "customers.csv")
subscriptions = pd.read_csv(DATA_DIR / "subscriptions.csv")

date_checks = [
    ("Customers", customers, "signup_date"),
    ("Customers", customers, "churn_date"),
    ("Subscriptions", subscriptions, "start_date"),
    ("Subscriptions", subscriptions, "end_date"),
]

for table_name, df, column in date_checks:
    parsed = pd.to_datetime(
        df[column],
        format="%d-%m-%Y",
        errors="coerce"
    )

    invalid_count = (df[column].notna() & parsed.isna()).sum()

    print(f"\n{table_name} — {column}")
    print("Original missing values:", df[column].isna().sum())
    print("Invalid non-empty dates:", invalid_count)
    print("Earliest date:", parsed.min())
    print("Latest date:", parsed.max())
