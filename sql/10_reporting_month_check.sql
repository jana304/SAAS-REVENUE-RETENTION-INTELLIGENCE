
SELECT
    MIN(period_month) AS first_reporting_month,
    MAX(period_month) AS latest_reporting_month,
    COUNT(DISTINCT period_month) AS reporting_months
FROM subscription_months;
