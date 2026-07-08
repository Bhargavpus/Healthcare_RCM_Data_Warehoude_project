USE HealthcareRCM_DWH;
GO

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    

    PRINT '=============================================';
    PRINT 'Loading Silver Layer';
    PRINT '=============================================';


    -- ============================================================
    -- 1. silver.departments
    -- Combines departments from both hospitals.
    -- Both hospitals share the same DeptID / Name master list,
    -- but we tag each row with its datasource for traceability.
    -- ============================================================
    PRINT '>> Truncating Table: silver.departments';
    TRUNCATE TABLE silver.departments;

    PRINT '>> Inserting Table: silver.departments';
    INSERT INTO silver.departments (DeptID, Name, datasource)
    SELECT
        TRIM(DeptID)  AS DeptID,
        TRIM(Name)    AS Name,
        'hos-a'       AS datasource
    FROM bronze.hosa_departments
    WHERE DeptID IS NOT NULL

    UNION ALL

    SELECT
        TRIM(DeptID)  AS DeptID,
        TRIM(Name)    AS Name,
        'hos-b'       AS datasource
    FROM bronze.hosb_departments
    WHERE DeptID IS NOT NULL;

    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 2. silver.providers
    -- Combines providers from both hospitals.
    -- NPI is cast to BIGINT; invalid values become NULL.
    -- ============================================================
    PRINT '>> Truncating Table: silver.providers';
    TRUNCATE TABLE silver.providers;

    PRINT '>> Inserting Table: silver.providers';
    INSERT INTO silver.providers
        (ProviderID, FirstName, LastName, Specialization, DeptID, NPI, datasource)
    SELECT
        TRIM(ProviderID)      AS ProviderID,
        TRIM(FirstName)       AS FirstName,
        TRIM(LastName)        AS LastName,
        TRIM(Specialization)  AS Specialization,
        TRIM(DeptID)          AS DeptID,
        TRY_CONVERT(BIGINT, TRIM(NPI)) AS NPI,
        'hos-a'               AS datasource
    FROM bronze.hosa_providers
    WHERE ProviderID IS NOT NULL

    UNION ALL

    SELECT
        TRIM(ProviderID)      AS ProviderID,
        TRIM(FirstName)       AS FirstName,
        TRIM(LastName)        AS LastName,
        TRIM(Specialization)  AS Specialization,
        TRIM(DeptID)          AS DeptID,
        TRY_CONVERT(BIGINT, TRIM(NPI)) AS NPI,
        'hos-b'               AS datasource
    FROM bronze.hosb_providers
    WHERE ProviderID IS NOT NULL;

    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 3. silver.patients
    -- Hospital-B uses different column names (ID, F_Name, L_Name,
    -- M_Name, Updated_Date) — both are mapped to the same schema.
    -- DOB and ModifiedDate are safely cast using TRY_CONVERT.
    -- Gender is standardised to 'Male' / 'Female' / 'n/a'.
    -- Duplicates removed using ROW_NUMBER on PatientID.
    -- ============================================================
    PRINT '>> Truncating Table: silver.patients';
    TRUNCATE TABLE silver.patients;

    PRINT '>> Inserting Table: silver.patients';
    INSERT INTO silver.patients
        (PatientID, FirstName, LastName, MiddleName, SSN, PhoneNumber,
            Gender, DOB, Address, ModifiedDate, datasource)
    SELECT
        PatientID,
        TRIM(FirstName)   AS FirstName,
        TRIM(LastName)    AS LastName,
        TRIM(MiddleName)  AS MiddleName,
        TRIM(SSN)         AS SSN,
        TRIM(PhoneNumber) AS PhoneNumber,
        CASE
            WHEN UPPER(TRIM(Gender)) IN ('M', 'MALE')   THEN 'Male'
            WHEN UPPER(TRIM(Gender)) IN ('F', 'FEMALE') THEN 'Female'
            ELSE 'n/a'
        END               AS Gender,
        TRY_CONVERT(DATE, DOB)          AS DOB,
        TRIM(Address)     AS Address,
        TRY_CONVERT(DATE, ModifiedDate) AS ModifiedDate,
        datasource
    FROM (
        -- Hospital-A
        SELECT
            PatientID, FirstName, LastName, MiddleName, SSN, PhoneNumber,
            Gender, DOB, Address, ModifiedDate,
            'hos-a' AS datasource,
            ROW_NUMBER() OVER (PARTITION BY PatientID ORDER BY ModifiedDate DESC) AS rn
        FROM bronze.hosa_patients
        WHERE PatientID IS NOT NULL

        UNION ALL

        -- Hospital-B  (different column names, mapped here)
        SELECT
            ID         AS PatientID,
            F_Name     AS FirstName,
            L_Name     AS LastName,
            M_Name     AS MiddleName,
            SSN, PhoneNumber, Gender, DOB, Address,
            Updated_Date AS ModifiedDate,
            'hos-b'    AS datasource,
            ROW_NUMBER() OVER (PARTITION BY ID ORDER BY Updated_Date DESC) AS rn
        FROM bronze.hosb_patients
        WHERE ID IS NOT NULL
    ) t
    WHERE rn = 1;

    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 4. silver.encounters
    -- Combines encounters from both hospitals.
    -- EncounterDate, InsertedDate and ModifiedDate safely cast.
    -- ============================================================
    PRINT '>> Truncating Table: silver.encounters';
    TRUNCATE TABLE silver.encounters;

    PRINT '>> Inserting Table: silver.encounters';
    INSERT INTO silver.encounters
        (EncounterID, PatientID, EncounterDate, EncounterType,
            ProviderID, DepartmentID, ProcedureCode,
            InsertedDate, ModifiedDate, datasource)
    SELECT
        TRIM(EncounterID)   AS EncounterID,
        TRIM(PatientID)     AS PatientID,
        TRY_CONVERT(DATE, EncounterDate)  AS EncounterDate,
        TRIM(EncounterType) AS EncounterType,
        TRIM(ProviderID)    AS ProviderID,
        TRIM(DepartmentID)  AS DepartmentID,
        TRIM(ProcedureCode) AS ProcedureCode,
        TRY_CONVERT(DATE, InsertedDate)   AS InsertedDate,
        TRY_CONVERT(DATE, ModifiedDate)   AS ModifiedDate,
        'hos-a'             AS datasource
    FROM bronze.hosa_encounters
    WHERE EncounterID IS NOT NULL

    UNION ALL

    SELECT
        TRIM(EncounterID)   AS EncounterID,
        TRIM(PatientID)     AS PatientID,
        TRY_CONVERT(DATE, EncounterDate)  AS EncounterDate,
        TRIM(EncounterType) AS EncounterType,
        TRIM(ProviderID)    AS ProviderID,
        TRIM(DepartmentID)  AS DepartmentID,
        TRIM(ProcedureCode) AS ProcedureCode,
        TRY_CONVERT(DATE, InsertedDate)   AS InsertedDate,
        TRY_CONVERT(DATE, ModifiedDate)   AS ModifiedDate,
        'hos-b'             AS datasource
    FROM bronze.hosb_encounters
    WHERE EncounterID IS NOT NULL;

    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 5. silver.transactions
    -- Combines transactions from both hospitals.
    -- Amount and PaidAmount cast to DECIMAL — bad values become NULL.
    -- All date columns use TRY_CONVERT for safe casting.
    -- ============================================================
    PRINT '>> Truncating Table: silver.transactions';
    TRUNCATE TABLE silver.transactions;

    PRINT '>> Inserting Table: silver.transactions';
    INSERT INTO silver.transactions
        (TransactionID, EncounterID, PatientID, ProviderID, DeptID,
            VisitDate, ServiceDate, PaidDate,
            VisitType, Amount, AmountType, PaidAmount,
            ClaimID, PayorID, ProcedureCode, ICDCode,
            LineOfBusiness, MedicaidID, MedicareID,
            InsertDate, ModifiedDate, datasource)
    SELECT
        TRIM(TransactionID)  AS TransactionID,
        TRIM(EncounterID)    AS EncounterID,
        TRIM(PatientID)      AS PatientID,
        TRIM(ProviderID)     AS ProviderID,
        TRIM(DeptID)         AS DeptID,
        TRY_CONVERT(DATE, VisitDate)    AS VisitDate,
        TRY_CONVERT(DATE, ServiceDate)  AS ServiceDate,
        TRY_CONVERT(DATE, PaidDate)     AS PaidDate,
        TRIM(VisitType)      AS VisitType,
        TRY_CONVERT(DECIMAL(12,2), Amount)     AS Amount,
        TRIM(AmountType)     AS AmountType,
        TRY_CONVERT(DECIMAL(12,2), PaidAmount) AS PaidAmount,
        TRIM(ClaimID)        AS ClaimID,
        TRIM(PayorID)        AS PayorID,
        TRIM(ProcedureCode)  AS ProcedureCode,
        TRIM(ICDCode)        AS ICDCode,
        TRIM(LineOfBusiness) AS LineOfBusiness,
        TRIM(MedicaidID)     AS MedicaidID,
        TRIM(MedicareID)     AS MedicareID,
        TRY_CONVERT(DATE, InsertDate)   AS InsertDate,
        TRY_CONVERT(DATE, ModifiedDate) AS ModifiedDate,
        'hos-a'              AS datasource
    FROM bronze.hosa_transactions
    WHERE TransactionID IS NOT NULL

    UNION ALL

    SELECT
        TRIM(TransactionID)  AS TransactionID,
        TRIM(EncounterID)    AS EncounterID,
        TRIM(PatientID)      AS PatientID,
        TRIM(ProviderID)     AS ProviderID,
        TRIM(DeptID)         AS DeptID,
        TRY_CONVERT(DATE, VisitDate)    AS VisitDate,
        TRY_CONVERT(DATE, ServiceDate)  AS ServiceDate,
        TRY_CONVERT(DATE, PaidDate)     AS PaidDate,
        TRIM(VisitType)      AS VisitType,
        TRY_CONVERT(DECIMAL(12,2), Amount)     AS Amount,
        TRIM(AmountType)     AS AmountType,
        TRY_CONVERT(DECIMAL(12,2), PaidAmount) AS PaidAmount,
        TRIM(ClaimID)        AS ClaimID,
        TRIM(PayorID)        AS PayorID,
        TRIM(ProcedureCode)  AS ProcedureCode,
        TRIM(ICDCode)        AS ICDCode,
        TRIM(LineOfBusiness) AS LineOfBusiness,
        TRIM(MedicaidID)     AS MedicaidID,
        TRIM(MedicareID)     AS MedicareID,
        TRY_CONVERT(DATE, InsertDate)   AS InsertDate,
        TRY_CONVERT(DATE, ModifiedDate) AS ModifiedDate,
        'hos-b'              AS datasource
    FROM bronze.hosb_transactions
    WHERE TransactionID IS NOT NULL;

    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 6. silver.claims
    -- Combines insurance claims from both hospitals.
    -- ClaimAmount, PaidAmount, Deductible, Coinsurance, Copay all
    -- cast to DECIMAL. Dates use TRY_CONVERT.
    -- ============================================================
    PRINT '>> Truncating Table: silver.claims';
    TRUNCATE TABLE silver.claims;

    PRINT '>> Inserting Table: silver.claims';
    INSERT INTO silver.claims
        (ClaimID, TransactionID, PatientID, EncounterID,
            ProviderID, DeptID, ServiceDate, ClaimDate,
            PayorID, ClaimAmount, PaidAmount, ClaimStatus, PayorType,
            Deductible, Coinsurance, Copay,
            InsertDate, ModifiedDate, datasource)
    SELECT
        TRIM(ClaimID)       AS ClaimID,
        TRIM(TransactionID) AS TransactionID,
        TRIM(PatientID)     AS PatientID,
        TRIM(EncounterID)   AS EncounterID,
        TRIM(ProviderID)    AS ProviderID,
        TRIM(DeptID)        AS DeptID,
        TRY_CONVERT(DATE, ServiceDate)  AS ServiceDate,
        TRY_CONVERT(DATE, ClaimDate)    AS ClaimDate,
        TRIM(PayorID)       AS PayorID,
        TRY_CONVERT(DECIMAL(12,2), ClaimAmount)  AS ClaimAmount,
        TRY_CONVERT(DECIMAL(12,2), PaidAmount)   AS PaidAmount,
        TRIM(ClaimStatus)   AS ClaimStatus,
        TRIM(PayorType)     AS PayorType,
        TRY_CONVERT(DECIMAL(12,2), Deductible)   AS Deductible,
        TRY_CONVERT(DECIMAL(12,2), Coinsurance)  AS Coinsurance,
        TRY_CONVERT(DECIMAL(12,2), Copay)        AS Copay,
        TRY_CONVERT(DATE, InsertDate)   AS InsertDate,
        TRY_CONVERT(DATE, ModifiedDate) AS ModifiedDate,
        'hos-a'             AS datasource
    FROM bronze.claims_hospital1
    WHERE ClaimID IS NOT NULL

    UNION ALL

    SELECT
        TRIM(ClaimID)       AS ClaimID,
        TRIM(TransactionID) AS TransactionID,
        TRIM(PatientID)     AS PatientID,
        TRIM(EncounterID)   AS EncounterID,
        TRIM(ProviderID)    AS ProviderID,
        TRIM(DeptID)        AS DeptID,
        TRY_CONVERT(DATE, ServiceDate)  AS ServiceDate,
        TRY_CONVERT(DATE, ClaimDate)    AS ClaimDate,
        TRIM(PayorID)       AS PayorID,
        TRY_CONVERT(DECIMAL(12,2), ClaimAmount)  AS ClaimAmount,
        TRY_CONVERT(DECIMAL(12,2), PaidAmount)   AS PaidAmount,
        TRIM(ClaimStatus)   AS ClaimStatus,
        TRIM(PayorType)     AS PayorType,
        TRY_CONVERT(DECIMAL(12,2), Deductible)   AS Deductible,
        TRY_CONVERT(DECIMAL(12,2), Coinsurance)  AS Coinsurance,
        TRY_CONVERT(DECIMAL(12,2), Copay)        AS Copay,
        TRY_CONVERT(DATE, InsertDate)   AS InsertDate,
        TRY_CONVERT(DATE, ModifiedDate) AS ModifiedDate,
        'hos-b'             AS datasource
    FROM bronze.claims_hospital2
    WHERE ClaimID IS NOT NULL;

    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 7. silver.cptcodes
    -- CPT procedure reference table.
    -- Deduped: if same CPT_Code appears in multiple categories,
    -- keep the first occurrence only (ROW_NUMBER).
    -- ============================================================
    PRINT '>> Truncating Table: silver.cptcodes';
    TRUNCATE TABLE silver.cptcodes;

    PRINT '>> Inserting Table: silver.cptcodes';
    INSERT INTO silver.cptcodes
        (CPT_Code, Procedure_Code_Category, Procedure_Code_Description, Code_Status)
    SELECT
        TRIM(CPT_Code)                    AS CPT_Code,
        TRIM(Procedure_Code_Category)     AS Procedure_Code_Category,
        TRIM(Procedure_Code_Description)  AS Procedure_Code_Description,
        TRIM(Code_Status)                 AS Code_Status
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY CPT_Code ORDER BY Procedure_Code_Category) AS duplicate_test
        FROM bronze.cptcodes
        WHERE CPT_Code IS NOT NULL
            AND Procedure_Code_Description IS NOT NULL
    ) t
    WHERE duplicate_test = 1;

    PRINT '>> ----------------------------------------------------------<<';


    PRINT '================================================';
    PRINT 'Loading Silver Layer is Completed';
    PRINT '================================================';
    
END
GO

execute bronze.load_bronze

