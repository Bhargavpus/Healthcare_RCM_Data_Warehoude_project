
USE HealthcareRCM_DWH;
GO

CREATE OR ALTER PROCEDURE gold.load_gold AS
BEGIN

    PRINT '=============================================';
    PRINT 'Loading Gold Layer';
    PRINT '=============================================';

    -- ============================================================
    -- 2. gold.dim_department
    -- ============================================================
   PRINT '>> Truncating Table: gold.dim_department';
    TRUNCATE TABLE gold.dim_department;

    PRINT '>> Inserting Table: gold.dim_department';
    INSERT INTO gold.dim_department (Dept_Key, DeptID, Name, datasource)
    SELECT
        DeptID + '-' + datasource AS Dept_Key,
        DeptID,
        Name,
        datasource
    FROM silver.departments;

    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 3. gold.dim_provider
    -- ============================================================
    PRINT '>> Truncating Table: gold.dim_provider';
    TRUNCATE TABLE gold.dim_provider;

    PRINT '>> Inserting Table: gold.dim_provider';
    INSERT INTO gold.dim_provider (Provider_Key, ProviderID, FullName, Specialization, Dept_Key, datasource)
    SELECT
        ProviderID AS Provider_Key,
        ProviderID,
        LTRIM(RTRIM(ISNULL(FirstName, '') + ' ' + ISNULL(LastName, ''))) AS FullName,
        Specialization,
        DeptID + '-' + datasource AS Dept_Key,
        datasource
    FROM silver.providers;

    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 4. gold.dim_patient
    -- ============================================================
    PRINT '>> Truncating Table: gold.dim_patient';
    TRUNCATE TABLE gold.dim_patient;

    PRINT '>> Inserting Table: gold.dim_patient';
    INSERT INTO gold.dim_patient (Patient_Key, PatientID, FullName, Gender, DOB, Age, datasource)
    SELECT
        PatientID + '-' + datasource AS Patient_Key,
        PatientID,
        LTRIM(RTRIM(ISNULL(FirstName, '') + ' ' + ISNULL(LastName, ''))) AS FullName,
        Gender,
        DOB,
        DATEDIFF(YEAR,DOB,GETDATE()) AS Age,
        datasource
    FROM silver.patients;

    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 5. gold.dim_cpt_code
    -- ============================================================
    PRINT '>> Truncating Table: gold.dim_cpt_code';
    TRUNCATE TABLE gold.dim_cpt_code;

    PRINT '>> Inserting Table: gold.dim_cpt_code';
    INSERT INTO gold.dim_cpt_code (CPT_Code, Category, Description)
    SELECT CPT_Code, Procedure_Code_Category, Procedure_Code_Description
    FROM silver.cptcodes;

    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 6. gold.dim_payor
    -- Built from claims, the only feed that carries real payor names.
    -- ============================================================
    PRINT '>> Truncating Table: gold.dim_payor';
    TRUNCATE TABLE gold.dim_payor;

    PRINT '>> Inserting Table: gold.dim_payor';
    INSERT INTO gold.dim_payor (Payor_Key, PayorID, PayorType)
    SELECT DISTINCT
        ISNULL(PayorID, 'UNKNOWN') + '|' + ISNULL(PayorType, 'UNKNOWN') AS Payor_Key,
        PayorID,
        PayorType
    FROM silver.claims
    WHERE PayorID IS NOT NULL;

    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 7. gold.fact_transactions
    -- Grain: one row per charge transaction.
    -- ============================================================
    PRINT '>> Truncating Table: gold.fact_transactions';
    TRUNCATE TABLE gold.fact_transactions;

    PRINT '>> Inserting Table: gold.fact_transactions';
    INSERT INTO gold.fact_transactions
        (Transaction_Key, FK_Patient_Key, FK_Provider_Key, FK_Dept_Key,
            FK_CPT_Code, FK_ServiceDate_Key, ServiceDate,
            ChargeAmount, PaidAmount, OutstandingAmount, datasource)
    SELECT
        TransactionID + '-' + datasource           AS Transaction_Key,
        PatientID + '-' + datasource                AS FK_Patient_Key,
        ProviderID                                     AS FK_Provider_Key,
        DeptID + '-' + datasource                         AS FK_Dept_Key,
        ProcedureCode                                        AS FK_CPT_Code,
        CONVERT(INT, FORMAT(ServiceDate, 'yyyyMMdd'))           AS FK_ServiceDate_Key,
        ServiceDate,
        Amount                                                    AS ChargeAmount,
        PaidAmount,
        ISNULL(Amount, 0) - ISNULL(PaidAmount, 0)                   AS OutstandingAmount,
        datasource
    FROM silver.transactions
    WHERE ServiceDate IS NOT NULL;

    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 8. gold.fact_claims
    -- Grain: one row per claim.
    -- ============================================================
    PRINT '>> Truncating Table: gold.fact_claims';
    TRUNCATE TABLE gold.fact_claims;

    PRINT '>> Inserting Table: gold.fact_claims';
    INSERT INTO gold.fact_claims
        (Claim_Key, FK_Patient_Key, FK_Payor_Key, FK_ServiceDate_Key,
            ClaimAmount, PaidAmount, ClaimStatus, datasource)
    SELECT
        ClaimID + '-' + datasource                              AS Claim_Key,
        PatientID + '-' + datasource                              AS FK_Patient_Key,
        ISNULL(PayorID, 'UNKNOWN') + '|' + ISNULL(PayorType, 'UNKNOWN') AS FK_Payor_Key,
        CONVERT(INT, FORMAT(ServiceDate, 'yyyyMMdd'))                    AS FK_ServiceDate_Key,
        ClaimAmount,
        PaidAmount,
        ClaimStatus,
        datasource
    FROM silver.claims
    WHERE ServiceDate IS NOT NULL;

    PRINT '>> ----------------------------------------------------------<<';


    PRINT '================================================';
    PRINT 'Loading Gold Layer is Completed';
    PRINT '================================================';
    
END
GO

