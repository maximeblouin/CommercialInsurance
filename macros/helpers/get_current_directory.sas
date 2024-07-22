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
    %let l_cwd = ;

    data _null_;
        length cwd $ 250;

        rc = filename('cwd', '.'); /*'.' refers to the current directory*/

        if (rc = 0) then do;
            call symputx('l_cwd', pathname('cwd'));
        end;
    run;

    %if &l_cwd %then %do;
        %put "ERROR: Unable to get current working directory.";
    %end;
    else %do;
        &l_cwd
    %end;

%mend get_current_directory;
/** \endcond */