/**
    \file
    \ingroup    HELPERS_TEST

    \brief      Tests for nobs.sas

    \details    Example for a test scenario with the following features:
                - create simple test scenario
                - check value of macro symbol with assertEquals.sas

    \author     Maxime Blouin
    \date       14JUL2022
*/ /** \cond */

%initScenario(i_desc=Tests for nobs.sas);

/*-- simple example with sashelp.class ---------------------------------------*/
%initTestcase(
    i_object=nobs.sas,
    i_desc=simple example with sashelp.class)

%let nobs=%nobs(sashelp.class);

%endTestcall()

%assertEquals(
    i_actual=&nobs,
    i_expected=19,
    i_desc=Check number of observations in sashelp.class)

%assertLogMsg(
    i_logMsg=.let nobs=.nobs.sashelp.class.);

%endTestcase()

/*-- example with big dataset ------------------------------------------------*/
%initTestcase(
    i_object=nobs.sas,
    i_desc=%str(example with big dataset))

data work.big;
    do i=1 to 1000000;
        x=ranuni(0);
        output;
    end;
run;

%let nobs=%nobs(work.big);

%endTestcall()

%assertEquals(
    i_actual=&nobs,
    i_expected=1000000,
    i_desc=Check for number of observations in dataset work.big)

%endTestcase()

/*-- example with empty dataset ----------------------------------------------*/
%initTestcase(
    i_object=nobs.sas,
    i_desc=%str(example with empty dataset))

data work.empty;
    stop;
run;

%let nobs=%nobs(work.empty);

%endTestcall()

%assertEquals(
    i_actual=&nobs,
    i_expected=0,
    i_desc=number of observations in dataset work.empty)

%endTestcase()

/*-- dataset not specified ---------------------------------------------------*/
%initTestcase(
    i_object=nobs.sas,
    i_desc=%str(dataset not specified))

%let nobs=%nobs(xxx);

%endTestcall()

%assertEquals(
    i_actual=&nobs,
    i_expected=,
    i_desc=number of observations when dataset is not specified)

%endTestcase()

/*-- invalid dataset ---------------------------------------------------------*/
%initTestcase(
    i_object=nobs.sas,
    i_desc=%str(invalid dataset))

%let nobs=%nobs(xxx);

%endTestcall()

%assertEquals(
    i_actual=&nobs,
    i_expected=,
    i_desc=number of observations with invalid dataset)

%endTestcase()

proc datasets lib=work memtype=DATA nolist;
    delete big empty;
    run;
quit;

%endScenario();
/** \endcond */