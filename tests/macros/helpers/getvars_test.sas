/**
    \file
    \ingroup    MACROS_HELPERS_TEST
    \brief      Tests for getvars.sas
    \details    Example for a test scenario with the following features:
                - check value of macro symbol with assertEquals.sas
                - scan log with assertLog.sas
                - omit endTestcall.sas and endTestcase.sas
                - check for special cases
    \author     Maxime Blouin
    \date       14JUL2022
*/

/** \cond */

%initScenario(i_desc=Tests for getvars.sas);

/*-- simple example with sashelp.class ---------------------------------------*/
%macro testcase();
    /* setup environment for test call */

    /* start testcase */
    %initTestcase(
        i_object=getvars.sas,
        i_desc=%str(simple example with sashelp.class))

    /* call */
    %let vars=%getvars(sashelp.class);
    %endTestcall()

    /* assert */
    %assertEquals(
        i_actual=&vars,
        i_expected=Name Sex Age Height Weight,
        i_desc=Check variables)

    /* end testcase */
    %endTestcase()
%mend testcase; %testcase;

/*-- simple example with sashelp.class, different delimiter ------------------*/
%macro testcase();
    /* setup environment for test call */

    /* start testcase */
    %initTestcase(
        i_object=getvars.sas,
        i_desc=%str(simple example with sashelp.class, different delimiter))

    /* call */
    %let vars=%getvars(i_data=sashelp.class, i_dlm=%str(,));

    %endTestcall()

    /* assert */
    %assertEquals(
        i_actual=&vars,
        i_expected=%str(Name,Sex,Age,Height,Weight),
        i_desc=Check variables)

    /* end testcase */
    %endTestcase()
%mend testcase; %testcase;

/*-- example with variable names containing special characters ---------------*/
%macro testcase();

    /* setup environment for test call */
    options validvarname=any;
    data work.test;
        'a b c'n=1;
        '$6789'n=2;
        ';6789'n=2;
    run;

    /* start testcase */
    %initTestcase(
        i_object=getvars.sas,
        i_desc=%str(example with variable names containing special characters))

    /* call */
    %let vars="%getvars(test,i_dlm=%str(%",%"))";
    %endTestcall()

    /* assert */
    %assertEquals(
        i_actual=&vars.,
        i_expected=%str("a b c","$6789",";6789"),
        i_desc=Check variables)

    /* end testcase */
    %endTestcase()
%mend testcase; %testcase;

/*-- example with empty dataset ----------------------------------------------*/
%macro testcase();
    /* setup environment for test call */
    data work.test;
        stop;
    run;

    /* start testcase */
    %initTestcase(
        i_object=getvars.sas,
        i_desc=%str(example with empty dataset))

    /* call */
    %let vars=%getvars(test);
    %endTestcall()

    /* assert */
    %assertEquals(
        i_actual=&vars,
        i_expected=,
        i_desc=Check for no variables found)

    /* end testcase */
    %endTestcase()
%mend testcase; %testcase;


/*-- example without dataset specified ---------------------------------------*/
%macro testcase();
    /* setup environment for test call */

    /* start testcase */
    %initTestcase(
        i_object=getvars.sas,
        i_desc=%str(example without dataset specified))

    /* call */
    %let vars=%getvars();
    %endTestcall()

    /* assert */
    %assertEquals(
        i_actual=&vars,
        i_expected=,
        i_desc=no variables found)

    /* end testcase */
    %endTestcase()
%mend testcase; %testcase;


/*-- example with invalid dataset --------------------------------------------*/
%macro testcase();
    /* setup environment for test call */

    /* start testcase */
    %initTestcase(
        i_object=getvars.sas,
        i_desc=%str(example with invalid dataset))

    /* call */
    %let vars=%getvars(xxx);
    %endTestcall()

    /* assert */
    %assertEquals(
        i_actual=&vars,
        i_expected=,
        i_desc=example with invalid dataset)

    /* end testcase */
    %endTestcase()
%mend testcase; %testcase;

proc delete data=work.test;
run;

%endScenario();

/** \endcond */