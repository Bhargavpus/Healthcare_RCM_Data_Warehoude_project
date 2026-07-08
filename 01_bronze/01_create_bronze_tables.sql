
USE HealthcareRCM_DWH;
GO

----------------------------------------------------------------------
-- Hospital A (EMR)
----------------------------------------------------------------------
IF OBJECT_ID('bronze.hosa_departments', 'U') IS NOT NULL 
    DROP TABLE bronze.hosa_departments;

CREATE TABLE bronze.hosa_departments
(
    DeptID          VARCHAR(20),
    Name            VARCHAR(200),
    
);
GO

IF OBJECT_ID('bronze.hosa_providers', 'U') IS NOT NULL 
    DROP TABLE bronze.hosa_providers;

CREATE TABLE bronze.hosa_providers
(
    ProviderID      VARCHAR(20),
    FirstName       VARCHAR(100),
    LastName        VARCHAR(100),
    Specialization  VARCHAR(200),
    DeptID          VARCHAR(20),
    NPI             VARCHAR(20),
    
);
GO

IF OBJECT_ID('bronze.hosa_patients', 'U') IS NOT NULL 
    DROP TABLE bronze.hosa_patients;

CREATE TABLE bronze.hosa_patients
(
    PatientID       VARCHAR(20),
    FirstName       VARCHAR(100),
    LastName        VARCHAR(100),
    MiddleName      VARCHAR(50),
    SSN             VARCHAR(20),
    PhoneNumber     VARCHAR(50),
    Gender          VARCHAR(20),
    DOB             VARCHAR(20),
    Address         VARCHAR(300),
    ModifiedDate    VARCHAR(30),
    
);
GO

IF OBJECT_ID('bronze.hosa_encounters', 'U') IS NOT NULL 
    DROP TABLE bronze.hosa_encounters;

CREATE TABLE bronze.hosa_encounters
(
    EncounterID     VARCHAR(20),
    PatientID       VARCHAR(20),
    EncounterDate   VARCHAR(30),
    EncounterType   VARCHAR(50),
    ProviderID      VARCHAR(20),
    DepartmentID    VARCHAR(20),
    ProcedureCode   VARCHAR(20),
    InsertedDate    VARCHAR(30),
    ModifiedDate    VARCHAR(30),
    
);
GO

IF OBJECT_ID('bronze.hosa_transactions', 'U') IS NOT NULL 
    DROP TABLE bronze.hosa_transactions;

CREATE TABLE bronze.hosa_transactions
(
    TransactionID   VARCHAR(20),
    EncounterID     VARCHAR(20),
    PatientID       VARCHAR(20),
    ProviderID      VARCHAR(20),
    DeptID          VARCHAR(20),
    VisitDate       VARCHAR(30),
    ServiceDate     VARCHAR(30),
    PaidDate        VARCHAR(30),
    VisitType       VARCHAR(50),
    Amount          VARCHAR(30),
    AmountType      VARCHAR(50),
    PaidAmount      VARCHAR(30),
    ClaimID         VARCHAR(20),
    PayorID         VARCHAR(20),
    ProcedureCode   VARCHAR(20),
    ICDCode         VARCHAR(20),
    LineOfBusiness  VARCHAR(50),
    MedicaidID      VARCHAR(20),
    MedicareID      VARCHAR(20),
    InsertDate      VARCHAR(30),
    ModifiedDate    VARCHAR(30),
    
);
GO

----------------------------------------------------------------------
-- Hospital B (EMR) - note the different column names from source!
----------------------------------------------------------------------
IF OBJECT_ID('bronze.hosb_departments', 'U') IS NOT NULL 
    DROP TABLE bronze.hosb_departments;

CREATE TABLE bronze.hosb_departments
(
    DeptID          VARCHAR(20),
    Name            VARCHAR(200),
    
);
GO

IF OBJECT_ID('bronze.hosb_providers', 'U') IS NOT NULL 
    DROP TABLE bronze.hosb_providers;

CREATE TABLE bronze.hosb_providers
(
    ProviderID      VARCHAR(20),
    FirstName       VARCHAR(100),
    LastName        VARCHAR(100),
    Specialization  VARCHAR(200),
    DeptID          VARCHAR(20),
    NPI             VARCHAR(20),
    
);
GO

IF OBJECT_ID('bronze.hosb_patients', 'U') IS NOT NULL 
    DROP TABLE bronze.hosb_patients;

CREATE TABLE bronze.hosb_patients
(
    ID              VARCHAR(20),
    F_Name          VARCHAR(100),
    L_Name          VARCHAR(100),
    M_Name          VARCHAR(50),
    SSN             VARCHAR(20),
    PhoneNumber     VARCHAR(50),
    Gender          VARCHAR(20),
    DOB             VARCHAR(20),
    Address         VARCHAR(300),
    Updated_Date    VARCHAR(30),
    
);
GO

IF OBJECT_ID('bronze.hosb_encounters', 'U') IS NOT NULL 
    DROP TABLE bronze.hosb_encounters;

CREATE TABLE bronze.hosb_encounters
(
    EncounterID     VARCHAR(20),
    PatientID       VARCHAR(20),
    EncounterDate   VARCHAR(30),
    EncounterType   VARCHAR(50),
    ProviderID      VARCHAR(20),
    DepartmentID    VARCHAR(20),
    ProcedureCode   VARCHAR(20),
    InsertedDate    VARCHAR(30),
    ModifiedDate    VARCHAR(30),
    
);
GO

IF OBJECT_ID('bronze.hosb_transactions', 'U') IS NOT NULL 
    DROP TABLE bronze.hosb_transactions;

CREATE TABLE bronze.hosb_transactions
(
    TransactionID   VARCHAR(20),
    EncounterID     VARCHAR(20),
    PatientID       VARCHAR(20),
    ProviderID      VARCHAR(20),
    DeptID          VARCHAR(20),
    VisitDate       VARCHAR(30),
    ServiceDate     VARCHAR(30),
    PaidDate        VARCHAR(30),
    VisitType       VARCHAR(50),
    Amount          VARCHAR(30),
    AmountType      VARCHAR(50),
    PaidAmount      VARCHAR(30),
    ClaimID         VARCHAR(20),
    PayorID         VARCHAR(20),
    ProcedureCode   VARCHAR(20),
    ICDCode         VARCHAR(20),
    LineOfBusiness  VARCHAR(50),
    MedicaidID      VARCHAR(20),
    MedicareID      VARCHAR(20),
    InsertDate      VARCHAR(30),
    ModifiedDate    VARCHAR(30),
    
);
GO

----------------------------------------------------------------------
-- Claims (one extract per hospital)
----------------------------------------------------------------------
IF OBJECT_ID('bronze.claims_hospital1', 'U') IS NOT NULL 
    DROP TABLE bronze.claims_hospital1;

CREATE TABLE bronze.claims_hospital1
(
    ClaimID         VARCHAR(20),
    TransactionID   VARCHAR(20),
    PatientID       VARCHAR(20),
    EncounterID     VARCHAR(20),
    ProviderID      VARCHAR(20),
    DeptID          VARCHAR(20),
    ServiceDate     VARCHAR(30),
    ClaimDate       VARCHAR(30),
    PayorID         VARCHAR(50),
    ClaimAmount     VARCHAR(30),
    PaidAmount      VARCHAR(30),
    ClaimStatus     VARCHAR(50),
    PayorType       VARCHAR(50),
    Deductible      VARCHAR(30),
    Coinsurance     VARCHAR(30),
    Copay           VARCHAR(30),
    InsertDate      VARCHAR(30),
    ModifiedDate    VARCHAR(30),
    
);
GO

IF OBJECT_ID('bronze.claims_hospital2', 'U') IS NOT NULL 
DROP TABLE bronze.claims_hospital2;

CREATE TABLE bronze.claims_hospital2
(
    ClaimID         VARCHAR(20),
    TransactionID   VARCHAR(20),
    PatientID       VARCHAR(20),
    EncounterID     VARCHAR(20),
    ProviderID      VARCHAR(20),
    DeptID          VARCHAR(20),
    ServiceDate     VARCHAR(30),
    ClaimDate       VARCHAR(30),
    PayorID         VARCHAR(50),
    ClaimAmount     VARCHAR(30),
    PaidAmount      VARCHAR(30),
    ClaimStatus     VARCHAR(50),
    PayorType       VARCHAR(50),
    Deductible      VARCHAR(30),
    Coinsurance     VARCHAR(30),
    Copay           VARCHAR(30),
    InsertDate      VARCHAR(30),
    ModifiedDate    VARCHAR(30),
    
);
GO

----------------------------------------------------------------------
-- CPT reference codes
----------------------------------------------------------------------
IF OBJECT_ID('bronze.cptcodes', 'U') IS NOT NULL 
    DROP TABLE bronze.cptcodes;

CREATE TABLE bronze.cptcodes
(
    Procedure_Code_Category    VARCHAR(20),
    CPT_Code                   VARCHAR(20),
    Procedure_Code_Description VARCHAR(1000),
    Code_Status                VARCHAR(50),
    
);
GO


