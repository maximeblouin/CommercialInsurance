/**
    \file
    \ingroup    INIT_SANDBOX
    \brief      Initialization of the data sandbox
    \author     Maxime Blouin
    \date       26MAR2024
    \remark
        1. Append SASUnit macro library
        2. Compile macros from the specified directory and its subdirectories.
        3. Assign a library reference to the data directory.
*/
/** \cond */

/* Append SASUnit macro library */
options append=sasautos=(
    "%sysfunc(pathname(HOME))/CommercialInsurance/macros/sasunit"
    "%sysfunc(pathname(HOME))/CommercialInsurance/macros/sasunit/linux"
    "%sysfunc(pathname(HOME))/CommercialInsurance/macros/sasunit/helpers"
) MAUTOLOCDISPLAY;

%macro compile_macros(
    i_dir= /* The directory to search for SAS files. */,
    i_recursive=1 /* An option to perform the search recursively (default is 1) */);

    %local filrf rc did name i basename pathname;

    /* Assign a fileref to the directory */
    %let rc = %sysfunc(filename(filrf, &i_dir));

    /* Open the directory and get a directory ID */
    %let did = %sysfunc(dopen(&filrf));

    /* Check if the directory can be opened */
    %if &did eq 0 %then %do;
        %put ERROR: Directory &i_dir cannot be opened or does not exist.;
        %return;
    %end;

    /* Loop through the contents of the directory */
    %do i = 1 %to %sysfunc(dnum(&did));
        %let name = %qsysfunc(dread(&did, &i));

        /* Extract the file name without extension */
        %let basename = %qscan(&name, 1, .);

        /* Check if the file has the .sas extension and does not end with _test or _tests */
        %if %qupcase(%qscan(&name, -1, .)) = %upcase(sas) and
            %index(%qupcase(&basename), %upcase(_test)) = 0 and
            %index(%qupcase(&basename), %upcase(_tests)) = 0 %then %do;
            %let pathname = &i_dir/&name;
            %put NOTE: Compiling &pathname;
            %include "&pathname.";
        %end;
        /* If the item is a directory and recursion is enabled, call the macro recursively */
        %else %if %qscan(&name, 2, .) = and &i_recursive eq 1 %then %do;
            %compile_macros(
                i_dir=&i_dir/&name,
                i_recursive=&i_recursive
            );
        %end;
    %end;

    /* Close the directory and clear the fileref */
    %let rc = %sysfunc(dclose(&did));
    %let rc = %sysfunc(filename(filrf));
%mend compile_macros;

/* Call the macro to compile macros from the specified directory */
%compile_macros(
    i_dir=%sysfunc(pathname(HOME))/CommercialInsurance/macros,
    i_recursive=1
);

/* Assign a library reference to the data directory */
libname DATA "%sysfunc(pathname(HOME))/CommercialInsurance/data/";

/** \endcond */
