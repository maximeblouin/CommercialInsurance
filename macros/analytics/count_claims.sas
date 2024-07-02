/**
    \file
    \ingroup    MACROS_ANALYTICS
    \author     Maxime Blouin
    \brief      Macro for counting claims by ansin, nodoss, and coverage in a dataset.
    \param      io_dsn The dataset to add the nbDoss variable
*/

/** \cond*/

%macro count_claims(io_dsn);

    %let dsid=%sysfunc(open(&io_dsn., i));

    /* Check if required variables exist */
    %if not %sysfunc(varnum(&dsid., ansin)) %then %do;
        %put ERROR: Variable ansin does not exist in &io_dsn.;
        %return; /* Exit macro */
    %end;
    %if not %sysfunc(varnum(&dsid., nodoss)) %then %do;
        %put ERROR: Variable nodoss does not exist in &io_dsn.;
        %return; /* Exit macro */
    %end;
    %if not %sysfunc(varnum(&dsid., coverage)) %then %do;
        %put ERROR: Variable coverage does not exist in &io_dsn.;
        %return; /* Exit macro */
    %end;

    /* Check if nbDoss variable already exists */
    %if %sysfunc(varnum(&dsid., nbDoss)) %then %do;
        %put WARNING: Variable nbDoss already exists in &io_dsn.;
    %end;

    %let rc=%sysfunc(close(&dsid));

    /* Check for missing values in required variables */
    data _mull_;
        set &io_dsn. end=lastobs;

        /* Check for missing values */
        if missing(ansin) or missing(nodoss) or missing(coverage) then do;
            put "WARNING: Missing values found in ansin, nodoss, or coverage variables in " &io_dsn.;
            put "Row: " _N_;
            stop; /* Stop processing after the warning */
        end;

        if lastobs then put "NOTE: No missing values found in ansin, nodoss, or coverage variables in " &io_dsn.;
    run;

    /* SAS code logic for counting claims by ansin, nodoss, and coverage */
    proc sort data=&io_dsn.;
        by ansin nodoss coverage;
    run;

    data &io_dsn.;
        set &io_dsn.;
        by ansin nodoss coverage;

        /* Counting logic for nbDoss */
        if first.coverage then nbDoss = 1;
        else nbDoss = 0;
    run;

%mend count_claims;

/** \endcond*/