


data sample_data;
    input id name $ gender $ age;
    datalines;
1 John M 25
2 Alice F 30
3 Bob M 35
4 Mary F 40
;
run;

proc format;
    value $gender
    'M' = 'Male'
    'F' = 'Female'
    ;

    value age_group
    low - 20 = 'Under 20'
    21 - 30 = '21-30'
    31 - 40 = '31-40'
    41 - high = 'Over 40'
    ;
run;
/* Apply the format to the dataset */
proc datasets library=work nodetails;
    modify sample_data;
    format gender $gender. age age_group.;
quit;

%data_dictionary(
    i_project=SasHelp Data,
    i_dslist=stpsamp.* sashelp.cars sample_data,
    o_htmlpath=%sysfunc(pathname(HOME))/CommercialInsurance/doc/dict,
    o_framename=data_dict.htm);

%put _ALL_;
