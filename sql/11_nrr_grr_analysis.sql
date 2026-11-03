
-- Monthly Net Revenue Retention (NRR) and
-- Gross Revenue Retention (GRR)
--
-- New customer and reactivation revenue are excluded
-- from both metrics.

WITH monthly_movements AS (
    SELECT
        period_month,

        SUM(
            CASE
                WHEN is_active = 'Yes' THEN mrr_usd
                ELSE 0
            END
        ) AS active_mrr,

        SUM(
            CASE
                WHEN movement_type = 'Expansion'
                THEN mrr_delta_usd
                ELSE 0
            END
        ) AS expansion_mrr,

        SUM(
            CASE
                WHEN movement_type = 'Contraction'
                THEN mrr_delta_usd
                ELSE 0
            END
        ) AS contraction_mrr,

        SUM(
            CASE
                WHEN movement_type = 'Churn'
                THEN mrr_delta_usd
                ELSE 0
            END
        ) AS churn_mrr

    FROM subscription_months
    GROUP BY period_month
),

monthly_starting_mrr AS (
    SELECT
        *,
        LAG(active_mrr) OVER (
            ORDER BY period_month
        ) AS starting_mrr
    FROM monthly_movements
)

SELECT
    period_month,

    ROUND(starting_mrr, 2) AS starting_mrr,

    ROUND(active_mrr, 2) AS ending_mrr,

    ROUND(expansion_mrr, 2) AS expansion_mrr,

    ROUND(contraction_mrr, 2) AS contraction_mrr,

    ROUND(churn_mrr, 2) AS churn_mrr,

    ROUND(
        100.0 * (
            starting_mrr
            + expansion_mrr
            + contraction_mrr
            + churn_mrr
        ) / NULLIF(starting_mrr, 0),
        2
    ) AS nrr_pct,

    ROUND(
        100.0 * (
            starting_mrr
            + contraction_mrr
            + churn_mrr
        ) / NULLIF(starting_mrr, 0),
        2
    ) AS grr_pct

FROM monthly_starting_mrr
ORDER BY period_month;
