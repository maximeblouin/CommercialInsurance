/**
    \file
    \ingroup    OPTIMISATION
    \brief      Compute the percentage of space for each column in a dataset.
    \author     Maxime Blouin
    \param      i_dsn  Input dataset name
    \return
*/ /** \cond */
%macro column_space_pct(i_dsn);

    /* Check if the dataset exists */
    %if %sysfunc(exist(&i_dsn.)) %then %do;

        /* Get column information */
        proc contents noprint data=&i_dsn. out=work.contents(keep=name length type);
        run;

        /* Calculate the total length of all columns */
        proc sql noprint;
            select sum(length) into :total_length
            from work.contents;
        quit;

        /* Compute space used and percentage for each column */
        data work.column_space;
            set work.contents;
            column_space = length;
            pct_space = (column_space / &total_length.);
            format pct_space percent8.2;
        run;

        proc sort;
            by descending pct_space;
        run;

        /* Print the results */
        proc print data=work.column_space;
            var nobs name type length column_space pct_space;
            title 'Column Space Usage';
        run;

        /* Clean up temporary datasets */
        proc datasets library=work nolist;
            delete contents column_space;
        quit;

    %end;
    %else %do;
        %put ERROR: Dataset &i_dsn. does not exist.;
    %end;

%mend column_space_pct;
/** \endcond */
