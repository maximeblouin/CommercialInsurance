/**
    \file
    \ingroup    MACRO
    \brief      Macro function to exclude claim or risk from overall rate level (ORL) analysis.
    \author     Maxime Blouin
    \date       08APR2024
    \param      i_CoverageClass Indicates the type of coverage class.
    \param      i_RegionCode Denotes the region.
    \param      i_BusinessActivity Specifies the business activity.
    \param      i_CatastropheFlag If a claim, indicates whether the claim is related to a catastrophe.
    \return     INCLUDE or EXCLUDE
*/

/** \cond */

%macro orl_exclusion(
    i_CoverageClass /*Indicates the type of coverage class*/,
    i_RegionCode /*Denotes the region*/,
    i_BusinessActivity /*Specifies the business activity*/,
    i_CatastropheFlag /*If a claim, indicates whether the claim is related to a catastrophe.*/
    ) / minoperator mindelimiter=',';

    /* Error Control for i_CoverageClass */
    %if (%upcase(&i_CoverageClass.) in ("BUILDER'S RISK", "EQUIPMENT BREAKDOWN",
        "BUILDER'S RISK - PER PROJECT", "BUILDER'S RISK - BLANKET", "ENOL",
        "INLAND MARINE", "SEWER BACKUP", "MANUAL FORM", "N/D", "FLOOD", "SURETY BOND",
        "FARM", "EARTHQUAKE")) %then;
    %else %put WARNING: The value orl_exclusion.i_CoverageClass(&i_CoverageClass.) is not handled.;

    /* Error Control for i_RegionCode */
    %if (%upcase(&i_RegionCode.) in ("QC", "OAW")) %then;
    %else %put WARNING: The value orl_exclusion.i_RegionCode(&i_RegionCode.) is not handled.;

    /* ORL exclusions based on coverage class */
    %if %upcase(&i_CoverageClass.) in ("BUILDER'S RISK - PER PROJECT", "EQUIPMENT BREAKDOWN", "SEWER BACKUP", "FLOOD", "SURETY BOND", "FARM", "EARTHQUAKE") %then %do;
        EXCLUDE
        %return;
    %end;

    /* OAW ORL exclusions based on business activity */
    %if %upcase(&i_RegionCode.) = "OAW" %then %do;
        %if %upcase(&i_BusinessActivity.) in ("HOSPITALITY-LICENSED", "HOSPITALITY-BARS", "SNOW REMOVAL") %then %do;
            EXCLUDE
            %return;
        %end;
    %end;

    /* ORL exclusions based on catastrophe indicator */
    %if %upcase(&i_CatastropheFlag.) = "Y" %then %do;
        EXCLUDE
        %return;
    %end;

    INCLUDE

%mend orl_exclusion;
/** \endcond */