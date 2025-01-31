/**
    \file
    \ingroup    HELPERS
    \brief      Compress a file in a zip archive
    \author     Maxime Blouin
    \date       22JUL2024
    \parm       i_file Full path of the file to compress
    \parm       o_archive_name Name of the archive without the path
    \parm       o_archive_path Full path where the archive will be saved
    \remark     Example: %compress_file(
                            i_file=&SASUSERS.env_sas\doc\sasunit\example.sas,
                            o_archive_name=example_archive.zip,
                            o_archive_path=&SASUSERS.env_sas\doc\sasunit);
*/ /** \cond */
%macro compress_file(
    i_file /* The file to compress */,
    o_archive_name /* The name of the archive without the path */,
    o_archive_path /* The Full path where the archive will be saved */
);

    ODS PACKAGE OPEN NOPF;

    ODS PACKAGE ADD FILE="&i_file." mimetype="application/x-comress" path="";

    ODS PACKAGE PUBLISH ARCHIVE PROPERTIES(ARCHIVE_NAME="&o_archive_name." ARCHIVE_PATH="&o_archive_path");
    ODS PACKAGE CLOSE;

%mend compress_file;
/** \endcond */