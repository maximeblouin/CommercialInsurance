/**
    \file
    \ingroup    MACROS_HELPERS
    \brief      Replace old_string by new_string in a text file
    \author     Maxime Blouin
    \date       22JUL2024
    \details    Example:
        %replace_text_in_file(
            i_input_file = 'C:\path\to\your\input.txt',
            i_output_file = 'C:\path\to\your\output.txt',
            i_find_string = old_string,
            i_replace_string = new_string,
            i_encoding = 'utf-16'
        );

    \param  i_input_file the input file
    \param  i_output_file the output file
    \param  i_find_string the string to find
    \param  i_replace_string the string to replace
    \param  i_encoding the encoding of the file
*/ /** \cond */
%macro replace_text_in_file(
    i_input_file /* the input file */,
    i_output_file /* the output file */,
    i_find_string /* the string to find */,
    i_replace_string /* the string to replace */,
    i_encoding = 'utf-8' /* the encoding of the file */
);

    /* Read the text file into a data set */
    data _null_;
        infile &i_input_file lrecl=32767 truncover;
        file &i_output_file encoding=&i_encoding;
        input;
        _infile_ = tranwrd(_infile_, &i_find_string, &i_replace_string);
        put _infile_;
    run;
%mend replace_text_in_file;
/** \endcond */