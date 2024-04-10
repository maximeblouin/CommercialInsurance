
proc sql;
    create table WORK.loss_insurance (
        coverage_class char(50),
        catastrophe_flag char(1),
        province_code char(2),
        region_code char(3),
        business_activity char(50)
    );
quit;

/* Convert data using PROC SQL insert into */
proc sql;
    insert into loss_insurance (coverage_class, catastrophe_flag, province_code, region_code, business_activity)
    values ("Builder's Risk", 'N', 'AB', 'OAW', 'Hospitality-Licensed')
    values ("Builder's Risk - Per Project", 'Y', 'NB', 'OAW', 'N/D')
    values ('Enol', 'N', 'ON', 'OAW', 'N/D')
    values ('Inland Marine', 'Y', 'NB', 'OAW', 'N/D')
    values ('Manual Form', 'N', 'NB', 'OAW', 'N/D')
    values ('Manual Form', 'N', 'ON', 'OAW', 'Snow Removal')
    values ('N/D', 'Y', 'QC', 'QC', 'N/D');
quit;

data loss_insurance;
    set loss_insurance;

    length exclusion_flag $ 7;

    exclusion_flag=resolve('%orl_claim_exclusion('||
        'i_CoverageClass="'||trim(coverage_class)||'",'||
        'i_RegionCode="'||trim(region_code)||'",'||
        'i_BusinessActivity="'||trim(business_activity)||'",'||
        'i_CatastropheFlag="'||catastrophe_flag||'")');  /* macro invocation */
run;

