
-- Customer retention by signup cohort
WITH customer_cohorts AS (
    SELECT
        customer_id,
        strftime('%Y-%m', signup_date) AS cohort_month,
        customer_status,
        CASE
            WHEN churn_date IS NOT NULL
            THEN strftime('%Y-%m', churn_date)
            ELSE NULL
        END AS churn_month
    FROM customers
),
cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers
    FROM customer_cohorts
    GROUP BY cohort_month
)
SELECT
    cc.cohort_month,
    cs.cohort_customers,
    COUNT(DISTINCT cc.customer_id) AS customers_in_cohort,
    COUNT(
        DISTINCT CASE
            WHEN cc.customer_status = 'Active'
            THEN cc.customer_id
        END
    ) AS currently_active_customers,
    ROUND(
        100.0 * COUNT(
            DISTINCT CASE
                WHEN cc.customer_status = 'Active'
                THEN cc.customer_id
            END
        ) / NULLIF(cs.cohort_customers, 0),
        2
    ) AS current_retention_pct
FROM customer_cohorts cc
JOIN cohort_sizes cs
    ON cc.cohort_month = cs.cohort_month
GROUP BY
    cc.cohort_month,
    cs.cohort_customers
ORDER BY cc.cohort_month;
