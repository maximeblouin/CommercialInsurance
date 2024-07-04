/**
    \file
    \ingroup    MACROS_HELPERS
    \brief      Supprime le fichier de données spécifié
    \author     Maxime Blouin
    \date       24OCT2023
    \param      i_table Le dataset à supprimer
                i_password Le mot de passe du dataset à supprimer
                i_library La librairie du dataset à supprimer (default=work)
*/

/** \cond */

%macro delete_dataset(
    i_table= /*Le dataset à supprimer*/,
    i_password= /*Le mot de passe du dataset à supprimer*/,
    i_library=work /*La librairie du dataset à supprimer.*/);

    %local l_dsid rc;

    %if %sysfunc(exist(&i_library..&i_table)) %then %do;
        %let l_dsid=%sysfunc(open(&i_library..&i_table));

        %if %sysfunc(attrn(&l_dsid, PW)) %then %do;
            %if %length(&i_password) eq 0 %then
                %put WARNING: &i_library..&i_table is password protected and you did not provide a password.;
            %else %do;
                %put NOTE: &i_library..&i_table exist and is password protected.;

                %let rc=%sysfunc(close(&l_dsid));

                proc datasets nodetails nolist library=&i_library;
                    delete &i_table (alter=&i_password);
                quit;

                %put NOTE: &i_library..&i_table deleted successfully.;
            %end;
        %end;
        %else %do;
            %put NOTE: &i_library..&i_table exist.;

            %let rc=%sysfunc(close(&l_dsid));

            proc datasets nodetails nolist library=&i_library;
                delete &i_table;
            quit;

            %put NOTE: &i_library..&i_table deleted successfully.;
        %end;
    %end;
    %else %put NOTE: &i_library..&i_table does not exist.;

%mend delete_dataset;

/** \endcond */