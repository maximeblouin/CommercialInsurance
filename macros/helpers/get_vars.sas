/**
    \file
    \ingroup    HELPERS
    \brief      Return variable names for a SAS dataset
    \details    Example: %put %get_vars(dataset);
    \author     Maxime Blouin
    \date       14JUL2022
    \param      i_data SAS dataset to return variable names from
    \param      i_dlm  delimiter, default is a blank
    \return     list of variable names from input dataset, separated by specified delimiter
*/

/** \cond */

%macro get_vars(
    i_data /*SAS dataset to return variable names from*/,
    i_dlm= /*delimiter, default is a blank*/);

    %local varlist dsid i;

    %if "&i_dlm"="" %then %let i_dlm=%str( );

    %let dsid = %sysfunc(open(&i_data));

    %if &dsid %then %do;
        %do i=1 %to %sysfunc(attrn(&dsid,NVARS));
            %if &i=1 %then
                %let varlist = %sysfunc(varname(&dsid,&i));
            %else
                %let varlist = &varlist.&i_dlm.%sysfunc(varname(&dsid,&i));
        %end;

        %let dsid = %sysfunc(close(&dsid));
    %end;

    &varlist

%mend get_vars;

/** \endcond */