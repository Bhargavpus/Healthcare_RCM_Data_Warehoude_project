
USE HealthcareRCM_DWH;
GO

IF OBJECT_ID('silver.departments', 'U') IS NOT NULL 
    DROP TABLE silver.departments;

CREATE TABLE silver.departments
(
    DeptID      VARCHAR(20)  NOT NULL,
    Name        VARCHAR(200) NULL,
    datasource  VARCHAR(10)  NOT NULL
);
GO

IF OBJECT_ID('silver.providers', 'U') IS NOT NULL 
    DROP TABLE silver.providers;

CREATE TABLE silver.providers
(
    ProviderID      VARCHAR(20)  NOT NULL,
    FirstName       VARCHAR(100) NULL,
    LastName        VARCHAR(100) NULL,
    Specialization  VARCHAR(200) NULL,
    DeptID          VARCHAR(20)  NULL,
    NPI             BIGINT       NULL,
    datasource      VARCHAR(10)  NOT NULL
);
GO

IF OBJECT_ID('silver.patients', 'U') IS NOT NULL 
    DROP TABLE silver.patients;

CREATE TABLE silver.patients
(
    PatientID       VARCHAR(20)  NOT NULL,
    FirstName       VARCHAR(100) NULL,
    LastName        VARCHAR(100) NULL,
    MiddleName      VARCHAR(50)  NULL,
    SSN             VARCHAR(20)  NULL,
    PhoneNumber     VARCHAR(50)  NULL,
    Gender          VARCHAR(20)  NULL,
    DOB             DATE         NULL,
    Address         VARCHAR(300) NULL,
    ModifiedDate    DATE         NULL,
    datasource      VARCHAR(10)  NOT NULL
);
GO

IF OBJECT_ID('silver.encounters', 'U') IS NOT NULL 
    DROP TABLE silver.encounters;

CREATE TABLE silver.encounters
(
    EncounterID     VARCHAR(20)  NOT NULL,
    PatientID       VARCHAR(20)  NULL,
    EncounterDate   DATE         NULL,
    EncounterType   VARCHAR(50)  NULL,
    ProviderID      VARCHAR(20)  NULL,
    DepartmentID    VARCHAR(20)  NULL,
    ProcedureCode   VARCHAR(20)  NULL,
    InsertedDate    DATE         NULL,
    ModifiedDate    DATE         NULL,
    datasource      VARCHAR(10)  NOT NULL
);
GO

IF OBJECT_ID('silver.transactions', 'U') IS NOT NULL 
    DROP TABLE silver.transactions;

CREATE TABLE silver.transactions
(
    TransactionID   VARCHAR(20)   NOT NULL,
    EncounterID     VARCHAR(20)   NULL,
    PatientID       VARCHAR(20)   NULL,
    ProviderID      VARCHAR(20)   NULL,
    DeptID          VARCHAR(20)   NULL,
    VisitDate       DATE          NULL,
    ServiceDate     DATE          NULL,
    PaidDate        DATE          NULL,
    VisitType       VARCHAR(50)   NULL,
    Amount          DECIMAL(12,2) NULL,
    AmountType      VARCHAR(50)   NULL,
    PaidAmount      DECIMAL(12,2) NULL,
    ClaimID         VARCHAR(20)   NULL,
    PayorID         VARCHAR(20)   NULL,
    ProcedureCode   VARCHAR(20)   NULL,
    ICDCode         VARCHAR(20)   NULL,
    LineOfBusiness  VARCHAR(50)   NULL,
    MedicaidID      VARCHAR(20)   NULL,
    MedicareID      VARCHAR(20)   NULL,
    InsertDate      DATE          NULL,
    ModifiedDate    DATE          NULL,
    datasource      VARCHAR(10)   NOT NULL
);
GO

IF OBJECT_ID('silver.claims', 'U') IS NOT NULL 
    DROP TABLE silver.claims;

CREATE TABLE silver.claims
(
    ClaimID         VARCHAR(20)   NOT NULL,
    TransactionID   VARCHAR(20)   NULL,
    PatientID       VARCHAR(20)   NULL,
    EncounterID     VARCHAR(20)   NULL,
    ProviderID      VARCHAR(20)   NULL,
    DeptID          VARCHAR(20)   NULL,
    ServiceDate     DATE          NULL,
    ClaimDate       DATE          NULL,
    PayorID         VARCHAR(50)   NULL,
    ClaimAmount     DECIMAL(12,2) NULL,
    PaidAmount      DECIMAL(12,2) NULL,
    ClaimStatus     VARCHAR(50)   NULL,
    PayorType       VARCHAR(50)   NULL,
    Deductible      DECIMAL(12,2) NULL,
    Coinsurance     DECIMAL(12,2) NULL,
    Copay           DECIMAL(12,2) NULL,
    InsertDate      DATE          NULL,
    ModifiedDate    DATE          NULL,
    datasource      VARCHAR(10)   NOT NULL
);
GO

IF OBJECT_ID('silver.cptcodes', 'U') IS NOT NULL 
    DROP TABLE silver.cptcodes;

CREATE TABLE silver.cptcodes
(
    CPT_Code                    VARCHAR(20)   NOT NULL,
    Procedure_Code_Category     VARCHAR(20)   NULL,
    Procedure_Code_Description  VARCHAR(1000) NULL,
    Code_Status                 VARCHAR(50)   NULL
);
GO
