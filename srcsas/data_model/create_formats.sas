/**
    \file
    \ingroup    DATA_MODEL
    \brief      Define formats
    \author     Maxime Blouin
    \date       04APR2024
*/ /** \cond */

/* Define custom format for province code */
proc format;
    value $province_fmt
        'QC' = 'Quebec'
        'ON' = 'Ontario'
        'NB' = 'New Brunswick';
        /* Add more province codes and corresponding labels as needed */
run;

/** \endcond */