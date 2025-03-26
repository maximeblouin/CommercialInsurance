/**
    \file
    \ingroup    DATA_QUALITY_TEST
    \brief      Test the check_conditions macro
    \details    This macro tests the check_conditions macro by running it
                on a test dataset.
    \author     Maxime Blouin
    \date       26MAR2025
*/ /** \cond */

/* Using SASHELP.CARS as a test dataset */
%let i_dsn = SASHELP.CARS;
%let i_check_rules = WORK.CHECKS;
%let o_check_results = QUALITY.SASHELP_CARS;

/* Create a dataset with check rules */
proc sql;
    create table &i_check_rules (
        ValidationRule char(200), /* Rule to validate */
        Filter char(200), /* A rule for all observations, use 1 */
        Threshold num /* Threshold for the rule */
    );

    insert into &i_check_rules
        values ('Origin eq "Asia"', 'Make eq "Audi"', 0.9);
    insert into &i_check_rules
        values ('Origin eq "Europe"', 'Make eq "Audi"', 0.9);
    insert into &i_check_rules
        values ('Origin eq "Asia2"', '1', 0.9);
    insert into &i_check_rules
        values ('Origin eq "Asia"', '1', 0.9);
quit;

/* Run the check conditions macro */
%check_conditions(
    i_dsn=&i_dsn,
    i_dsn_rules=&i_check_rules,
    o_dsn_results=&o_check_results);

/* Display results */
proc print data=&o_check_results;
run;

/** \endcond */