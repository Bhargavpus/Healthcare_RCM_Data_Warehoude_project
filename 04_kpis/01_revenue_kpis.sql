/*
================================================================================
 04_kpis / 01_revenue_kpis.sql
 Reusable reporting views over the gold star schema - point Power BI / Excel
 / SSRS at these. Re-create after every gold reload (or wrap them as a step
 in run_all.sql, which it already is).
================================================================================
*/
USE HealthcareRCM_DWH;
GO

----------------------------------------------------------------------
-- 1. Revenue (charge & paid amount) per provider, per department
----------------------------------------------------------------------
CREATE OR ALTER VIEW gold.vw_revenue_by_provider_dept AS
SELECT
    p.FullName              AS Provider_Name,
    d.Name                  AS Dept_Name,
    COUNT(*)                AS Transaction_Count,
    SUM(f.ChargeAmount)     AS Total_Charge_Amt,
    SUM(f.PaidAmount)       AS Total_Paid_Amt,
    SUM(f.OutstandingAmount) AS Total_Outstanding_Amt
FROM gold.fact_transactions f
LEFT JOIN gold.dim_provider p ON p.Provider_Key = f.FK_Provider_Key
LEFT JOIN gold.dim_department d ON d.Dept_Key = f.FK_Dept_Key
GROUP BY p.FullName, d.Name;
GO

----------------------------------------------------------------------
-- 2. Monthly revenue trend per provider/department
----------------------------------------------------------------------
CREATE OR ALTER VIEW gold.vw_monthly_revenue_trend AS
SELECT
    p.FullName            AS Provider_Name,
    d.Name                AS Dept_Name,
    dt.YearMonth,
    SUM(f.ChargeAmount)   AS Total_Charge_Amt,
    SUM(f.PaidAmount)     AS Total_Paid_Amt
FROM gold.fact_transactions f
LEFT JOIN gold.dim_provider p   ON p.Provider_Key = f.FK_Provider_Key
LEFT JOIN gold.dim_department d ON d.Dept_Key = f.FK_Dept_Key
LEFT JOIN gold.dim_date dt      ON dt.Date_Key = f.FK_ServiceDate_Key
GROUP BY p.FullName, d.Name, dt.YearMonth;
GO

----------------------------------------------------------------------
-- 3. Collection rate (paid / charged) by department
----------------------------------------------------------------------
CREATE OR ALTER VIEW gold.vw_collection_rate_by_dept AS
SELECT
    d.Name                       AS Dept_Name,
    SUM(f.ChargeAmount)          AS Total_Charge_Amt,
    SUM(f.PaidAmount)            AS Total_Paid_Amt,
    CASE WHEN SUM(f.ChargeAmount) > 0
         THEN CAST(SUM(f.PaidAmount) AS DECIMAL(12,4)) / SUM(f.ChargeAmount)
         ELSE NULL END           AS Collection_Rate
FROM gold.fact_transactions f
LEFT JOIN gold.dim_department d ON d.Dept_Key = f.FK_Dept_Key
GROUP BY d.Name;
GO

----------------------------------------------------------------------
-- 4. Top CPT codes by total charge amount
----------------------------------------------------------------------
CREATE OR ALTER VIEW gold.vw_top_cpt_codes AS
SELECT
    f.FK_CPT_Code                AS CPT_Code,
    cpt.Description,
    cpt.Category,
    COUNT(*)                     AS Transaction_Count,
    SUM(f.ChargeAmount)          AS Total_Charge_Amt,
    SUM(f.PaidAmount)            AS Total_Paid_Amt
FROM gold.fact_transactions f
LEFT JOIN gold.dim_cpt_code cpt ON cpt.CPT_Code = f.FK_CPT_Code
GROUP BY f.FK_CPT_Code, cpt.Description, cpt.Category;
GO

----------------------------------------------------------------------
-- 5. Claim denial rate by payor
----------------------------------------------------------------------
CREATE OR ALTER VIEW gold.vw_claim_denial_rate_by_payor AS
SELECT
    py.PayorID,
    py.PayorType,
    COUNT(*)                                                          AS Total_Claims,
    SUM(CASE WHEN fc.ClaimStatus = 'Denied' THEN 1 ELSE 0 END)        AS Denied_Claims,
    CAST(SUM(CASE WHEN fc.ClaimStatus = 'Denied' THEN 1 ELSE 0 END) AS DECIMAL(12,4))
        / NULLIF(COUNT(*), 0)                                         AS Denial_Rate
FROM gold.fact_claims fc
LEFT JOIN gold.dim_payor py ON py.Payor_Key = fc.FK_Payor_Key
GROUP BY py.PayorID, py.PayorType;
GO

----------------------------------------------------------------------
-- 6. Claims AR aging buckets (open/pending claims only)
----------------------------------------------------------------------
CREATE OR ALTER VIEW gold.vw_claims_ar_aging AS
SELECT
    fc.Claim_Key,
    fc.ClaimStatus,
    fc.ClaimAmount,
    fc.PaidAmount,
    fc.ClaimAmount - ISNULL(fc.PaidAmount, 0)             AS Open_Balance,
    DATEDIFF(DAY, dt.[Date], CAST(GETDATE() AS DATE))      AS Days_Outstanding,
    CASE
        WHEN DATEDIFF(DAY, dt.[Date], CAST(GETDATE() AS DATE)) <= 30  THEN '0-30'
        WHEN DATEDIFF(DAY, dt.[Date], CAST(GETDATE() AS DATE)) <= 60  THEN '31-60'
        WHEN DATEDIFF(DAY, dt.[Date], CAST(GETDATE() AS DATE)) <= 90  THEN '61-90'
        WHEN DATEDIFF(DAY, dt.[Date], CAST(GETDATE() AS DATE)) <= 120 THEN '91-120'
        ELSE '120+'
    END                                                     AS Aging_Bucket
FROM gold.fact_claims fc
LEFT JOIN gold.dim_date dt ON dt.Date_Key = fc.FK_ServiceDate_Key
WHERE fc.ClaimStatus IN ('Pending', 'Approved')      -- open / not-yet-settled statuses in this dataset
  AND fc.ClaimAmount > ISNULL(fc.PaidAmount, 0);
GO

----------------------------------------------------------------------
-- 7. Patient volume / demographics summary
----------------------------------------------------------------------
CREATE OR ALTER VIEW gold.vw_patient_demographics AS
SELECT
    Gender,
    CASE
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) < 18 THEN 'Under 18'
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) < 35 THEN '18-34'
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) < 50 THEN '35-49'
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) < 65 THEN '50-64'
        ELSE '65+'
    END        AS Age_Band,
    COUNT(*)   AS Patient_Count
FROM gold.dim_patient
GROUP BY
    Gender,
    CASE
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) < 18 THEN 'Under 18'
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) < 35 THEN '18-34'
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) < 50 THEN '35-49'
        WHEN DATEDIFF(YEAR, DOB, GETDATE()) < 65 THEN '50-64'
        ELSE '65+'
    END;
GO