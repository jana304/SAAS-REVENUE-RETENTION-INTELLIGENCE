
from pathlib import Path
import sqlite3
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent.parent
DB_PATH = BASE_DIR / "data" / "saas_revenue.db"

if not DB_PATH.exists():
    raise FileNotFoundError(f"Database not found: {DB_PATH}")

with sqlite3.connect(DB_PATH) as connection:
    # Check the monthly activity table's column names and data types
    schema = pd.read_sql_query(
        "PRAGMA table_info(subscription_months);",
        connection
    )

    print("=" * 70)
    print("1. SUBSCRIPTION_MONTHS SCHEMA")
    print("=" * 70)
    print(schema[["name", "type"]].to_string(index=False))

    # Inspect available movement types
    movements = pd.read_sql_query(
        """
        SELECT
            movement_type,
            COUNT(*) AS record_count,
            ROUND(SUM(mrr_delta_usd), 2) AS total_mrr_delta_usd
        FROM subscription_months
        GROUP BY movement_type
        ORDER BY record_count DESC;
        """,
        connection
    )

    print("\n" + "=" * 70)
    print("2. MOVEMENT TYPE SUMMARY")
    print("=" * 70)
    print(movements.to_string(index=False))

    # Inspect the latest six reporting months
    monthly = pd.read_sql_query(
        """
        SELECT
            period_month,
            SUM(CASE
                WHEN is_active = 'Yes' THEN mrr_usd
                ELSE 0
            END) AS active_mrr,
            SUM(CASE
                WHEN movement_type = 'New' THEN mrr_delta_usd
                ELSE 0
            END) AS new_mrr,
            SUM(CASE
                WHEN movement_type = 'Expansion' THEN mrr_delta_usd
                ELSE 0
            END) AS expansion_mrr,
            SUM(CASE
                WHEN movement_type = 'Contraction' THEN mrr_delta_usd
                ELSE 0
            END) AS contraction_mrr,
            SUM(CASE
                WHEN movement_type = 'Churn' THEN mrr_delta_usd
                ELSE 0
            END) AS churn_mrr,
            SUM(CASE
                WHEN movement_type = 'Reactivation' THEN mrr_delta_usd
                ELSE 0
            END) AS reactivation_mrr
        FROM subscription_months
        GROUP BY period_month
        ORDER BY period_month DESC
        LIMIT 6;
        """,
        connection
    )

    print("\n" + "=" * 70)
    print("3. LATEST SIX MONTHS OF MRR MOVEMENTS")
    print("=" * 70)
    print(monthly.to_string(index=False))

print("\nSchema and movement checks completed.")
