/**
    \file
    \ingroup    DATA_MODEL
    \brief      Define formats for commercial insurance data model
    \author     Maxime Blouin
    \date       04APR2024
*/ /** \cond */

proc format;
    /* Format for province code */
    value $province_fmt
        'AB' = 'Alberta'
        'BC' = 'British Columbia'
        'MB' = 'Manitoba'
        'NB' = 'New Brunswick'
        'NL' = 'Newfoundland and Labrador'
        'NT' = 'Northwest Territories'
        'NS' = 'Nova Scotia'
        'NU' = 'Nunavut'
        'ON' = 'Ontario'
        'PE' = 'Prince Edward Island'
        'QC' = 'Quebec'
        'SK' = 'Saskatchewan'
        'YT' = 'Yukon';

    /* Format for region code */
    value $region_fmt
        'QC' = 'Quebec'
        'OAW' = 'Ontario and West';
run;
/** \endcond */