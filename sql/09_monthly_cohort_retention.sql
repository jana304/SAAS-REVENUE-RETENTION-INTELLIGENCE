
-- Cohort retention for signups within the available reporting period
WITH customer_cohorts AS (
    SELECT
        customer_id,
        strftime('%Y-%m', signup_date) AS cohort_month
    FROM customers
    WHERE signup_date >= '2024-01-01'
      AND signup_date < '2026-07-01'
),
monthly_activity AS (
    SELECT DISTINCT
        customer_id,
        strftime('%Y-%m', period_month) AS activity_month
    FROM subscription_months
    WHERE is_active = 'Yes'
),
cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers
    FROM customer_cohorts
    GROUP BY cohort_month
),
cohort_activity AS (
    SELECT
        cc.cohort_month,
        ma.activity_month,
        cc.customer_id,
        (
            (CAST(substr(ma.activity_month, 1, 4) AS INTEGER)
             - CAST(substr(cc.cohort_month, 1, 4) AS INTEGER)) * 12
            +
            (CAST(substr(ma.activity_month, 6, 2) AS INTEGER)
             - CAST(substr(cc.cohort_month, 6, 2) AS INTEGER))
        ) AS month_number
    FROM customer_cohorts cc
    JOIN monthly_activity ma
        ON cc.customer_id = ma.customer_id
    WHERE ma.activity_month >= cc.cohort_month
      AND ma.activity_month <= '2026-06'
)
SELECT
    ca.cohort_month,
    cs.cohort_customers,
    ca.month_number,
    COUNT(DISTINCT ca.customer_id) AS active_customers,
    ROUND(
        100.0 * COUNT(DISTINCT ca.customer_id)
        / NULLIF(cs.cohort_customers, 0),
        2
    ) AS retention_pct
FROM cohort_activity ca
JOIN cohort_sizes cs
    ON ca.cohort_month = cs.cohort_month
GROUP BY
    ca.cohort_month,
    cs.cohort_customers,
    ca.month_number
ORDER BY
    ca.cohort_month,
    ca.month_number;
