
from pathlib import Path
import pandas as pd

DATA_DIR = Path("data/processed")

for filename in [
    "invoices.csv",
    "subscription_months.csv",
]:
    df = pd.read_csv(DATA_DIR / filename)

    print("\n" + "=" * 55)
    print(filename)
    print("=" * 55)

    print("\nMissing values by column:")
    print(df.isna().sum().to_string())

    print("\nFirst 5 rows:")
    print(df.head().to_string(index=False))

    print("\nData types:")
    print(df.dtypes.to_string())
