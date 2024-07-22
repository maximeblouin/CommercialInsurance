/**
    \file
    \ingroup    MACROS_HELPERS_TEST
    \brief      Tests for get_current_directory.sas
    \author     Maxime Blouin
    \date       22JUL2024
*/ /** \cond */
%initScenario(
    i_desc=Tests for get_current_directory.sas);

%initTestcase(
    i_object=get_current_directory.sas,
    i_desc=%str(Test case for no error in the log));

/* call */
%let cwd=%get_current_directory();

%endTestcall()

/* assert */
%assertTrue(
    i_cond = &cwd NE '',
    i_desc = %str(Check that the current working directory is not empty));

%assertPerformance(
    i_expected=1,
    i_desc=%str(Check for run time less than 1 second));

%assertLog(
    i_errors=0,
    i_warnings=0);

%endTestcase()

%endScenario();
/** \endcond */