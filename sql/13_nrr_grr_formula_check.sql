
-- Validate NRR and GRR formula outputs.

WITH monthly AS (
    SELECT
        period_month,

        SUM(CASE WHEN is_active = 'Yes'
                 THEN mrr_usd ELSE 0 END) AS ending_mrr,

        SUM(CASE WHEN movement_type = 'Expansion'
                 THEN mrr_delta_usd ELSE 0 END) AS expansion_mrr,

        SUM(CASE WHEN movement_type = 'Contraction'
                 THEN mrr_delta_usd ELSE 0 END) AS contraction_mrr,

        SUM(CASE WHEN movement_type = 'Churn'
                 THEN mrr_delta_usd ELSE 0 END) AS churn_mrr

    FROM subscription_months
    GROUP BY period_month
),

with_starting_mrr AS (
    SELECT
        *,
        LAG(ending_mrr) OVER (
            ORDER BY period_month
        ) AS starting_mrr
    FROM monthly
)

SELECT
    period_month,
    ROUND(starting_mrr, 2) AS starting_mrr,

    ROUND(
        100.0 * (
            starting_mrr + expansion_mrr
            + contraction_mrr + churn_mrr
        ) / NULLIF(starting_mrr, 0),
        2
    ) AS nrr_pct,

    ROUND(
        100.0 * (
            starting_mrr + contraction_mrr + churn_mrr
        ) / NULLIF(starting_mrr, 0),
        2
    ) AS grr_pct,

    CASE
        WHEN starting_mrr IS NULL THEN 'No prior month'
        WHEN starting_mrr <= 0 THEN 'Invalid starting MRR'
        WHEN (
            100.0 * (
                starting_mrr + expansion_mrr
                + contraction_mrr + churn_mrr
            ) / starting_mrr
        ) < 0 THEN 'Review NRR'
        ELSE 'OK'
    END AS validation_status

FROM with_starting_mrr
ORDER BY period_month;
