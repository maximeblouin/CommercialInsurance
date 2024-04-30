/**
    \file
    \ingroup    HELPERS
    \brief      Check for the existence of a specified variable.
    \details    Usage Notes:

                %if %varexist(&data,NAME)
                %then %put input data set contains variable NAME;

                The macro calls resolves to 0 when either the data set does not exist
                or the variable is not in the specified data set.
    \author     Tom (https://communities.sas.com/t5/user/viewprofilepage/user-id/159)
    \sa         https://communities.sas.com/t5/SAS-Programming/How-to-know-whether-a-variable-exists-in-a-dataset/td-p/120083
    \date       09JAN2013
    \param      ds  Data set name
    \param      var Variable name
    \return
*/

/** \cond */

%macro varexist (
    ds /* Data set name */,
    var /* Variable name */);

    %local dsid rc ;

    /*Use SYSFUNC to execute OPEN, VARNUM, and CLOSE functions.*/
    %let dsid=%sysfunc(open(&ds));

    %if (&dsid) %then %do;
        %if %sysfunc(varnum(&dsid,&var)) %then 1;
        %else 0;
        %let rc=%sysfunc(close(&dsid));
    %end;
    %else 0;

%mend varexist;

/** \endcond */