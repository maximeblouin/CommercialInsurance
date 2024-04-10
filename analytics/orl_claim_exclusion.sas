/**
    \file
    \ingroup    MACRO
    \brief      Macro function to exclude claim from overall rate level (ORL) analysis.
    \author     Maxime Blouin
    \date       08APR2024
    \param      i_CoverageClass Indicates the type of coverage class.
    \param      i_Region Denotes the region of the claim.
    \param      i_BusinessActivity Specifies the business activity associated with the claim.
    \param      i_CatastropheFlag Indicates whether the claim is related to a catastrophe.
    \return     INCLUDE or EXCLUDE
*/

/** \cond */

%macro orl_claim_exclusion(
    i_CoverageClass /*Indicates the type of coverage class.*/,
    i_RegionCode /*Denotes the region of the claim.*/,
    i_BusinessActivity /*Specifies the business activity associated with the claim.*/,
    i_CatastropheFlag /*Indicates whether the claim is related to a catastrophe.*/
    ) / minoperator mindelimiter=',';

    /* Error Control for i_CatastropheFlag */
    %if (%upcase(&i_CatastropheFlag.) in ("Y", "N")) %then;
    %else %put WARNING: The value orl_exclusion.i_CatastropheFlag(&i_CatastropheFlag.) is not handled.;

    %orl_exclusion(
        &i_CoverageClass.,
        &i_RegionCode.,
        &i_BusinessActivity.,
        &i_CatastropheFlag.);

%mend orl_claim_exclusion;

/** \endcond */
