
/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema
    from external CSV files.

    It performs the following actions:
    - Truncates existing Bronze tables before loading.
    - Loads CSV files using PostgreSQL COPY command.
    - Captures individual table loading durations.
    - Captures total batch loading duration.
    - Handles errors using EXCEPTION.

Tables:
    1. bronze.account_onboarding
    2. bronze.transaction_log

Parameters:
    None.

Usage Example:
    CALL bronze.load_bronze();

Note:
    Update the CSV file paths according to your environment.
    PostgreSQL server must have permission to read these files.

===============================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time         TIMESTAMPTZ;
    v_end_time           TIMESTAMPTZ;
    v_batch_start_time   TIMESTAMPTZ;
    v_batch_end_time     TIMESTAMPTZ;

    v_error_message      TEXT;
    v_error_detail       TEXT;
    v_error_hint         TEXT;
    v_error_context      TEXT;

BEGIN

    -- =========================================================
    -- START BRONZE LOAD
    -- =========================================================

    v_batch_start_time := CLOCK_TIMESTAMP();

    RAISE NOTICE '================================================';
    RAISE NOTICE '          LOADING BRONZE LAYER';
    RAISE NOTICE '================================================';

    -- =========================================================
    -- TRUNCATE BOTH TABLES
    -- =========================================================

    RAISE NOTICE 'Truncating Bronze Tables';

    TRUNCATE TABLE
        bronze.transaction_log,
        bronze.account_onboarding
    RESTART IDENTITY;

    -- =========================================================
    -- LOAD ACCOUNT ONBOARDING
    -- =========================================================

    v_start_time := CLOCK_TIMESTAMP();

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading Table: bronze.account_onboarding';
    RAISE NOTICE '------------------------------------------------';

    COPY bronze.account_onboarding (
        client_name,
        portfolio_type,
        portfolio_number,
        advisory_desk_code,
        desk_name,
        desk_location,
        initial_capital_inr,
        risk_profile,
        relationship_manager
    )
    FROM '/var/lib/postgresql/import/account_onboarding.csv'
    WITH (
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ',',
        QUOTE '"',
        ESCAPE '"'
    );

    v_end_time := CLOCK_TIMESTAMP();

    RAISE NOTICE 'Account Onboarding Load Duration: % seconds',
        ROUND(
            EXTRACT(EPOCH FROM (v_end_time - v_start_time))::NUMERIC,
            2
        );

    -- =========================================================
    -- LOAD TRANSACTION LOG
    -- =========================================================

    v_start_time := CLOCK_TIMESTAMP();

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading Table: bronze.transaction_log';
    RAISE NOTICE '------------------------------------------------';

    COPY bronze.transaction_log (
        client_name,
        portfolio_number,
        asset_symbol,
        order_side,
        quantity,
        executed_price_inr,
        currency,
        trade_timestamp,
        exchange,
        settlement_status,
        remarks
    )
    FROM '/var/lib/postgresql/import/transaction_log.csv'
    WITH (
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ',',
        QUOTE '"',
        ESCAPE '"'
    );

    v_end_time := CLOCK_TIMESTAMP();

    RAISE NOTICE 'Transaction Log Load Duration: % seconds',
        ROUND(
            EXTRACT(EPOCH FROM (v_end_time - v_start_time))::NUMERIC,
            2
        );

    -- =========================================================
    -- END BRONZE LOAD
    -- =========================================================

    v_batch_end_time := CLOCK_TIMESTAMP();

    RAISE NOTICE '================================================';
    RAISE NOTICE '     LOADING BRONZE LAYER COMPLETED';
    RAISE NOTICE '------------------------------------------------';

    RAISE NOTICE 'Total Load Duration: % seconds',
        ROUND(
            EXTRACT(EPOCH FROM (v_batch_end_time - v_batch_start_time))::NUMERIC,
            2
        );

    RAISE NOTICE '================================================';

EXCEPTION

    WHEN OTHERS THEN

        GET STACKED DIAGNOSTICS
            v_error_message = MESSAGE_TEXT,
            v_error_detail = PG_EXCEPTION_DETAIL,
            v_error_hint = PG_EXCEPTION_HINT,
            v_error_context = PG_EXCEPTION_CONTEXT;

        RAISE NOTICE '================================================';
        RAISE NOTICE 'ERROR OCCURRED DURING BRONZE LAYER LOADING';
        RAISE NOTICE 'Error Message: %', v_error_message;
        RAISE NOTICE 'Error Detail: %', v_error_detail;
        RAISE NOTICE 'Error Hint: %', v_error_hint;
        RAISE NOTICE 'Error Context: %', v_error_context;
        RAISE NOTICE '================================================';

        RAISE;

END;
$$;


-- ============================================================
-- EXECUTE STORED PROCEDURE
-- ============================================================

CALL bronze.load_bronze();
