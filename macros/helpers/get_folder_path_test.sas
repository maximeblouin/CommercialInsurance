/**
    \file
    \ingroup    MACROS_HELPERS_TEST
    \brief      Tests for get_folder_path.sas
    \author     Maxime Blouin
    \date       22JUL2024
*/ /** \cond */

/* Example usage */

%initScenario(
    i_desc=Tests for get_folder_path.sas);

%initTestcase(
    i_object=get_folder_path.sas,
    i_desc=%str(Test case for no error in the log));

/* call */
%let file_path = C:\path\to\your\file.txt;
%let folder_path = %get_folder_path(&file_path);

%endTestcall()

/* assert */
%assertTrue(
    i_cond = &folder_path EQ 'C:\path\to\your',
    i_desc = %str(Check that path is extracted correctly));

%assertPerformance(
    i_expected=1,
    i_desc=%str(Check for run time less than 1 second));

%assertLog(
    i_errors=0,
    i_warnings=0);

%endTestcase()

%endScenario();
/** \endcond */