/**
    \file
    \ingroup    MACROS_ANALYTICS_TEST
    \author     Maxime Blouin
    \date       07JUL2024
*/

/** \cond */

%initScenario(i_desc=Unit tests for macro count_claims);

%initTestCase(i_object=count_claims, i_desc=Test claims counting);

/* Generate test data */
data claim_count_expected;
    input ansin nodoss $ coverage $ nbDoss;
    datalines;
2022 Claim1 PROP 1
2022 Claim1 PROP 0
2022 Claim2 PROP 1
2022 Claim2 RESP 1
2022 Claim3 RESP 1
2023 Claim3 RESP 1
;
run;

/* Generate test data */
data claim_count_actual;
    input ansin nodoss $ coverage $;
    datalines;
2022 Claim1 PROP
2022 Claim1 PROP
2022 Claim2 PROP
2022 Claim2 RESP
2022 Claim3 RESP
2023 Claim3 RESP
;
run;

/* Run the macro with the test data */
%count_claims(claim_count_actual);

%endTestCall();

%assertColumns(
    i_expected=work.claim_count_expected,
    i_actual=work.claim_count_actual,
    i_desc=Check claims counter
)

%assertPerformance(i_expected=1);

%assertLog(i_errors=0, i_warnings=0);

%endTestCase();

%endScenario();

/** \endcond */