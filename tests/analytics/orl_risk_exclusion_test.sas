
proc sql;
    create table WORK.prem_insurance (
        coverage_class char(50),
        region_code char(3),
        business_activity char(50)
    );
quit;

/* Convert data using PROC SQL insert into */
proc sql;
    insert into prem_insurance (coverage_class, region_code, business_activity)
    values ("Builder's Risk", 'OAW', 'Hospitality-Licensed')
    values ("Builder's Risk - Per Project", 'OAW', 'N/D')
    values ('Enol', 'OAW', 'N/D')
    values ('Inland Marine', 'OAW', 'N/D')
    values ('Manual Form', 'OAW', 'Snow Removal')
    values ('N/D', 'QC', 'N/D');
quit;

data prem_insurance;
    set prem_insurance;

    length exclusion_flag $ 7;

    exclusion_flag=resolve('%orl_risk_exclusion('||
        'i_CoverageClass="'||trim(coverage_class)||'",'||
        'i_RegionCode="'||trim(region_code)||'",'||
        'i_BusinessActivity="'||trim(business_activity)||'")');
run;
