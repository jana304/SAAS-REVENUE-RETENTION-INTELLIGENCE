
-- Validate whether monthly MRR movements reconcile
-- with the reported ending MRR.

WITH monthly AS (
    SELECT
        period_month,

        SUM(
            CASE WHEN is_active = 'Yes'
                 THEN mrr_usd ELSE 0 END
        ) AS ending_mrr,

        SUM(
            CASE WHEN movement_type = 'New'
                 THEN mrr_delta_usd ELSE 0 END
        ) AS new_mrr,

        SUM(
            CASE WHEN movement_type = 'Expansion'
                 THEN mrr_delta_usd ELSE 0 END
        ) AS expansion_mrr,

        SUM(
            CASE WHEN movement_type = 'Contraction'
                 THEN mrr_delta_usd ELSE 0 END
        ) AS contraction_mrr,

        SUM(
            CASE WHEN movement_type = 'Churn'
                 THEN mrr_delta_usd ELSE 0 END
        ) AS churn_mrr,

        SUM(
            CASE WHEN movement_type = 'Reactivation'
                 THEN mrr_delta_usd ELSE 0 END
        ) AS reactivation_mrr

    FROM subscription_months
    GROUP BY period_month
),

comparison AS (
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
    ROUND(new_mrr, 2) AS new_mrr,
    ROUND(expansion_mrr, 2) AS expansion_mrr,
    ROUND(contraction_mrr, 2) AS contraction_mrr,
    ROUND(churn_mrr, 2) AS churn_mrr,
    ROUND(reactivation_mrr, 2) AS reactivation_mrr,
    ROUND(ending_mrr, 2) AS ending_mrr,

    ROUND(
        ending_mrr - (
            starting_mrr
            + new_mrr
            + expansion_mrr
            + contraction_mrr
            + churn_mrr
            + reactivation_mrr
        ),
        2
    ) AS reconciliation_difference

FROM comparison
ORDER BY period_month;
