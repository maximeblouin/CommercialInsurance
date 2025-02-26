/**
    \file
    \ingroup    DATAMODELING
    \author     Maxime Blouin
    \date       29JAN2025
    \brief      Macro to normalize the dimension of a dataset.
    \details    This macro normalizes the dimension of a large dataset by
                removing redundant data and improving data integrity.

                SAS macro sections:
                - Input Parameters Validation
                - Dimension Table Creation
                - Fact Table Normalization
                - Summary Statistics

    \param      io_fact_dsn The fact fact table to normalize.
    \param      i_primary_keys The primary key(s) of the dimension.
    \param      i_attributes The attributes in the io_fact_dsn to normalize.
    \param      i_sum_attributes The attributes to sum in the io_fact_dsn. (optional)
    \param      o_where The where clause to filter the fact table. (optional)
    \param      o_foreign_key The foreign key to the dimension table.
    \param      o_dim_dataset The output dimension table.

    \remark     Example usage of the %normalize_dimension macro:
                <pre><code>
                %normalize_dimension(
                    io_fact_dsn=model.FactTransactions,
                    i_primary_keys=PolicyNumber RenewalCycle,
                    i_attributes=PolicyType PolicyStatus PolicyStartDate
                        PolicyEndDate,
                    i_sum_attributes=TransactionAmount,
                    o_where=AmountType='Premium',
                    o_foreign_key=PolicyID,
                    o_dim_dataset=model.DimPolicy);
                <\pre><\code>

    \remark     The dimension will be normalized based on the primary keys and
                attributes provided. The primary keys will be kept in the
                fact table because they may be needed to normalize other
                dimensions. They should be removed manually if needed.
    \remark     Error handling includes checks for missing parameters and
                invalid column names.
    \remark     Warnings are logged if primary keys are not unique or if
                foreign keys are not assigned in the fact table.
    \return     Returns the normalized fact and dimension datasets.
*/ /** \cond */

%macro normalize_dimension(
    io_fact_dsn=,
    i_primary_keys=,
    i_attributes=,
    i_sum_attributes=,
    o_where=1,
    o_foreign_key=,
    o_dim_dataset=);

    /* Section: Input Parameters Validatation */

    /* Ensure all parameters are provided. */
    %if %length(&io_fact_dsn) eq 0
        or %length(&i_primary_keys) eq 0
        or %length(&i_attributes) eq 0
        or %length(&o_foreign_key) eq 0
        or %length(&o_dim_dataset) eq 0 %then %do;
        %put ERROR: Missing required parameters.;
        %abort cancel;
    %end;

    /* Check that `i_primary_keys` and `i_attributes` are valid column
        names in `io_fact_dsn`. */
    %let dsid=%sysfunc(open(&io_fact_dsn, i));
    %do i = 1 %to %sysfunc(countw(&i_primary_keys &i_attributes &i_sum_attributes));
        %let l_col = %scan(&i_primary_keys &i_attributes &i_sum_attributes, &i);
        %let l_dsncol = %sysfunc(varnum(&dsid, &l_col));
        %if &l_dsncol eq 0 %then %do;
            %put ERROR: Column &l_col not found in &io_fact_dsn..;
            %abort cancel;
        %end;
    %end;
    %let rc=%sysfunc(close(&dsid));

    /* Check that `o_foreign_key` is not in `io_original_dsn` */
    %let dsid=%sysfunc(open(&io_fact_dsn, i));
    %let l_dsncol = %sysfunc(varnum(&dsid, &o_foreign_key));
    %if &l_dsncol ne 0 %then %do;
        %put ERROR: Column &o_foreign_key already exists in &io_fact_dsn..;
        %abort cancel;
    %end;
    %let rc=%sysfunc(close(&dsid));

    /* Section: Dimension Table Creation */
    data &o_dim_dataset;
        set &io_fact_dsn;
        keep &i_primary_keys &i_attributes &i_sum_attributes;
        if &o_where;
    run;

    %if %length(&i_sum_attributes) eq 0 %then %do;
        /* Create the Dimension Table without summary statistics */
        proc sort nodupkey data=&o_dim_dataset;
            by _ALL_;
        run;
    %end;
    %else %do;
        /* Create the Dimension Table with summary statistics */
        proc summary nway missing
            data=&o_dim_dataset;
            class &i_primary_keys &i_attributes;
            var &i_sum_attributes;
            output
                out=&o_dim_dataset (drop=_type_ _freq_)
                sum=;
        run;
    %end;

    /* Warns if the primary keys are not unique */
    %local l_sql_primary_keys;
    %let l_sql_primary_keys=%sysfunc(tranwrd(%sysfunc(compbl(%str(&i_primary_keys))), %str( ), %str(,)));
    %put &=l_sql_primary_keys;

    %let l_error = 0;
    proc sql noprint;
        select count(*) into :l_error
        from (
            select &l_sql_primary_keys, count(*) as count
            from &o_dim_dataset
            group by &l_sql_primary_keys
            having count(*) > 1);
    quit;

    /* Log warning if primary keys are not unique */
    %if &l_error > 0 %then %do;
        %put WARNING: Primary keys are not unique in &o_dim_dataset..;
    %end;

    /* Assign a Unique Key for the Dimension Table */
    data &o_dim_dataset;
        retain &o_foreign_key;
        set &o_dim_dataset;

        attrib &o_foreign_key
            length=8 format=best12. informat=best12.
            label="Unique Key for Dimension Table";
        &o_foreign_key = _n_;
    run;

    /* Section: Adds Foreign Key to Fact Table */
    /* Add single quotes to attributes and primary keys, and replace spaces with commas. */
    %let l_defineKeys = %sysfunc(tranwrd(%sysfunc(compbl(%str(%'&i_primary_keys &i_attributes%'))), %str( ), %str(%',%')));

    /* Join back with the Fact Table using HASH OBJECT */
    data &io_fact_dsn;
        if _n_ = 1 then do;
            declare hash dim(dataset:"&o_dim_dataset");
            dim.defineKey(&l_defineKeys);
            dim.defineData("&o_foreign_key.");
            dim.defineDone();
        end;
        set &io_fact_dsn;

        attrib &o_foreign_key
            length=8 format=best12. informat=best12.
            label="Unique Key for &o_dim_dataset. dimension table";

        /* Handle missing cases */
        if dim.find() ne 0 then do;
            &o_foreign_key = .;
            %if %str(&o_where) eq %str(1) %then %do;
                put "WARNING: Foreign key not assigned for record in " _n_;
            %end;
        end;
    run;

    /* Set column order in the dimension dataset. */
    data &o_dim_dataset;
        retain &o_foreign_key &i_primary_keys &i_attributes &i_sum_attributes;
        set &o_dim_dataset;
    run;

    /* Check that all dimension IDs are assigned. */
    %let l_error = 0;
    proc sql noprint;
        select count(*) into :l_error
        from &io_fact_dsn
        where &o_foreign_key is missing and &o_where;
    quit;

    /* Log warning if foreign keys are not assigned. */
    %if &l_error > 0 %then %do;
        %put WARNING: Foreign keys are not assigned in &io_fact_dsn;
    %end;

    /* Log Normalized Tables */
    %put Normalization Information;
    %put Fact Table: &io_fact_dsn;
    %put Dimension Table: &o_dim_dataset;
    %put Primary Keys: &i_primary_keys;
    %put Attributes: &i_attributes;
    %put Foreign Key: &o_foreign_key;
    %put Where Clause: &o_where;
    %put Sum Attributes: &i_sum_attributes;

%mend normalize_dimension;

/** \endcond */