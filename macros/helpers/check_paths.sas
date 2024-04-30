
/**
    \file
    \ingroup    MACROS
    \brief      Macro to check if a file or directory exists
    \details    This macro checks if the specified file or directory exists.
    \author     Maxime Blouin
    \date       30APR2024
    \param      i_path Path of the filename or directory to check
    \return     Returns a message indicating whether the path exists or not
    \remark     Here's an example usage of the `check_paths`:
                %check_paths(i_path=&htmlpath);
*/

/** \cond */

%macro check_paths(i_path=);
    %if %sysfunc(fileexist(&i_path.)) %then %do;
        %put INFO: Path &i_path. exists.;
    %end;
    %else %do;
        %put ERROR: Path &i_path. does not exist.;
        %return;
    %end;
%mend check_paths;

/** \endcond */