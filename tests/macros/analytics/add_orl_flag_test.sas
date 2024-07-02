/**
    \file
    \ingroup    MACROS_ANALYTICS_TEST
    \author     Maxime Blouin
    \date       07JUL2024
*/

/** \cond */

%initScenario(i_desc=Unit tests for macro add_orl_flag);

%initTestCase(i_object=add_orl_flag, i_desc=Test addition of ORL flag for losses);

proc sql;
    create table work.loss_insurance_expected (
        coverage_class char(50),
        catastrophe_flag char(1),
        province_code char(2),
        business_activity char(50),
        orl_flag char(1)
    );

    /* Insert data */
    insert into work.loss_insurance_expected (coverage_class, catastrophe_flag, province_code, business_activity, orl_flag)
    values ("Builder's Risk",               'N', 'AB', 'Hospitality-Licensed',  '0')
    values ("Builder's Risk - Per Project", 'Y', 'NB', 'N/D',                   '0')
    values ('Enol',                         'N', 'ON', 'N/D',                   '1')
    values ('Inland Marine',                'Y', 'NB', 'N/D',                   '0')
    values ('Manual Form',                  'N', 'NB', 'N/D',                   '1')
    values ('Manual Form',                  'N', 'ON', 'Snow Removal',          '0')
    values ('N/D',                          'Y', 'QC', 'N/D',                   '0');
quit;

proc sql;
    create table work.loss_insurance_actual (
        coverage_class char(50),
        catastrophe_flag char(1),
        province_code char(2),
        business_activity char(50)
    );

    /* Insert data */
    insert into work.loss_insurance_actual (coverage_class, catastrophe_flag, province_code, business_activity)
    values ("Builder's Risk",               'N', 'AB', 'Hospitality-Licensed')
    values ("Builder's Risk - Per Project", 'Y', 'NB', 'N/D')
    values ('Enol',                         'N', 'ON', 'N/D')
    values ('Inland Marine',                'Y', 'NB', 'N/D')
    values ('Manual Form',                  'N', 'NB', 'N/D')
    values ('Manual Form',                  'N', 'ON', 'Snow Removal')
    values ('N/D',                          'Y', 'QC', 'N/D');
quit;

/* Apply ORL exclusion flag on losses */
%add_orl_flag(
    i_dataset_name=loss_insurance_actual,
    i_claim_data=1,
    o_dataset_name=loss_insurance_actual
);

%endTestCall();

%assertColumns(
    i_expected=work.loss_insurance_expected,
    i_actual=work.loss_insurance_actual,
    i_desc=Check ORL flag for losses
)

%assertPerformance(i_expected=1);

%assertLog(i_errors=0, i_warnings=0);

%endTestCase();


%initTestCase(i_object=add_orl_flag, i_desc=Test addition of ORL flag for premiums);

proc sql;
    create table work.prem_insurance_expected (
        coverage_class char(50),
        province_code char(3),
        business_activity char(50),
        orl_flag char(1)
    );

    /* Insert data */
    insert into work.prem_insurance_expected (coverage_class, province_code, business_activity, orl_flag)
    values ("Builder's Risk",               'AB', 'Hospitality-Licensed',   '0')
    values ("Builder's Risk - Per Project", 'NB', 'N/D',                    '1')
    values ('Enol',                         'ON', 'N/D',                    '1')
    values ('Inland Marine',                'NB', 'N/D',                    '1')
    values ('Manual Form',                  'NB', 'N/D',                    '1')
    values ('Manual Form',                  'ON', 'Snow Removal',           '0')
    values ('N/D',                          'QC', 'N/D',                    '1');
quit;




proc sql;
    create table work.prem_insurance_actual (
        coverage_class char(50),
        province_code char(3),
        business_activity char(50)
    );

    /* Insert data */
    insert into work.prem_insurance_actual (coverage_class, province_code, business_activity)
    values ("Builder's Risk",               'AB', 'Hospitality-Licensed')
    values ("Builder's Risk - Per Project", 'NB', 'N/D')
    values ('Enol',                         'ON', 'N/D')
    values ('Inland Marine',                'NB', 'N/D')
    values ('Manual Form',                  'NB', 'N/D')
    values ('Manual Form',                  'ON', 'Snow Removal')
    values ('N/D',                          'QC', 'N/D');
quit;

/* Apply ORL exclusion flag on premiums */
%add_orl_flag(
    i_dataset_name=prem_insurance_actual,
    i_claim_data=0,
    o_dataset_name=prem_insurance_actual
);

%endTestCall();

%assertColumns(
    i_expected=work.prem_insurance_expected,
    i_actual=work.prem_insurance_actual,
    i_desc=Check ORL flag for premiums
)

%assertPerformance(i_expected=1);

%assertLog(i_errors=0, i_warnings=0);

%endTestCase();

%endScenario();

/** \endcond */