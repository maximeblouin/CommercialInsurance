/**
    \file
    \ingroup    CLEANING_DATA
    \brief      Macro to calculate statistics for data cleaning purposes.
    \details    This macro calculates statistics such as maximum length
                and whether the column is a singleton to aid in data
                cleaning tasks.
                It provides the following statistics for each column:
                - Current length of the variable
                - Length of the longest value
                - Number of distinct values
    \author     Maxime Blouin
    \date       15MAY2024
    \param      i_dsn Input dataset name
    \param      o_dsn Output dataset name
    \return     Prints the statistics for each column and creates an output
                dataset containing the statistics.
    \remark     Example usage:
                %get_stats_for_data_cleaning(
                    i_dsn=lib.data,
                    o_dsn=stats_for_data_cleaning);
*/

/** \cond */

%macro get_stats_for_data_cleaning(
    i_dsn= /* Input dataset name */,
    o_dsn= /* Output dataset name */);

    /* Check if dataset names are provided */
    %if %length(&i_dsn) eq 0 or %length(&o_dsn) eq 0 %then %do;
        %put ERROR: Dataset names are not provided.;
        %return;
    %end;

    /* Check if input dataset exists */
    %if %sysfunc(exist(&i_dsn)) eq 0 %then %do;
        %put ERROR: Dataset &i_dsn. does not exist.;
        %return;
    %end;

    /* Get the number of variables in the dataset */
    %let dsid = %sysfunc(open(&i_dsn));
    %let numvars = %sysfunc(attrn(&dsid, nvars));

    /* Create output dataset for statistics */
    proc sql noprint;
        create table &o_dsn. (
            Variable_Name char(32) label="Variable Name",
            Variable_Length num label="Variable Length",
            Longest_Length num label="Longest value length",
            Num_Distinct_Values num label="Number of Distinct Values"
        );
    quit;

    /* Loop over each variable */
    %do i = 1 %to &numvars;
        /* Get the name and type of the current variable */
        %let varname = %sysfunc(varname(&dsid, &i));
        %let vartype = %sysfunc(vartype(&dsid, &i));
        %let varlen = %sysfunc(varlen(&dsid, &i));

        /* Calculate max length and number of distinct values */
        proc freq data=&i_dsn noprint;
            table &varname. / missing out=stats_temp;
        run;

        /* Get max length */
        %let max_length = .;
        %if "&vartype" eq "C" %then %do;
            proc sql noprint;
                select max(lengthn(&varname.)) into :max_length
                from stats_temp;
            quit;
        %end;

        /* Get number of distinct values */
        proc sql noprint;
            select count(distinct &varname.) into :nb_distinct_value
            from stats_temp;
        quit;

        /* Print the variable name and information */
        %put Variable Name: &varname;
        %put > Variable Length: &varlen;
        %put > Longest Value Length: &max_length;
        %put > Number of Distinct Values: &nb_distinct_value;

        /* Output to dataset */
        proc sql noprint;
            insert into &o_dsn. (Variable_Name, Variable_Length, Longest_Length, Num_Distinct_Values)
            values ("&varname", &varlen, &max_length, &nb_distinct_value);
        quit;
    %end;

    /* Close dataset */
    %let rc = %sysfunc(close(&dsid));

%mend get_stats_for_data_cleaning;

/** \endcond */
