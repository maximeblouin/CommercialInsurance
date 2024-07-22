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

    %local l_cwd;
    %let l_cwd=cwd;

    %sysfunc(pathname(cwd, F)); /* 'F' specifies a search for a fileref. */

%mend get_current_directory;
/** \endcond */