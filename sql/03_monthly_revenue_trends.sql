
-- 1. Monthly active MRR and active customers
SELECT
    period_month,
    COUNT(
        DISTINCT CASE
            WHEN is_active = 'Yes' THEN customer_id
        END
    ) AS active_customers,
    ROUND(
        SUM(
            CASE WHEN is_active = 'Yes'
                 THEN mrr_usd ELSE 0 END
        ),
        2
    ) AS active_mrr_usd
FROM subscription_months
GROUP BY period_month
ORDER BY period_month;


-- 2. Monthly revenue movement summary
SELECT
    period_month,
    ROUND(SUM(mrr_delta_usd), 2) AS net_mrr_change_usd,
    ROUND(SUM(
        CASE WHEN movement_type = 'New'
             THEN mrr_delta_usd ELSE 0 END
    ), 2) AS new_mrr_usd,
    ROUND(SUM(
        CASE WHEN movement_type = 'Expansion'
             THEN mrr_delta_usd ELSE 0 END
    ), 2) AS expansion_mrr_usd,
    ROUND(SUM(
        CASE WHEN movement_type = 'Churn'
             THEN mrr_delta_usd ELSE 0 END
    ), 2) AS churn_mrr_usd,
    ROUND(SUM(
        CASE WHEN movement_type = 'Contraction'
             THEN mrr_delta_usd ELSE 0 END
    ), 2) AS contraction_mrr_usd
FROM subscription_months
GROUP BY period_month
ORDER BY period_month;
