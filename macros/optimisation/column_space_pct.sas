/**
    \file
    \ingroup    OPTIMISATION
    \brief      Compute the space for each column in a dataset based on both metadata and actual value lengths.
    \author     Maxime Blouin
    \param      i_dsn  Input dataset name
    \param      include_actual  Switch to include actual length calculations (1=include, 0=exclude)
    \return
*/ /** \cond */
%macro column_space_pct(i_dsn, include_actual=0);

    /* Check if the dataset exists */
    %if %sysfunc(exist(&i_dsn.)) %then %do;

        /* Get column information */
        proc contents noprint data=&i_dsn. out=work.contents(keep=name length type);
        run;

        /* Calculate the total length of all columns based on metadata */
        proc sql noprint;
            select sum(length) into :total_length_metadata
            from work.contents;
        quit;

        /* Compute space used for each column based on metadata */
        data work.column_space_metadata;
            set work.contents;
            column_space_metadata = length;
        run;

        %if &include_actual = 1 %then %do;
            /* Create a dataset with the actual lengths of each value */
            data work.value_lengths;
                set &i_dsn.;
                array char_vars _character_;
                array num_vars _numeric_;

                /* Calculate length for character variables */
                do i = 1 to dim(char_vars);
                    varname = vname(char_vars[i]);
                    varlength = lengthn(char_vars[i]);
                    output;
                end;

                /* Calculate length for numeric variables (assuming 8 bytes for numeric values) */
                do i = 1 to dim(num_vars);
                    varname = vname(num_vars[i]);
                    varlength = 8;
                    output;
                end;

                keep varname varlength;
            run;

            /* Summarize the maximum length for each column */
            proc summary data=work.value_lengths nway;
                class varname;
                var varlength;
                output out=work.column_summaries max=column_space_actual;
            run;

            /* Merge both results and calculate the difference */
            proc sql;
                create table work.column_space as
                select
                    a.name as column_name,
                    a.length as length_metadata,
                    b.column_space_metadata,
                    c.column_space_actual,
                    (c.column_space_actual - b.column_space_metadata) as diff_space length=8 label='Difference in Space'
                from
                    work.contents as a
                left join
                    work.column_space_metadata as b
                on
                    a.name = b.name
                left join
                    work.column_summaries as c
                on
                    a.name = c.varname
                order by
                    diff_space;
            quit;

        %end;
        %else %do;
            /* Only include metadata results */
            proc sql;
                create table work.column_space as
                select
                    name as column_name,
                    length as length_metadata,
                    column_space_metadata
                from
                    work.column_space_metadata
                order by
                    column_space_metadata desc;
            quit;
        %end;

        /* Print the results */
        proc print data=work.column_space;
            var column_name length_metadata column_space_metadata
                %if &include_actual = 1 %then %do;
                    column_space_actual diff_space
                %end;;
            title 'Column Space Usage';
        run;

        /* Clean up temporary datasets */
        proc datasets library=work nolist;
            delete contents column_space_metadata
                %if &include_actual = 1 %then %do;
                    value_lengths column_summaries column_space_actual
                %end;
                column_space;
        quit;

    %end;
    %else %do;
        %put ERROR: Dataset &i_dsn. does not exist.;
    %end;

%mend column_space_pct;
/** \endcond */
