SELECT 
    PaymentMethod, 
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE Churn = 'Yes') AS churn_count,
    ROUND(COUNT(*) FILTER (WHERE Churn = 'Yes')::numeric / COUNT(*) * 100, 2) AS churn_rate_pct
FROM telco_churn
GROUP BY 1
ORDER BY churn_rate_pct DESC;