/*==============================================================
 1. Create multi-row balanced sample datasets
==============================================================*/
data base_data;
    input Region $ Product $ Sales;
    datalines;
East A 118
East A 122
East A 120
East B 130
East B 129
East B 131
North A 150
North A 151
North A 149
North B 160
North B 162
North B 158
South A 125
South A 124
South A 126
West A 110
West A 111
West A 112
;
run;

data compare_data;
    input Region $ Product $ Sales;
    datalines;
East A 122
East A 124
East A 123
East B 128
East B 127
East B 129
North A 155
North A 156
North A 157
North B 165
North B 166
North B 167
South A 120
South A 121
South A 122
West A 115
West A 114
West A 116
;
run;

/*==============================================================
 2. Run the macro
==============================================================*/
%compare_numeric_by_classes(
    i_dsn_base=base_data,
    i_dsn_compare=compare_data,
    i_classes=Region Product,
    i_variable=Sales,
    i_threshold=0.05,
    out=test_results
);

/*==============================================================
 3. Inspect results
==============================================================*/
title "🧪 Macro Test Results: base_data vs compare_data";
proc print data=test_results noobs label;
run;
title;
