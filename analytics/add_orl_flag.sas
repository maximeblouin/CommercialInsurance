/**
    \file
    \ingroup    ANALYTICS
    \brief      SAS macro for overall rate level (ORL) analysis.
    \details    This macro adds an 'orl_flag' variable to a dataset, indicating
                whether to include or exclude certain records based on specific criteria.
    \author     Maxime Blouin
    \date       08APR2024
    \param      i_dataset_name      Specifies the name of the dataset to process (default=_LAST_).
    \param      i_claim_data        Specifies whether the data represents claims (1) or risks (0) (default=0).
    \param      o_dataset_name      Specifies the name of the output dataset (default=the input dataset name).
    \param      flag_variable_name  Specifies the name of the flag variable (default='orl_flag').
    \return     A dataset with an added orl_flag variable indicating whether to include (1) or exclude (0).
*/

/** \cond */

%macro add_orl_flag(
    i_dataset_name=_LAST_ /*Specifies the name of the dataset to process.*/,
    i_claim_data=0 /*Specifies whether the data represents claims (1) or risks (0).*/,
    o_dataset_name= /*Specifies the name of the output dataset.*/,
    flag_variable_name=orl_flag /*Specifies the name of the flag variable.*/);

    /* Parameter Validation */
    %if not %length(&o_dataset_name) %then %let o_dataset_name = &i_dataset_name;
    %if %sysfunc(exist(&i_dataset_name)) = 0 %then %do;
        %put ERROR: Dataset &i_dataset_name does not exist.;
        %return;
    %end;

    /* Error Control */
    /* Check if required variables exist in the dataset.*/
    %if %varexist(&i_dataset_name., coverage_class) = 0 %then %do;
        %put ERROR: Variable 'coverage_class' not found in dataset &i_dataset_name.;
        %return;
    %end;
    %if %varexist(&i_dataset_name., province_code) = 0 %then %do;
        %put ERROR: Variable 'province_code' not found in dataset &i_dataset_name.;
        %return;
    %end;
    %if %varexist(&i_dataset_name., business_activity) = 0 %then %do;
        %put ERROR: Variable 'business_activity' not found in dataset &i_dataset_name.;
        %return;
    %end;
    %if &i_claim_data. = 1 %then %do;
        %if %varexist(&i_dataset_name., catastrophe_flag) = 0 %then %do;
            %put ERROR: Variable 'catastrophe_flag' not found in dataset &i_dataset_name.;
            %return;
        %end;
    %end;

    /* Error Control */
    /* Check if the 'flag_variable_name' variable exists in the dataset. If so, delete it. */
    %if %varexist(&i_dataset_name., &flag_variable_name) = 1 %then %do;
        proc datasets lib=work nolist;
            modify &i_dataset_name.;
            drop &flag_variable_name;
        run;
        quit;
    %end;

    data &o_dataset_name;
        set &i_dataset_name;
        length &flag_variable_name $1.;
        label &flag_variable_name="ORL Include/Exclude Flag";

        /* ORL Risk/Claims exclusions based on coverage class */
        if upcase(coverage_class) in ("BUILDER'S RISK - BLANKET", "SEWER BACKUP",
            "EQUIPMENT BREAKDOWN", "FLOOD", "CYBER", "SURETY BOND", "FARM", "EARTHQUAKE") then &flag_variable_name="0";
        /* OAW ORL Risk/Claims exclusions based on business activity */
        else if upcase(province_code) in ('AB', 'NB', 'ON') and upcase(business_activity) in ("HOSPITALITY-LICENSED", "HOSPITALITY-BARS", "SNOW REMOVAL") then &flag_variable_name="0";
        /* ORL claims exclusions based on catastrophe indicator */
        %if &i_claim_data. = 1 %then %do;
            else if upcase(catastrophe_flag) eq "Y" then &flag_variable_name="0";
        %end;
        else &flag_variable_name="1";
    run;

    %put NOTE: ORL flag added to dataset &o_dataset_name.;

%mend add_orl_flag;
/** \endcond */
