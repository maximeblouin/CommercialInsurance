/**
    \file
    \ingroup    MACROS_HELPERS
    \brief      List folders matching a pattern in a directory
    \details    Example: Execute the macro in a libname statement to create
                a library with the folders matching the pattern.:
                >> libname demo (
                >>      %list_folders(
                >>          i_dir=&_sasprod.fichiers\actu\a11\s999,
                >>          i_pattern=^base_prmauto\[.*V00]$),
                >>          i_nb_path=7));
    \author     Maxime Blouin
    \date       02AUG2024
    \param      i_dir directory to search for folders
    \param      i_pattern pattern to match folders
    \param      i_nb_path number of folders to return
    \remark     Generation Data Group (GDG)
    \remark     The pattern is a regular expression
    \remark     The folders are returned in reverse order (To prioritize the most recent folders)
    \remark     The folders are returned as a list of strings separated by a blank space (e.g. "folder1" "folder2")
    \return     list of folders matching the pattern in the specified directory
*/ /** \cond */
%macro list_folders(
    i_dir /* directory to search for folders */,
    i_pattern /* pattern to match folders */,
    i_nb_path /* number of folders to return */);

    %local filrf rc did memcnt name i regex_id match folder_found;

    %let rc = %sysfunc(filename(filrf, &i_dir));
    %let did = %sysfunc(dopen(&filrf));

    %if &did eq 0 %then %do;
        %put Directory &i_dir cannot be opened or does not exist;
        %return;
    %end;

    %let memcnt = %sysfunc(dnum(&did)); /* Get the number of entries in the directory */
    %let regex_id = %sysfunc(prxparse(/&i_pattern/)); /* Compile the regex pattern */
    %let folder_found = 0;

    %do i = &memcnt %to 1 %by -1; /* Loop from last to first */
        %let name = %qsysfunc(dread(&did, &i));

        %if %qscan(&name, 2, .) = %then %do;
            %let match = %sysfunc(prxmatch(&regex_id, &name));
            %if &match > 0 %then %do;
                %let folder_found = %eval(&folder_found + 1);
                %if &folder_found <= &i_nb_path %then %do;
                    "&i_dir\&name" /* Output path */
                %end;
            %end;
        %end;
    %end;

    %let rc = %sysfunc(dclose(&did));
    %let rc = %sysfunc(filename(filrf));
%mend list_folders;
/** \endcond */