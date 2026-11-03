
-- Revenue and customer count by subscription plan
SELECT
    p.plan_name,
    p.tier,
    p.billing_interval,
    COUNT(DISTINCT sm.customer_id) AS customer_count,
    SUM(
        CASE
            WHEN sm.is_active = 'Yes' THEN 1
            ELSE 0
        END
    ) AS active_subscription_records,
    ROUND(
        SUM(
            CASE
                WHEN sm.is_active = 'Yes' THEN sm.mrr_usd
                ELSE 0
            END
        ), 2
    ) AS active_mrr_usd
FROM subscription_months sm
JOIN plans p
    ON sm.plan_id = p.plan_id
WHERE sm.period_month = (
    SELECT MAX(period_month)
    FROM subscription_months
)
GROUP BY
    p.plan_name,
    p.tier,
    p.billing_interval
ORDER BY active_mrr_usd DESC;
