/**
    \file
    \ingroup    HELPERS
    \brief      Compare a numeric variable between two datasets for each class or
                class combination.
    \author     Maxime Blouin
    \date       31OCT2025
    \parm       i_dsn_base     Base dataset name (e.g., WORK.ds1)
    \parm       i_dsn_compare  Comparison dataset name (e.g., WORK.ds2)
    \parm       i_classes      One or more class variables (categorical or numeric)
    \parm       i_variable     Numeric variable to compare (must exist in both datasets)
    \parm       i_threshold    p-value significance threshold (default=0.05)
    \parm       out            Output dataset for summary results (default=compare_results)

    \details
        This macro compares a numeric variable between two datasets for each
        class or class combination. It performs t-tests and outputs classes
        with statistically significant differences.

        Steps:
        1. Validate datasets and variable existence.
        2. Combine datasets with _source_ indicator.
        3. Build concatenated _class_key_ for multiple class variables.
        4. Compute means and std dev for each class × dataset.
        5. Perform t-tests by class combination.
        6. Merge statistics and output classes with significant differences.
**/ /** \cond */

%macro compare_numeric_by_classes(
    i_dsn_base=,
    i_dsn_compare=,
    i_classes=,
    i_variable=,
    i_threshold=0.05,
    out=compare_results
);
    %local _errflag_ _missing_ _nmiss;
    %let _errflag_=0;

    /*===============================================================
      1. Validate datasets
    ===============================================================*/
    %if %sysfunc(exist(&i_dsn_base))=0 %then %do;
        %put ERROR: Dataset &i_dsn_base does not exist.;
        %let _errflag_=1;
    %end;
    %if %sysfunc(exist(&i_dsn_compare))=0 %then %do;
        %put ERROR: Dataset &i_dsn_compare does not exist.;
        %let _errflag_=1;
    %end;
    %if &_errflag_=1 %then %return;

    /*===============================================================
      2. Validate variable presence
    ===============================================================*/
    proc contents data=&i_dsn_base out=_vars_base(keep=name) noprint;
    proc contents data=&i_dsn_compare out=_vars_comp(keep=name) noprint;
    run;

    data _vars_check;
        merge _vars_base(in=a) _vars_comp(in=b);
        by name;
        if upcase(name)="%upcase(&i_variable)" and not (a and b) then call symputx('_missing_',1);
    run;

    %if &_missing_=1 %then %do;
        %put ERROR: Variable &i_variable must exist in both datasets.;
        %return;
    %end;

    /*===============================================================
      3. Combine datasets with source flag
    ===============================================================*/
    data combined;
        set &i_dsn_base(in=a) &i_dsn_compare(in=b);
        length _source_ $5;
        if a then _source_='BASE';
        else if b then _source_='COMP';
    run;

    /*===============================================================
      4. Build concatenated class key for multi-class comparison
    ===============================================================*/
    data combined;
        set combined;
        length _class_key_ $200;
        _class_key_ = catx('_', of &i_classes);
    run;
    proc sort data=combined; by _class_key_; run;

    /*===============================================================
      5. Warn about class levels that exist in only one dataset
    ===============================================================*/
    proc freq data=combined noprint;
        tables _class_key_ * _source_ / out=_freqs(drop=percent);
    run;

    proc sql noprint;
        create table _missing_classes as
        select _class_key_, count(distinct _source_) as n_source
        from _freqs
        group by _class_key_
        having n_source < 2;
    quit;

    %if %sysfunc(exist(work._missing_classes)) %then %do;
        data _null_;
            if 0 then set work._missing_classes nobs=_nmiss;
            call symputx('_nmiss', _nmiss);
        run;
        %if &_nmiss>0 %then %do;
            %put WARNING: Some class levels exist only in one dataset. See WORK._MISSING_CLASSES.;
        %end;
    %end;

    /*===============================================================
      6. Compute summary stats
    ===============================================================*/
    proc means data=combined nway noprint;
        class &i_classes _source_;
        var &i_variable;
        output out=_summary(drop=_type_ _freq_)
            mean=mean_ std=std_ n=n_;
    run;

    data _summary;
        set _summary;
        length _class_key_ $200;
        _class_key_ = catx('_', of &i_classes);
    run;

    /*===============================================================
    7. Perform t-tests (only for classes with both groups)
    ===============================================================*/
    ods graphics off;
    proc sort data=combined;
        by _class_key_;
    run;

    /* Identify only valid classes that exist in both BASE and COMP */
    proc sql;
        create table _valid_classes as
        select _class_key_
        from combined
        group by _class_key_
        having count(distinct _source_) = 2;
    quit;

    /* Merge to keep only valid class keys */
    proc sql;
        create table combined_valid as
        select a.*
        from combined a
        inner join _valid_classes b
            on a._class_key_ = b._class_key_;
    quit;

    /* Run t-tests only on valid class combinations */
    proc sort data=combined_valid;
        by _class_key_;
    run;

    proc ttest data=combined_valid;
        class _source_;
        var &i_variable;
        by _class_key_;
        ods output TTests=_ttests;
    run;
    ods graphics on;

    /* Clean up and deduplicate */
    data _ttests_clean;
        set _ttests(keep=_class_key_ Probt);
        rename Probt=p_value;
    run;

    proc sort data=_ttests_clean nodupkey;
        by _class_key_;
    run;

    /*===============================================================
      8. Split base and comp summaries for merging
    ===============================================================*/
    data _base _comp;
        set _summary;
        if _source_='BASE' then output _base;
        else if _source_='COMP' then output _comp;
    run;

    /*===============================================================
      9. Merge results (FULL JOIN keeps missing classes)
    ===============================================================*/
    proc sql;
        create table &out as
        select
            coalesce(a._class_key_, b._class_key_) as _class_key_,
            a.mean_ as mean_base,
            b.mean_ as mean_comp,
            (a.mean_ - b.mean_) as mean_diff,
            t.p_value,
            case
                when missing(a.mean_) then 'Missing in BASE'
                when missing(b.mean_) then 'Missing in COMP'
                when not missing(t.p_value) and t.p_value < &i_threshold. then 'Significant'
                when not missing(t.p_value) then 'Not Significant'
                else 'Not Tested'
            end as significance
        from _base a
        full join _comp b
            on a._class_key_ = b._class_key_
        left join _ttests_clean t
            on coalesce(a._class_key_, b._class_key_) = t._class_key_
        order by _class_key_;
    quit;

    /*===============================================================
    9B. Compute Sum Tables (per class and per class combination)
    ===============================================================*/

    /* --- 1. Sum by concatenated class key --- */
    proc sql;
        create table &out._sum_by_combo as
        select
            _class_key_,
            sum(case when _source_='BASE' then &i_variable else 0 end) as sum_base,
            sum(case when _source_='COMP' then &i_variable else 0 end) as sum_comp,
            calculated sum_base - calculated sum_comp as sum_net_diff,
            case
                when calculated sum_comp ne 0
                then 100*(calculated sum_base - calculated sum_comp)/calculated sum_comp
            end as sum_pct_diff
        from combined
        group by _class_key_;
    quit;

    /* --- 2. Sum by each class variable individually --- */
    %let ncls=%sysfunc(countw(&i_classes));
    %do i=1 %to &ncls;
        %let cls=%scan(&i_classes,&i);

        /* --- Build safe table name (truncate to 32 chars) --- */
        %let full_name=&out._sum_by_class_&i;
        %let name_length=%length(&full_name);
        %let tblname=%substr(&full_name, 1, %sysfunc(min(&name_length,32)));

        /* --- Log warning if truncated --- */
        %if &name_length > 32 %then %do;
            %put WARNING: Table name &full_name exceeds 32 chars. Truncated to &tblname.;
        %end;

        proc sql;
            create table &tblname as
            select
                "&cls" as class length=64,
                &cls as class_value length=64,
                &i_variable as variable length=64,
                sum(case when _source_='BASE' then &i_variable else 0 end) as sum_base,
                sum(case when _source_='COMP' then &i_variable else 0 end) as sum_comp,
                calculated sum_base - calculated sum_comp format=comma32.2 as sum_net_diff,
                case
                    when calculated sum_comp ne 0
                    then 100*(calculated sum_base - calculated sum_comp)/calculated sum_comp
                end format=percent8.2 as sum_pct_diff
            from combined
            group by &cls;
        quit;
    %end;

    /* --- Combine all sum by class tables into one --- */

    data &out._sum_by_class;
        set
        %do i=1 %to &ncls;
            &out._sum_%scan(&i_classes,&i)
        %end;;
    run;

    /*===============================================================
      10. Display results
    ===============================================================*/
    title "Comparison of &i_variable by &i_classes (threshold=&i_threshold)";
    proc print data=&out label noobs;
        label mean_base="Base Mean"
              mean_comp="Compare Mean"
              mean_diff="Mean Diff (Base - Comp)"
              p_value="p-Value"
              significance="Significance Status";
    run;
    title;

    /*===============================================================
      11. Cleanup
    ===============================================================*/
    proc datasets lib=work nolist;
        delete _vars_base _vars_comp _vars_check _summary _ttests _ttests_clean
            _base _comp _freqs _missing_classes combined;
    quit;

%mend compare_numeric_by_classes;
/** \endcond */
