
-- Customer churn analysis by plan and customer status
SELECT
    c.customer_status,
    p.tier,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    ROUND(
        AVG(
            CAST(
                julianday(
                    COALESCE(c.churn_date, '2026-06-30')
                ) - julianday(c.signup_date)
                AS REAL
            )
        ), 1
    ) AS average_customer_lifetime_days
FROM customers c
LEFT JOIN subscriptions s
    ON c.customer_id = s.customer_id
LEFT JOIN plans p
    ON s.plan_id = p.plan_id
GROUP BY
    c.customer_status,
    p.tier
ORDER BY
    c.customer_status,
    customer_count DESC;
