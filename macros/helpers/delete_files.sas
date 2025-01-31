/**
    \file
    \ingroup    HELPERS
    \brief      Delete all files in a directory amd subdirectories.
    \author     Maxime Blouin
    \date       01MAY2024
    \parm       i_path Full path of directory
    \parm       i_recursive 1: Search recursively in subdirectories, default is 0
    \remark     Example: %delete_files(i_dir=&SASUSERS.env_sas\doc\sasunit, i_recursive=1);
*/ /** \cond */
%macro delete_files(
    i_path /*Full path of directory*/,
    i_recursive=0);

    /* Step 1: Get files in directory (and subdirectories).*/
    %_dir(
        i_path=&i_path.,
        i_recursive=&i_recursive.,
        o_out=work.files_to_delete);

    /* Step 2: Delete files in directory (and subdirectories).*/
    data _null_;
        set files_to_delete;

        fname = "tempfile";
        rc = filename(fname, filename);
        if rc = 0 and fexist(fname) then rc = fdelete(fname);
        rc = filename(fname);
    run;

    %delete_dataset(
        i_table=files_to_delete,
        i_library=work);

%mend delete_files;
/** \endcond */