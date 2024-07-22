/**
    \file
    \ingroup    MACROS_HELPERS
    \brief      Return the folder path of a filename or pathname
    \details    Extract the folder path from a given file path by finding the
        position of the last backslash and then extracting the substring up
        to that point.

        Example:
        %let file_path = C:\path\to\your\file.txt;
        %let path = %get_folder_path(&file_path.);
    \author     Maxime Blouin
    \date       22JUL2024
    \param      file_path     the file path
    \return     the folder path
*/ /** \cond */
%macro get_folder_path(
    file_path /* the file path */
);
    %local i_last_backslash_position i_length i_folder_path;

    /* Find the position of the last backslash (\) */
    %let i_last_backslash_position = %eval(%length(&file_path) - %length(%scan(&file_path, -1, \)) - 1);

    /* Extract the substring up to the last backslash */
    %let i_folder_path = %substr(&file_path, 1, &i_last_backslash_position);

    /* Return the folder path */
    &i_folder_path

%mend get_folder_path;
/** \endcond */