/*
================================================================================
 00_setup / 01_create_database.sql
 Creates the data warehouse database.
 Run this script with a connection to the [master] database.
================================================================================
*/
USE master;
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE HealthcareRCM_DWH
GO

USE HealthcareRCM_DWH;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
