/**
    \file
    \ingroup    HELPERS
    \brief      Return number of observations in a SAS dataset.

    \details    Return number of logical observations (deleted obeservations are not counted) in a SAS dataset.
                In case of an invalid dataset specification, a blank will be returned.

                Example: %put %nobs(dataset);
    \author     Maxime Blouin
    \date       14JUL2022
    \param      i_data SAS dataset to count observations from
    \return     number of observations in input dataset
*/

/** \cond */

%macro nobs(
    i_data /*SAS dataset to count observations from*/);

    %local dsid nobs;
    %let nobs=;
    %let dsid=%sysfunc(open(&i_data));

    %if &dsid > 0 %then %do;
        %let nobs=%sysfunc(attrn(&dsid, nlobs));
        %let dsid=%sysfunc(close(&dsid));
    %end;

    &nobs
%mend nobs;

/** \endcond */