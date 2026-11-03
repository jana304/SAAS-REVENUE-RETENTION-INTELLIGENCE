
-- 1. Subscription count by status
SELECT
    subscription_status,
    COUNT(*) AS subscription_count,
    ROUND(SUM(mrr_usd), 2) AS total_mrr_usd,
    ROUND(AVG(mrr_usd), 2) AS average_mrr_usd
FROM subscriptions
GROUP BY subscription_status
ORDER BY subscription_count DESC;


-- 2. Overall subscription metrics
SELECT
    COUNT(*) AS total_subscriptions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(mrr_usd), 2) AS total_subscription_mrr_usd,
    ROUND(AVG(mrr_usd), 2) AS average_subscription_mrr_usd
FROM subscriptions;
