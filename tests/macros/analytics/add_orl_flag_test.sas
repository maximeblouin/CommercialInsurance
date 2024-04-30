
proc sql;
    create table WORK.loss_insurance (
        coverage_class char(50),
        catastrophe_flag char(1),
        province_code char(2),
        business_activity char(50)
    );
quit;

/* Convert data using PROC SQL insert into */
proc sql;
    insert into loss_insurance (coverage_class, catastrophe_flag, province_code, business_activity)
    values ("Builder's Risk",               'N', 'AB', 'Hospitality-Licensed')
    values ("Builder's Risk - Per Project", 'Y', 'NB', 'N/D')
    values ('Enol',                         'N', 'ON', 'N/D')
    values ('Inland Marine',                'Y', 'NB', 'N/D')
    values ('Manual Form',                  'N', 'NB', 'N/D')
    values ('Manual Form',                  'N', 'ON', 'Snow Removal')
    values ('N/D',                          'Y', 'QC', 'N/D');
quit;

/* Test the add_orl_flag macro */
%add_orl_flag(
    i_dataset_name=loss_insurance,
    i_claim_data=1,
    o_dataset_name=loss_insurance
);

proc sql;
    create table WORK.prem_insurance (
        coverage_class char(50),
        province_code char(3),
        business_activity char(50)
    );
quit;

/* Convert data using PROC SQL insert into */
proc sql;
    insert into prem_insurance (coverage_class, province_code, business_activity)
    values ("Builder's Risk",               'AB', 'Hospitality-Licensed')
    values ("Builder's Risk - Per Project", 'NB', 'N/D')
    values ('Enol',                         'ON', 'N/D')
    values ('Inland Marine',                'NB', 'N/D')
    values ('Manual Form',                  'NB', 'N/D')
    values ('Manual Form',                  'ON', 'Snow Removal')
    values ('N/D',                          'QC', 'N/D');
quit;

/* Test the add_orl_flag macro */
%add_orl_flag(
    i_dataset_name=prem_insurance,
    i_claim_data=0,
    o_dataset_name=prem_insurance
);