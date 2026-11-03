
from pathlib import Path
import pandas as pd

DATA_DIR = Path("data/raw")

customers = pd.read_csv(DATA_DIR / "customers.csv")
invoices = pd.read_csv(DATA_DIR / "invoices.csv")
plans = pd.read_csv(DATA_DIR / "plans.csv")
subscriptions = pd.read_csv(DATA_DIR / "subscriptions.csv")
months = pd.read_csv(DATA_DIR / "subscription_months.csv")


def show_counts(df, column):
    print(f"\n{column}:")
    print(df[column].value_counts(dropna=False).to_string())


print("=" * 60)
print("1. CUSTOMER STATUS")
print("=" * 60)
show_counts(customers, "customer_status")

print("\nChurn date by customer status:")
print(pd.crosstab(
    customers["customer_status"],
    customers["churn_date"].isna(),
    rownames=["Customer status"],
    colnames=["Churn date is missing"]
))

print("\n" + "=" * 60)
print("2. SUBSCRIPTION STATUS")
print("=" * 60)
show_counts(subscriptions, "subscription_status")

print("\n" + "=" * 60)
print("3. INVOICE STATUS")
print("=" * 60)
show_counts(invoices, "invoice_status")

print("\n" + "=" * 60)
print("4. MONTHLY REVENUE MOVEMENTS")
print("=" * 60)
show_counts(months, "movement_type")

print("\n" + "=" * 60)
print("5. DATE RANGES")
print("=" * 60)

date_columns = {
    "customers": (customers, ["signup_date", "churn_date"]),
    "subscriptions": (subscriptions, ["start_date", "end_date"]),
    "invoices": (invoices, ["invoice_date", "invoice_month"]),
    "subscription_months": (months, ["period_month", "month_start_date"]),
}

for table_name, (df, columns) in date_columns.items():
    print(f"\n{table_name}:")
    for column in columns:
        dates = pd.to_datetime(df[column], errors="coerce")
        print(
            f"{column}: {dates.min()} to {dates.max()} "
            f"| invalid/missing: {dates.isna().sum()}"
        )

print("\n" + "=" * 60)
print("6. TABLE RELATIONSHIP CHECKS")
print("=" * 60)

checks = {
    "Invoice customer IDs missing from customers": (
        ~invoices["customer_id"].isin(customers["customer_id"])
    ).sum(),
    "Subscription customer IDs missing from customers": (
        ~subscriptions["customer_id"].isin(customers["customer_id"])
    ).sum(),
    "Subscription plan IDs missing from plans": (
        ~subscriptions["plan_id"].isin(plans["plan_id"])
    ).sum(),
    "Monthly customer IDs missing from customers": (
        ~months["customer_id"].isin(customers["customer_id"])
    ).sum(),
    "Monthly subscription IDs missing from subscriptions": (
        ~months["subscription_id"].isin(subscriptions["subscription_id"])
    ).sum(),
    "Monthly plan IDs missing from plans": (
        ~months["plan_id"].isin(plans["plan_id"])
    ).sum(),
}

for description, count in checks.items():
    print(f"{description}: {count}")

print("\nValidation completed.")
