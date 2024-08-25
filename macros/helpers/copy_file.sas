/**
    \file copy_file.sas
    \brief This macro copies a file from one directory to another.
    \details This macro copies a file from one directory to another using the SAS FILENAME statement.
    \author Maxime Blouin
    \date 25AUG2024
    \version 1.0
    \param[in] i_src_file Full path of the source file
    \param[out] o_dest_file Full path of the destination file
    \remark This macro is a helper macro for the %copy_files macro.
    \remark Version 1.0 - 25AUG2024 - Initial version of the macro
*/ /** \cond */
%macro copy_file(
    i_src_file /*Full path of the source file*/,
    o_dest_file /*Full path of the destination file*/);

    %let recfm = d;
    /* Define recfm for Excel files */
    %if %index(%lowcase(&i_src_file), .xlsx) %then %let recfm = n; /*binary format*/

    /* Define recfm for text files */
    %else %if %index(%lowcase(&i_src_file), .txt) %then %let recfm = v; /*variable format*/

    /* Define recfm for CSV files */
    %else %if %index(%lowcase(&i_src_file), .csv) %then %let recfm = v;

    /* Define recfm for sas7bdat files */
    %else %if %index(%lowcase(&i_src_file), .sas7bdat) %then %let recfm = f;

    /* Define the source file */
    filename fsrc "&i_src_file" recfm=&recfm.;

    /* Define the destination file */
    filename fdest "&o_dest_file" recfm=&recfm.;

    /* Copy the file to the destination directory */
    data _null_;
        length msg $ 384;
        rc = fcopy('fsrc', 'fdest');
        if rc ne 0 then do;
            msg = sysmsg();
            put "ERROR: Unable to copy file &i_src_file to &o_dest_file: " msg;
        end;
        else put "INFO: File &i_src_file copied to &o_dest_file";
    run;

    /* Clear the source file */
    %let rc = %sysfunc(filename(fsrc));

    /* Clear the destination file */
    %let rc = %sysfunc(filename(fdest));

%mend copy_file;
/** \endcond */