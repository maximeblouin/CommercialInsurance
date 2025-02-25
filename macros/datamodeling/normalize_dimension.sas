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

    \param      i_original_dsn The input dataset to normalize.
    \param      i_primary_keys The primary key(s) of the dimension.
    \param      i_attributes The attributes in the i_original_dsn to normalize.
    \param      i_sum_attributes The attributes to sum in the i_original_dsn.
    \param      o_fact_dataset The output fact table to normalize.
    \param      o_foreign_key The foreign key to the dimension table.
    \param      o_dim_dataset The output dimension table.

    \remark     Example usage of the %normalize_dimension macro:
                <pre><code>
                %normalize_dimension(
                    i_original_dsn=FactTransactions,
                    i_primary_keys=PolicyNumber RenewalCycle,
                    i_attributes=PolicyNumber RenewalCycle PolicyType
                        PolicyStatus PolicyStartDate PolicyEndDate,
                    i_sum_attributes=TransactionAmount,
                    o_fact_dataset=FactTransactionsNormalized,
                    o_foreign_key=PolicyID,
                    o_dim_dataset=DimPolicy);
                <\pre><\code>

    \remark     The o_fact_dataset can be the same as the i_original_dsn. The
                macro will overwrite the dataset if it already exists.
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
    i_original_dsn=,
    i_primary_keys=,
    i_attributes=,
    i_sum_attributes=,
    o_fact_dataset=,
    o_foreign_key=,
    o_dim_dataset=);

    /* Section: Input Parameters Validatation */

    /* Ensure all parameters are provided. */
    %if %length(&i_original_dsn) eq 0
        or %length(&i_primary_keys) eq 0
        or %length(&i_attributes) eq 0
        or %length(&i_sum_attributes) eq 0
        or %length(&o_fact_dataset) eq 0
        or %length(&o_foreign_key) eq 0
        or %length(&o_dim_dataset) eq 0 %then %do;
        %put ERROR: Missing required parameters.;
        %abort cancel;
    %end;

    /* Check that `i_primary_keys` and `i_attributes` are valid column
        names in `i_original_dsn`. */
    %let dsid=%sysfunc(open(&i_original_dsn, i));
    %do i = 1 %to %sysfunc(countw(&i_primary_keys &i_attributes));
        %let l_col = %scan(&i_primary_keys &i_attributes, &i);
        %let l_dsncol = %sysfunc(varnum(&dsid, &l_col));
        %if &l_dsncol eq 0 %then %do;
            %put ERROR: Column &l_col not found in &i_original_dsn;
            %abort cancel;
        %end;
    %end;
    %let rc=%sysfunc(close(&dsid));

    /* Section: Dimension Table Creation */
    proc summary nway missing data=&i_original_dsn;
        class &i_primary_keys &i_attributes;
        var &i_sum_attributes.;
        output
            out=&o_dim_dataset. (drop=_type_ _freq_)
            sum=;
    run;

    /* Warns if the primary keys are not unique */
    %local l_sql_primary_keys;
    %let l_sql_primary_keys = %sysfunc(tranwrd(%sysfunc(compbl(%str(&i_primary_keys))), %str( ), %str(,)));
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
        %put WARNING: Primary keys are not unique in &o_dim_dataset;
    %end;

    /* Assign a Unique Key for the Dimension Table */
    data &o_dim_dataset;
        retain &o_foreign_key;
        set &o_dim_dataset;

        attrib &o_foreign_key.
            length=8 format=best12. informat=best12.
            label="Unique Key for Dimension Table";
        &o_foreign_key = _n_;
    run;

    /* Section: Fact Table Normalization */
    /* Add quotes to attributes and primary keys, and replace spaces with commas */
    %let l_defineKeys = %sysfunc(tranwrd(%sysfunc(compbl(%str(%'&i_primary_keys &i_attributes%'))), %str( ), %str(%',%')));
    %put Define Keys: &l_defineKeys;

    /* Remove the primary keys from the attributes list */
    %let l_remove_attributes = &i_attributes;
    %do i = 1 %to %sysfunc(countw(&i_primary_keys));
        %let l_remove_attributes = %sysfunc(tranwrd(&l_remove_attributes, %scan(&i_primary_keys, &i), ));
        %put Removed %scan(&i_primary_keys, &i) from &l_remove_attributes;
    %end;

    %put Attributes to remove: &l_remove_attributes;


    /* Join back with the Fact Table using HASH OBJECT */
    data &o_fact_dataset;
        if _n_ = 1 then do;
            declare hash dim(dataset:"&o_dim_dataset");
            dim.defineKey(&l_defineKeys);
            dim.defineData("&o_foreign_key.");
            dim.defineDone();
        end;
        set &i_original_dsn;

        attrib &o_foreign_key.
            length=8 format=best12. informat=best12.
            label="Unique Key for &o_dim_dataset. Dimension Table";

        /* Handle missing cases */
        if dim.find() ne 0 then do;
            &o_foreign_key. = .;
            put "WARNING: Foreign key not assigned for record in " _n_;
        end;

        /* Drop attributes */
        drop &l_remove_attributes;
    run;

    /* Check that all Dimension IDs are assigned */
    %let l_error = 0;
    proc sql noprint;
        select count(*) into :l_error
        from &o_fact_dataset
        where &o_foreign_key. is missing;
    quit;

    /* Log warning if foreign keys are not assigned */
    %if &l_error > 0 %then %do;
        %put WARNING: Foreign keys are not assigned in &o_fact_dataset;
    %end;

    /* Log Normalized Tables */
    %put Normalized Fact Table: &o_fact_dataset;
    %put Normalized Dimension Table: &o_dim_dataset;

%mend normalize_dimension;

/** \endcond */