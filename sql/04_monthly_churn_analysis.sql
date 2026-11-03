
WITH monthly AS (
    SELECT
        period_month,
        SUM(
            CASE WHEN is_active = 'Yes'
                 THEN mrr_usd ELSE 0 END
        ) AS active_mrr,
        SUM(
            CASE WHEN movement_type = 'Churn'
                 THEN mrr_delta_usd ELSE 0 END
        ) AS churn_mrr,
        COUNT(
            CASE WHEN movement_type = 'Churn'
                 THEN 1 END
        ) AS churn_events
    FROM subscription_months
    GROUP BY period_month
),
with_previous AS (
    SELECT
        *,
        LAG(active_mrr) OVER (
            ORDER BY period_month
        ) AS previous_month_mrr
    FROM monthly
)
SELECT
    period_month,
    ROUND(previous_month_mrr, 2) AS previous_month_mrr,
    churn_events,
    ROUND(churn_mrr, 2) AS churn_mrr,
    ROUND(
        100.0 * ABS(churn_mrr) / NULLIF(previous_month_mrr, 0),
        2
    ) AS gross_mrr_churn_rate_pct
FROM with_previous
ORDER BY period_month;
