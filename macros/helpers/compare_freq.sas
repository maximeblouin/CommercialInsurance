%macro compare_freq(var, ds1, ds2, out=compare_results);

    /* Step 1: Calculate Frequencies */
    proc freq data=&ds1 noprint;
        tables &var / missing out=ds1_freq(drop=percent);
    run;

    proc freq data=&ds2 noprint;
        tables &var / missing out=ds2_freq(drop=percent);
    run;

    /* Step 2: Merge Frequency Tables */
    proc sort data=ds1_freq; by &var; run;
    proc sort data=ds2_freq; by &var; run;

    data merged_freq;
        merge ds1_freq(in=a) ds2_freq(in=b);
        by &var;
        if a or b;
    run;

    /* Step 3: Perform Chi-Square Test */
    proc freq data=merged_freq;
        tables &var / chisq expected;
        weight count;
        ods output ChiSq=chi_square;
    run;

    /* Step 4: Output Results */
    data &out;
        set chi_square;
    run;

    /* Clean up temporary datasets */
    proc datasets library=work nolist;
        delete ds1_freq ds2_freq merged_freq chi_square;
    quit;

%mend compare_freq;