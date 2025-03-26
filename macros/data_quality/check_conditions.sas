/**
    \file
    \ingroup    DATA_QUALITY
    \brief      Check conditions macro
    \details    This macro checks conditions based on validation rules
                and filters.
    \author     Maxime Blouin
    \date       26MAR2025
    \param      i_dsn The dataset to check
    \param      i_dsn_rules The dataset containing the validation rules
    \param      o_dsn_results The output dataset
    \remark     input dataset structure:
                    ValidationRule char(200) [Rule to validate]
                    Filter char(200) [A rule for all observations, use 1]
                    Threshold num [Threshold for the rule]
    \remark     output dataset structure:
                    ValidationRule char(200) [Copied from i_dsn_rules]
                    Filter char(200) [Copied from i_dsn_rules]
                    Threshold num [Copied from i_dsn_rules]
                    NumberOfObs int
                    NumberOfPass int
                    PercentPass num
                    RuleStatus => PASS or FAILED
*/ /** \cond */

%macro check_conditions(
    i_dsn,
    i_dsn_rules=1,
    o_dsn_results=work.checks_results);

    /* Create output dataset from input dataset. */
    data &o_dsn_results;
        length
            ValidationRule $200
            Filter $200
            Threshold 8
            NumberOfObs 8
            NumberOfPass 8
            PercentPass 8
            RuleStatus $10;
    run;

    /* Remove empty observations */
    proc sql;
        delete from &o_dsn_results where ValidationRule eq "";
    quit;

    /* Read validation rules */
    proc sql noprint;
        select ValidationRule, Filter, Threshold into
            :rule1-,
            :filter1-,
            :threshold1-
        from &i_dsn_rules;
        %let num_rules = &sqlobs;
    quit;

    /* Loop through validation rules */
    %do i = 1 %to &num_rules;
        %let rule = &&rule&i;
        %let filter = &&filter&i;
        %let threshold = &&threshold&i;

        /* Apply filters and check conditions */
        proc sql noprint;
            select count(*) into :num_obs from &i_dsn where &filter;
            select count(*) into :num_pass from &i_dsn where &filter and &rule;
        quit;

        /* Calculate percentage of PASS conditions */
        %if &num_obs > 0 %then %let percent_pass = %sysevalf((&num_pass / &num_obs));
        %else %let percent_pass = 0;

        /* Determine Pass/Fail */
        %if &percent_pass >= &threshold %then %let rule_status = PASS;
        %else %let rule_status = FAILED;

        /* Append results */
        proc sql;
            insert into &o_dsn_results
            values (
                "%superq(rule)",
                "%superq(filter)",
                &threshold,
                &num_obs,
                &num_pass,
                &percent_pass,
                "&rule_status");
        quit;
    %end;

%mend check_conditions;

/** \endcond */