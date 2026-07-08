
USE HealthcareRCM_DWH;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    

    PRINT '=============================================';
    PRINT 'Loading Bronze Layer';
    PRINT '=============================================';


    -- ============================================================
    -- 1. bronze.hosa_departments
    -- ============================================================
    PRINT '>> Truncating Table: bronze.hosa_departments';
    TRUNCATE TABLE bronze.hosa_departments;

    PRINT '>> Inserting Table: bronze.hosa_departments';
    BULK INSERT bronze.hosa_departments
    FROM 'C:\Users\bharg\OneDrive\Desktop\SQL_Dwh_Projects\healthcare_project\data\hospital-a\departments.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2
            
    );
    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 2. bronze.hosa_providers
    -- ============================================================
    PRINT '>> Truncating Table: bronze.hosa_providers';
    TRUNCATE TABLE bronze.hosa_providers;

    PRINT '>> Inserting Table: bronze.hosa_providers';
    BULK INSERT bronze.hosa_providers
    FROM 'C:\Users\bharg\OneDrive\Desktop\SQL_Dwh_Projects\healthcare_project\data\hospital-a\providers.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2
            
    );
    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 3. bronze.hosa_patients
    -- ============================================================
    PRINT '>> Truncating Table: bronze.hosa_patients';
    TRUNCATE TABLE bronze.hosa_patients;

    PRINT '>> Inserting Table: bronze.hosa_patients';
    BULK INSERT bronze.hosa_patients
    FROM 'C:\Users\bharg\OneDrive\Desktop\SQL_Dwh_Projects\healthcare_project\data\hospital-a\patients.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2
            
    );
    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 4. bronze.hosa_encounters
    -- ============================================================
    PRINT '>> Truncating Table: bronze.hosa_encounters';
    TRUNCATE TABLE bronze.hosa_encounters;

    PRINT '>> Inserting Table: bronze.hosa_encounters';
    BULK INSERT bronze.hosa_encounters
    FROM 'C:\Users\bharg\OneDrive\Desktop\SQL_Dwh_Projects\healthcare_project\data\hospital-a\encounters.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2
            
    );
    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 5. bronze.hosa_transactions
    -- ============================================================
    PRINT '>> Truncating Table: bronze.hosa_transactions';
    TRUNCATE TABLE bronze.hosa_transactions;

    PRINT '>> Inserting Table: bronze.hosa_transactions';
    BULK INSERT bronze.hosa_transactions
    FROM 'C:\Users\bharg\OneDrive\Desktop\SQL_Dwh_Projects\healthcare_project\data\hospital-a\transactions.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2
            
    );
    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 6. bronze.hosb_departments
    -- ============================================================
    PRINT '>> Truncating Table: bronze.hosb_departments';
    TRUNCATE TABLE bronze.hosb_departments;

    PRINT '>> Inserting Table: bronze.hosb_departments';
    BULK INSERT bronze.hosb_departments
    FROM 'C:\Users\bharg\OneDrive\Desktop\SQL_Dwh_Projects\healthcare_project\data\hospital-b\departments.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2
            
    );
    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 7. bronze.hosb_providers
    -- ============================================================
    PRINT '>> Truncating Table: bronze.hosb_providers';
    TRUNCATE TABLE bronze.hosb_providers;

    PRINT '>> Inserting Table: bronze.hosb_providers';
    BULK INSERT bronze.hosb_providers
    FROM 'C:\Users\bharg\OneDrive\Desktop\SQL_Dwh_Projects\healthcare_project\data\hospital-b\providers.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2
            
    );
    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 8. bronze.hosb_patients
    --    (Hospital-B uses different column names: ID, F_Name,
    --     L_Name, M_Name, Updated_Date — handled later in silver)
    -- ============================================================
    PRINT '>> Truncating Table: bronze.hosb_patients';
    TRUNCATE TABLE bronze.hosb_patients;

    PRINT '>> Inserting Table: bronze.hosb_patients';
    BULK INSERT bronze.hosb_patients
    FROM 'C:\Users\bharg\OneDrive\Desktop\SQL_Dwh_Projects\healthcare_project\data\hospital-b\patients.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2
            
    );
    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 9. bronze.hosb_encounters
    -- ============================================================
    PRINT '>> Truncating Table: bronze.hosb_encounters';
    TRUNCATE TABLE bronze.hosb_encounters;

    PRINT '>> Inserting Table: bronze.hosb_encounters';
    BULK INSERT bronze.hosb_encounters
    FROM 'C:\Users\bharg\OneDrive\Desktop\SQL_Dwh_Projects\healthcare_project\data\hospital-b\encounters.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2
            
    );
    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 10. bronze.hosb_transactions
    -- ============================================================
    PRINT '>> Truncating Table: bronze.hosb_transactions';
    TRUNCATE TABLE bronze.hosb_transactions;

    PRINT '>> Inserting Table: bronze.hosb_transactions';
    BULK INSERT bronze.hosb_transactions
    FROM 'C:\Users\bharg\OneDrive\Desktop\SQL_Dwh_Projects\healthcare_project\data\hospital-b\transactions.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2
            
    );
    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 11. bronze.claims_hospital1
    -- ============================================================
    PRINT '>> Truncating Table: bronze.claims_hospital1';
    TRUNCATE TABLE bronze.claims_hospital1;

    PRINT '>> Inserting Table: bronze.claims_hospital1';
    BULK INSERT bronze.claims_hospital1
    FROM 'C:\Users\bharg\OneDrive\Desktop\SQL_Dwh_Projects\healthcare_project\data\claims\hospital1_claim_data.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2
            
    );
    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 12. bronze.claims_hospital2
    -- ============================================================
    PRINT '>> Truncating Table: bronze.claims_hospital2';
    TRUNCATE TABLE bronze.claims_hospital2;

    PRINT '>> Inserting Table: bronze.claims_hospital2';
    BULK INSERT bronze.claims_hospital2
    FROM 'C:\Users\bharg\OneDrive\Desktop\SQL_Dwh_Projects\healthcare_project\data\claims\hospital2_claim_data.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2
            
    );
    PRINT '>> ----------------------------------------------------------<<';


    -- ============================================================
    -- 13. bronze.cptcodes
    -- ============================================================
    PRINT '>> Truncating Table: bronze.cptcodes';
    TRUNCATE TABLE bronze.cptcodes;

    PRINT '>> Inserting Table: bronze.cptcodes';
    BULK INSERT bronze.cptcodes
    FROM 'C:\Users\bharg\OneDrive\Desktop\SQL_Dwh_Projects\healthcare_project\data\cptcodes\cptcodes.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2
            
    );
    PRINT '>> ----------------------------------------------------------<<';    
END
GO


execute bronze.load_bronze





