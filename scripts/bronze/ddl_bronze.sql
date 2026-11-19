
/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema.

    If the tables already exist, they will be dropped and recreated.

    Tables:
        1. bronze.account_onboarding
        2. bronze.transaction_log

WARNING:
    Existing tables and their data will be permanently deleted.
===============================================================================
*/


-- ============================================================================
-- 1. Create Bronze Schema
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS bronze;


-- ============================================================================
-- 2. Drop Existing Tables
-- ============================================================================

DROP TABLE IF EXISTS bronze.transaction_log;
DROP TABLE IF EXISTS bronze.account_onboarding;


-- ============================================================================
-- 3. Create Account Onboarding Table
-- ============================================================================


CREATE TABLE bronze.account_onboarding (
    s_no BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_name VARCHAR(150) NOT NULL,
    portfolio_type VARCHAR(50) NOT NULL,
    portfolio_number VARCHAR(30) UNIQUE NOT NULL,
    advisory_desk_code VARCHAR(20) NOT NULL,
    desk_name VARCHAR(100),
    desk_location VARCHAR(150),
    initial_capital_inr NUMERIC(15, 2) NOT NULL
        CHECK (initial_capital_inr >= 0),
    risk_profile VARCHAR(20) NOT NULL
        CHECK (risk_profile IN ('Low', 'Moderate', 'High', 'Very High')),
    relationship_manager VARCHAR(150) NOT NULL
);

-- ============================================================================
-- 4. Create Transaction Log Table
-- ============================================================================

CREATE TABLE bronze.transaction_log (
    trade_ref_no BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_name VARCHAR(150) NOT NULL,
    portfolio_number VARCHAR(30) NOT NULL,
    asset_symbol VARCHAR(20) NOT NULL,
    order_side VARCHAR(10) NOT NULL
        CHECK (order_side IN ('BUY', 'SELL')),
    quantity NUMERIC(15, 4) NOT NULL
        CHECK (quantity > 0),
    executed_price_inr NUMERIC(15, 2) NOT NULL
        CHECK (executed_price_inr >= 0),
    currency CHAR(3) NOT NULL DEFAULT 'INR',
    trade_timestamp TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    exchange VARCHAR(50) NOT NULL,
    settlement_status VARCHAR(20) NOT NULL
        CHECK (settlement_status IN ('PENDING', 'SETTLED', 'FAILED')),
    remarks TEXT,

    CONSTRAINT fk_transaction_portfolio
        FOREIGN KEY (portfolio_number)
        REFERENCES bronze.account_onboarding (portfolio_number)
);



-- ============================================================================
-- 5. Verify Created Tables
-- ============================================================================

SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'bronze'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;


-- ============================================================================
-- END OF SCRIPT
-- ============================================================================
