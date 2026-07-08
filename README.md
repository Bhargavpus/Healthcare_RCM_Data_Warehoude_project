# Healthcare Revenue Cycle Management — SQL Server Data Warehouse

## 1. Architectur

| Layer | Stored Procedure | What it does |
| --- | --- | --- |
| **bronze** | `bronze.load_bronze` | Loads all 13 raw CSV files as-is via `BULK INSERT` |
| **silver** | `silver.load_silver` | Cleans, trims, standardises values (gender, dates, amounts), combines Hospital-A + Hospital-B into single tables |
| **gold** | `gold.load_gold` | Builds the star schema: 6 dimensions + 2 fact tables |

### Gold star schema

* `gold.dim_date`, `gold.dim_patient`, `gold.dim_provider`, `gold.dim_department`, `gold.dim_cpt_code`, `gold.dim_payor`
* `gold.fact_transactions` — grain: one row per charge transaction
* `gold.fact_claims` — grain: one row per insurance claim



## 2. KPI views (`sql/04_kpis/01_revenue_kpis.sql`)

| View | Answers |
| --- | --- |
| `gold.vw_revenue_by_provider_dept` | Total charged/paid/outstanding $ by provider & department |
| `gold.vw_monthly_revenue_trend` | Charged/paid $ trended by month |
| `gold.vw_collection_rate_by_dept` | Paid ÷ charged ratio by department |
| `gold.vw_top_cpt_codes` | Highest-revenue CPT procedure codes |
| `gold.vw_claim_denial_rate_by_payor` | Denied ÷ total claims, by payor |
| `gold.vw_claims_ar_aging` | Open claim balance, bucketed 0-30/31-60/61-90/91-120/120+ days |
| `gold.vw_patient_demographics` | Patient counts by gender & age band |

