/**
    \file       copy_files.sas
    \ingroup    MACROS_HELPERS
    \brief      Copy files from a directory to another directory
    \detail     Copy files from a directory to another directory using regular expression pattern to match files
    \author     Maxime Blouin
    \date       25AUG2024
    \version    1.0
    \param[in]  i_src_dir Full path of the source directory
    \param[out] i_dest_dir Full path of the destination directory
    \param[in]  i_prx_pattern Regular expression pattern to match files to copy, default is .*
    \remark
    >>    %copy_files(
    >>        i_src_dir = /path/to/source/directory,
    >>        o_dest_dir = /path/to/destination/directory,
    >>        i_prx_pattern = .*\.(sas7bdat|sas7bcat)
    >>    );
    \remark    Version 1.0 - 25AUG2024 - Initial version of the macro
*/ /** \cond */
%macro copy_files(
    i_src_dir /*Full path of the source directory*/,
    o_dest_dir /*Full path of the destination directory*/,
    i_prx_pattern=.* /*Regular expression pattern to match files to copy, default is .**/);

    %let rc = %sysfunc(filename(src_dir, &i_src_dir));

    /* Open the source directory */
    %let did = %sysfunc(dopen(&src_dir));

    /* Check if the source directory is open */
    %if &did eq 0 %then %do;
        %put ERROR: Unable to open the source directory;
        %return;
    %end;

    /* Compile the regular expression pattern */
    %let pattern = %sysfunc(prxparse(/&i_prx_pattern/));

    /* Check if the pattern compiled successfully */
    %if &pattern eq 0 %then %do;
        %put ERROR: Invalid regular expression pattern;
        %return;
    %end;

    /* Loop through the files in the source directory */
    %do i = 1 %to %sysfunc(dnum(&did));
        /* Get the name of the file */
        %let file = %sysfunc(dread(&did, &i));

        %let prx_match = %sysfunc(prxmatch(&pattern, &file));

        /* Check if the file matches the regular expression pattern */
        %if &prx_match. > 0 %then %do;
            %copy_file(
                i_src_file = &i_src_dir./&file,
                o_dest_file = &o_dest_dir./&file
            );
        %end;
    %end;

    /* Close the source directory */
    %let rc = %sysfunc(dclose(&did));

    /* Free the source directory fileref */
    %let rc = %sysfunc(filename(src_dir));

%mend copy_files;
/** \endcond */