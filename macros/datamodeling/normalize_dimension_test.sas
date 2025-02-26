/**
    \file
    \ingroup    DATAMODELING_TEST
    \author     Maxime Blouin
    \date       29JAN2025
    \brief      Tests for normalize_dimension.sas
    \details    This file contains test scenarios for the
                normalize_dimension macro.
    \remark     Test scenarios should cover the following cases:
*/ /** \cond */

%macro test_normalize_dimension();

    %put Running tests for normalize_dimension macro...;

    %put Test 1: Testing basic normalization;

    proc sql;
        create table test.FactTransactions1 (
            TransactionID num,
            PolicyNumber char(10),
            RiskNumber num,
            RenewalCycle num,
            PolicyType char(10),
            PolicyStatus char(10),
            PolicyStartDate date format=date9.,
            PolicyEndDate date format=date9.,
            TransactionAmount num
        );

        insert into test.FactTransactions1
        values (0, 'Policy123', 1, 1, 'Auto', 'Active', '01JAN2025'd, '31DEC2025'd, 100)
        values (1, 'Policy123', 1, 1, 'Auto', 'Active', '01JAN2025'd, '31DEC2025'd, 200)
        values (2, 'Policy456', 2, 1, 'Home', 'Inactive', '01JAN2025'd, '31DEC2025'd, 300)
        values (3, 'Policy789', 3, 1, 'Corpo', 'Active', '01JAN2025'd, '31DEC2025'd, 400)
        values (4, 'Policy123', 1, 2, 'Auto', 'Active', '01JAN2025'd, '31DEC2025'd, 150)
        values (5, 'Policy456', 2, 2, 'Home', 'Inactive', '01JAN2025'd, '31DEC2025'd, 600)
        values (6, 'Policy789', 3, 2, 'Corpo', 'Active', '01JAN2025'd, '31DEC2025'd, 700)
        values (7, 'Policy123', 1, 3, 'Auto', 'Active', '01JAN2025'd, '31DEC2025'd, 200)
        values (8, 'Policy456', 2, 3, 'Home', 'Inactive', '01JAN2025'd, '31DEC2025'd, 300)
        values (9, 'Policy789', 3, 3, 'Corpo', 'Active', '01JAN2025'd, '31DEC2025'd, 150);
    quit;

    %normalize_dimension(
        io_fact_dsn=test.FactTransactions1,
        i_primary_keys=PolicyNumber RenewalCycle,
        i_attributes=PolicyType PolicyStatus PolicyStartDate PolicyEndDate,
        i_sum_attributes=TransactionAmount,
        o_foreign_key=PolicyID,
        o_dim_dataset=test.DimPolicy);

    /* Validate that Primary Keys are Unique in Dimension Table */
    proc sql;
        select count(*) into :dim_count from test.DimPolicy;
        select count(distinct PolicyID) into :dim_distinct from test.DimPolicy;
    quit;

    %if &dim_count ne &dim_distinct %then %do;
        %put ERROR: Duplicate PolicyID found in Dimension Table;
    %end;

    /* Validate that Primary Keys are in Fact Table */
    proc sql;
        select count(*) into :pk_missing
        from test.FactTransactions1
        where PolicyNumber is missing or RenewalCycle is missing;
    quit;

    %if &pk_missing > 0 %then %do;
        %put ERROR: Missing primary keys in Fact Table;
    %end;

    /* Validate that Foreign Keys are in Fact Table */
    proc sql;
        select count(*) into :fk_missing
        from test.FactTransactions1
        where PolicyID is missing;
    quit;

    %if &fk_missing > 0 %then %do;
        %put ERROR: Missing foreign keys in Fact Table;
    %end;

    %put Tests completed.;


    %put Test 2: Testing o_where parameter;

    proc sql;
        create table test.FactTransactions2 (
            TransactionID num,
            PolicyNumber char(10),
            RiskNumber num,
            RenewalCycle num,
            PolicyType char(10),
            PolicyStatus char(10),
            PolicyStartDate date format=date9.,
            PolicyEndDate date format=date9.,
            TransactionAmount num,
            AmountType char(10)
        );

        insert into test.FactTransactions2
        values (0, 'Policy123', 1, 1, 'Auto', 'Active', '01JAN2025'd, '31DEC2025'd, 100, 'Premium')
        values (1, 'Policy123', 1, 1, 'Auto', 'Active', '01JAN2025'd, '31DEC2025'd, 200, 'Premium')
        values (2, 'Policy456', 2, 1, 'Home', 'Inactive', '01JAN2025'd, '31DEC2025'd, 300, 'Premium')
        values (3, 'Policy789', 3, 1, 'Corpo', 'Active', '01JAN2025'd, '31DEC2025'd, 400, 'Premium')
        values (4, 'Policy123', 1, 2, 'Auto', 'Active', '01JAN2025'd, '31DEC2025'd, 150, 'Premium')
        values (5, 'Policy456', 2, 2, 'Home', 'Inactive', '01JAN2025'd, '31DEC2025'd, 600, 'Premium')
        values (6, 'Policy789', 3, 2, 'Corpo', 'Active', '01JAN2025'd, '31DEC2025'd, 700, 'Premium')
        values (7, 'Policy123', 1, 3, 'Auto', 'Active', '01JAN2025'd, '31DEC2025'd, 200, 'Premium')
        values (8, 'Policy456', 2, 3, 'Home', 'Inactive', '01JAN2025'd, '31DEC2025'd, 300, 'Premium')
        values (9, 'Policy789', 3, 3, 'Corpo', 'Active', '01JAN2025'd, '31DEC2025'd, 150, 'Premium')
        values (10, 'Policy123', 1, 1, 'Auto', 'Active', '01JAN2025'd, '31DEC2025'd, 100, 'Fee')
        values (11, 'Policy123', 1, 1, 'Auto', 'Active', '01JAN2025'd, '31DEC2025'd, 200, 'Fee')
        values (12, 'Policy456', 2, 1, 'Home', 'Inactive', '01JAN2025'd, '31DEC2025'd, 300, 'Fee')
        values (13, 'Policy789', 3, 1, 'Corpo', 'Active', '01JAN2025'd, '31DEC2025'd, 400, 'Fee')
        values (14, 'Policy123', 1, 2, 'Auto', 'Active', '01JAN2025'd, '31DEC2025'd, 150, 'Fee')
        values (15, 'Policy456', 2, 2, 'Home', 'Inactive', '01JAN2025'd, '31DEC2025'd, 600, 'Fee')
        values (16, 'Policy789', 3, 2, 'Corpo', 'Active', '01JAN2025'd, '31DEC2025'd, 700, 'Fee')
        values (17, 'Policy123', 1, 3, 'Auto', 'Active', '01JAN2025'd, '31DEC2025'd, 200, 'Fee')
        values (18, 'Policy456', 2, 3, 'Home', 'Inactive', '01JAN2025'd, '31DEC2025'd, 300, 'Fee')
        values (19, 'Policy789', 3, 3, 'Corpo', 'Active', '01JAN2025'd, '31DEC2025'd, 150, 'Fee');
    quit;

    %normalize_dimension(
        io_fact_dsn=test.FactTransactions2,
        i_primary_keys=PolicyNumber RenewalCycle,
        i_attributes=PolicyType PolicyStatus PolicyStartDate PolicyEndDate,
        i_sum_attributes=TransactionAmount,
        o_where=AmountType eq 'Premium',
        o_foreign_key=PolicyID,
        o_dim_dataset=test.DimPolicy2);

    /* Validate that only Premium records are in Dimension Table */
    proc sql;
        select count(*) into :dim_count_premium from test.DimPolicy2;
    quit;

    %if &dim_count_premium ne 9 %then %do;
        %put ERROR: Dimension Table does not contain only Premium records;
    %end;

    %put Tests completed.;
%mend test_normalize_dimension;

%test_normalize_dimension();
/** \endcond */