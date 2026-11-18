

/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse'
    after checking if it already exists.

    If the database exists, it is dropped and recreated.
    Additionally, it creates three schemas:
    'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will DROP the entire DataWarehouse
    database if it exists.

    All data will be permanently deleted.
    Ensure proper backups before execution.
*/

-- Step 1: Connect to the default maintenance database
-- Execute this script while connected to postgres.

-- Step 2: Drop the database if it already exists
DROP DATABASE IF EXISTS "DataWarehouse" WITH (FORCE);

-- Step 3: Create the database
CREATE DATABASE "DataWarehouse";

-- Step 4: Connect to the newly created database
-- Run this separately in psql:
\c "DataWarehouse"

-- Step 5: Create schemas
CREATE SCHEMA bronze;

CREATE SCHEMA silver;

CREATE SCHEMA gold;

-- Step 6: Verify schemas
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('bronze', 'silver', 'gold')
ORDER BY schema_name;
