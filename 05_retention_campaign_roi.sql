/* BUSINESS CASE: ROI Simulation for Retention Campaign
Hypothesis: If we invest in retaining the "High Risk" customers identified in step 04, 
what is the potential return on investment?

ASSUMPTIONS (Conservative Estimates):
1. Target: High Risk Customers (Score >= 5) from previous step.
2. Campaign Cost: $50 per customer (Call center time + incentive offer).
3. Success Rate: 20% (Industry standard for targeted retention).
4. Customer Value: Average Monthly Charges * 12 months (LTV calculation).
*/

WITH high_risk_segment AS (
    -- Re-calculating the High Risk segment logic (Score >= 5 logic simplified here)
    SELECT 
        COUNT(customerID) AS target_customers,
        SUM(MonthlyCharges) AS total_mrr_at_risk,
        AVG(MonthlyCharges) AS avg_mrr
    FROM telco_churn
    WHERE Churn = 'No' 
    AND (
        (Contract = 'Month-to-month') 
        OR (PaymentMethod = 'Electronic check') 
        OR (tenure <= 6)
    )
),
campaign_financials AS (
    SELECT 
        target_customers,
        total_mrr_at_risk,
        
        -- COST: How much do we spend to try to save them?
        (target_customers * 50) AS total_campaign_investment,
        
        -- REVENUE SAVED: Assuming we save 20% of them for 1 year
        (total_mrr_at_risk * 0.20 * 12) AS projected_revenue_saved
    FROM high_risk_segment
)
-- FINAL ROI CALCULATION
SELECT 
    target_customers,
    total_campaign_investment AS cost_usd,
    projected_revenue_saved AS revenue_saved_usd,
    
    -- Net Profit from Campaign
    (projected_revenue_saved - total_campaign_investment) AS net_profit_usd,
    
    -- ROI Percentage: (Net Profit / Cost) * 100
    ROUND(
        ((projected_revenue_saved - total_campaign_investment) / total_campaign_investment) * 100, 
    2) AS roi_percentage
FROM campaign_financials;