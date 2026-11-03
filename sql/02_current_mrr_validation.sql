
-- 1. Find the latest reporting month
SELECT
    MAX(period_month) AS latest_reporting_month
FROM subscription_months;


-- 2. Calculate MRR for active records in the latest month
WITH latest_month AS (
    SELECT MAX(period_month) AS latest_month
    FROM subscription_months
)
SELECT
    lm.latest_month,
    COUNT(*) AS monthly_records,
    SUM(
        CASE WHEN sm.is_active = 'Yes' THEN 1 ELSE 0 END
    ) AS active_records,
    COUNT(
        DISTINCT CASE
            WHEN sm.is_active = 'Yes' THEN sm.customer_id
        END
    ) AS active_customers,
    ROUND(
        SUM(
            CASE WHEN sm.is_active = 'Yes'
                 THEN sm.mrr_usd ELSE 0 END
        ),
        2
    ) AS active_mrr_usd
FROM subscription_months sm
CROSS JOIN latest_month lm
WHERE sm.period_month = lm.latest_month
GROUP BY lm.latest_month;


-- 3. Understand revenue movements in the latest month
WITH latest_month AS (
    SELECT MAX(period_month) AS latest_month
    FROM subscription_months
)
SELECT
    sm.movement_type,
    COUNT(*) AS record_count,
    ROUND(SUM(sm.mrr_delta_usd), 2) AS total_mrr_change_usd
FROM subscription_months sm
CROSS JOIN latest_month lm
WHERE sm.period_month = lm.latest_month
GROUP BY sm.movement_type
ORDER BY record_count DESC;
