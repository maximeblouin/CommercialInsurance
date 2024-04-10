/**
    \file
    \ingroup    MACRO
    \brief      Macro function to exclude risk from overall rate level (ORL) analysis.
    \author     Maxime Blouin
    \date       08APR2024
    \param      i_CoverageClass Indicates the type of coverage class.
    \param      i_Region Denotes the region of the claim.
    \param      i_BusinessActivity Specifies the business activity associated with the claim.
    \return     INCLUDE or EXCLUDE
*/

/** \cond */

%macro orl_risk_exclusion(
    i_CoverageClass /*Indicates the type of coverage class.*/,
    i_RegionCode /*Denotes the region of the claim.*/,
    i_BusinessActivity /*Specifies the business activity associated with the claim.*/
    ) / minoperator mindelimiter=',';

    %orl_exclusion(
        &i_CoverageClass.,
        &i_RegionCode.,
        &i_BusinessActivity.);

%mend orl_risk_exclusion;

/** \endcond */