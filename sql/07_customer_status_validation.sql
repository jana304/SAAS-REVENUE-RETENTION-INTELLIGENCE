
SELECT
    customer_status,
    COUNT(*) AS customer_count
FROM customers
GROUP BY customer_status
ORDER BY customer_count DESC;
