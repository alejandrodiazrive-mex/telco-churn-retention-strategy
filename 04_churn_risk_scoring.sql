/* BUSINESS CONTEXT: 
We cannot stop everyone from churning, but we can prioritize.
This query creates a 'Risk Score' (1-10) for CURRENT customers based on 
known churn factors identified in previous analysis steps.

GOAL: Generate a priority list for the Retention Team.
*/

WITH risk_calculation AS (
    SELECT 
        customerID,
        tenure,
        Contract,
        MonthlyCharges,
        PaymentMethod,
        
        -- FACTOR 1: Contract Flexibility (Month-to-month is highest risk)
        CASE 
            WHEN Contract = 'Month-to-month' THEN 4
            WHEN Contract = 'One year' THEN 2
            ELSE 0 
        END AS contract_risk,

        -- FACTOR 2: Payment Friction (Electronic check has highest churn correlation)
        CASE 
            WHEN PaymentMethod = 'Electronic check' THEN 3
            WHEN PaymentMethod IN ('Mailed check') THEN 2
            ELSE 0 
        END AS payment_risk,

        -- FACTOR 3: New Customer Vulnerability (First 6 months are critical)
        CASE 
            WHEN tenure <= 6 THEN 3
            WHEN tenure <= 12 THEN 1
            ELSE 0 
        END AS tenure_risk

    FROM telco_churn
    WHERE Churn = 'No' -- IMPORTANT: We only score customers who are still with us
),
scored_customers AS (
    SELECT 
        *,
        (contract_risk + payment_risk + tenure_risk) AS total_risk_score
    FROM risk_calculation
)
-- FINAL OUPUT: High Value + High Risk Customers (The "Must Calls")
SELECT 
    customerID,
    total_risk_score,
    MonthlyCharges,
    tenure,
    Contract,
    CASE 
        WHEN total_risk_score >= 8 THEN 'Critical'
        WHEN total_risk_score >= 5 THEN 'High'
        ELSE 'Medium/Low'
    END AS risk_category
FROM scored_customers
WHERE total_risk_score >= 5 -- Filter for the retention team dashboard
ORDER BY total_risk_score DESC, MonthlyCharges DESC;