/*
================================================================================
 03_gold / 01_create_gold_tables.sql
 Gold layer = simple star schema, built for reporting.
s   gold.dim_patient
   gold.dim_provider
   gold.dim_department
   gold.dim_cpt_code
   gold.dim_payor
   gold.fact_transactions  -- one row per charge transaction
   gold.fact_claims        -- one row per insurance claim
================================================================================
*/
USE HealthcareRCM_DWH;
GO


IF OBJECT_ID('gold.dim_department', 'U') IS NOT NULL DROP TABLE gold.dim_department;
CREATE TABLE gold.dim_department
(
    Dept_Key VARCHAR(40) NOT NULL PRIMARY KEY,
    DeptID VARCHAR(20) NOT NULL,
    Name VARCHAR(200) NULL,
    datasource VARCHAR(10) NOT NULL
);
GO

IF OBJECT_ID('gold.dim_provider', 'U') IS NOT NULL DROP TABLE gold.dim_provider;
CREATE TABLE gold.dim_provider
(
    Provider_Key VARCHAR(40) NOT NULL PRIMARY KEY,
    ProviderID VARCHAR(20) NOT NULL,
    FullName VARCHAR(210) NULL,
    Specialization VARCHAR(200) NULL,
    Dept_Key VARCHAR(40) NULL,
    datasource VARCHAR(10) NOT NULL
);
GO

IF OBJECT_ID('gold.dim_patient', 'U') IS NOT NULL DROP TABLE gold.dim_patient;
CREATE TABLE gold.dim_patient
(
    Patient_Key VARCHAR(40) NOT NULL PRIMARY KEY,
    PatientID VARCHAR(20) NOT NULL,
    FullName VARCHAR(210) NULL,
    Gender VARCHAR(20) NULL,
    DOB DATE NULL,
    Age INT,
    datasource VARCHAR(10) NOT NULL
);
GO

IF OBJECT_ID('gold.dim_cpt_code', 'U') IS NOT NULL DROP TABLE gold.dim_cpt_code;
CREATE TABLE gold.dim_cpt_code
(
    CPT_Code VARCHAR(20) NOT NULL PRIMARY KEY,
    Category VARCHAR(20) NULL,
    Description VARCHAR(1000) NULL
);
GO

IF OBJECT_ID('gold.dim_payor', 'U') IS NOT NULL DROP TABLE gold.dim_payor;
CREATE TABLE gold.dim_payor
(
    Payor_Key VARCHAR(60) NOT NULL PRIMARY KEY,
    PayorID VARCHAR(50) NOT NULL,
    PayorType VARCHAR(50) NULL
);
GO

IF OBJECT_ID('gold.fact_transactions', 'U') IS NOT NULL DROP TABLE gold.fact_transactions;
CREATE TABLE gold.fact_transactions
(
    Transaction_Key VARCHAR(40) NOT NULL PRIMARY KEY,
    FK_Patient_Key VARCHAR(40) NULL,
    FK_Provider_Key VARCHAR(40) NULL,
    FK_Dept_Key VARCHAR(40) NULL,
    FK_CPT_Code VARCHAR(20) NULL,
    FK_ServiceDate_Key INT NULL,
    ServiceDate DATE NULL,
    ChargeAmount DECIMAL(12,2) NULL,
    PaidAmount DECIMAL(12,2) NULL,
    OutstandingAmount DECIMAL(12,2) NULL,
    datasource VARCHAR(10) NOT NULL
);
GO

IF OBJECT_ID('gold.fact_claims', 'U') IS NOT NULL DROP TABLE gold.fact_claims;
CREATE TABLE gold.fact_claims
(
    Claim_Key VARCHAR(40) NOT NULL PRIMARY KEY,
    FK_Patient_Key VARCHAR(40) NULL,
    FK_Payor_Key VARCHAR(60) NULL,
    FK_ServiceDate_Key INT NULL,
    ClaimAmount DECIMAL(12,2) NULL,
    PaidAmount DECIMAL(12,2) NULL,
    ClaimStatus VARCHAR(50) NULL,
    datasource VARCHAR(10) NOT NULL
);
GO
