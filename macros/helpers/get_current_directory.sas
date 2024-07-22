/**
    \file
    \ingroup    MACROS_HELPERS
    \brief      Return the current working directory
    \details    Example: %put %get_current_directory();
                Example: %let cwd = %get_current_directory();
    \author     Maxime Blouin
    \date       22JUL2024
    \return     the current working directory
*/ /** \cond */
%macro get_current_directory();

    filename cwd '.';

    %local l_cwd;

    %if %sysfunc(fileref(cwd)) %then %do;
        %let l_cwd = %sysfunc(pathname(cwd, F)); /* 'F' specifies a search for a fileref. */
        &l_cwd
    %end;
    %else %do;
        %put %sysfunc(sysmsg());
    %end;

%mend get_current_directory;
/** \endcond */