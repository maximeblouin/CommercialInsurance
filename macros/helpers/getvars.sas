/**
    \file
    \ingroup    MACROS_HELPERS

    \brief      return variable names for a SAS dataset

    \details    Example: %put %getVars(dataset);

    \author     Maxime Blouin
    \date       14JUL2022
    \param      i_data SAS dataset to return variable names from
    \param      i_dlm  delimiter, default is a blank
    \return     list of variable names from input dataset, separated by specified delimiter
*/

/** \cond */

%macro getVars(
    data,
    dlm=);

    %local varlist dsid i;
    %if "&dlm"="" %then %let dlm=%str( );
    %let dsid = %sysfunc(open(&data));
    %if &dsid %then %do ;
    %do i=1 %to %sysfunc(attrn(&dsid,NVARS));
        %if &i=1 %then
            %let varlist = %sysfunc(varname(&dsid,&i));
        %else
            %let varlist = &varlist.&dlm.%sysfunc(varname(&dsid,&i));
    %end;
    %let dsid = %sysfunc(close(&dsid));
    %end;

    &varlist

%mend getVars;

/** \endcond */