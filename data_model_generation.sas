/**
    \file
    \ingroup    DATA_MODEL
    \brief      Simulate data for the data model
    \author     Maxime Blouin
    \date       04APR2024
*/ /** \cond */

/* Simulate data for PolicyHolder table */
data PolicyHolder;
    do PolicyHolderID = 1 to 100;
        Name = "PolicyHolder_" || put(PolicyHolderID, 3.);
        Address = "Address_" || put(PolicyHolderID, 3.);
        City = "City_" || put(floor(ranuni(0)*10) + 1, 2.);
        /* Generate Province based on specified distribution */
        rand = ranuni(0);
        if rand <= 0.5 then Province = "QC"; /* 50% chance for QC */
        else if rand <= 0.85 then Province = "ON"; /* 35% chance for ON */
        else Province = "NB"; /* Remaining 15% chance for NB */
        PostalCode = cats(put(floor(ranuni(0)*10), z2.), " ", put(floor(ranuni(0)*10), z2.), " ", put(floor(ranuni(0)*10), z2.), " ", put(floor(ranuni(0)*10), z2.), " ", put(floor(ranuni(0)*10), z2.));
        Phone = cats("555-", put(floor(ranuni(0)*900) + 100, 3.), "-", put(floor(ranuni(0)*9000) + 1000, 4.));
        output;
    end;
run;

/* Simulate data for InsurancePolicy table */
data InsurancePolicy;
    do PolicyID = 1 to 100;
        PolicyHolderID = put(floor(ranuni(0)*100) + 1, 3.);
        StartDate = intnx('month', '01JAN2023'd, -floor(ranuni(0)*24)); /* Random start date within the last 2 years */
        EndDate = intnx('month', StartDate, floor(ranuni(0)*36) + 12); /* Random end date within the next 3 years */
        Premium = round(ranuni(0)*2000, 0.01); /* Random premium amount */
        BrokerID = put(floor(ranuni(0)*10) + 1, 2.);
        CoverageType = ifc(ranuni(0) < 0.5, "Auto", "Property");
        output;
    end;
run;

/* Simulate data for AutoInsurancePolicy table */
data AutoInsurancePolicy;
    set InsurancePolicy;
    if CoverageType = "Auto" then do;
        do VehicleID = 1 to floor(ranuni(0)*5) + 1; /* Simulate 1 to 6 vehicles per policy */
            Make = "Make_" || put(floor(ranuni(0)*5) + 1, 1.);
            Model = "Model_" || put(floor(ranuni(0)*10) + 1, 2.);
            Year = 2022 - floor(ranuni(0)*20); /* Random year between 2002 and 2022 */
            Premium = round(ranuni(0)*1000, 0.01);
            VIN = cats(put(floor(ranuni(0)*10), 1.), put(floor(ranuni(0)*10), 1.), put(floor(ranuni(0)*10), 1.), put(floor(ranuni(0)*10), 1.), put(floor(ranuni(0)*10), 1.), put(floor(ranuni(0)*10), 1.), put(floor(ranuni(0)*10), 1.), put(floor(ranuni(0)*10), 1.), put(floor(ranuni(0)*10), 1.), put(floor(ranuni(0)*10), 1.), put(floor(ranuni(0)*10), 1.), put(floor(ranuni(0)*10), 1.), put(floor(ranuni(0)*10), 1.));
            output;
        end;
    end;
run;

/* Simulate data for PropertyInsurancePolicy table */
data PropertyInsurancePolicy;
    set InsurancePolicy;
    if CoverageType = "Property" then do;
        /* Simulate 1 to 4 properties per policy */
        do PropertyID = 1 to floor(ranuni(0)*3) + 1;
            Address = "Address_" || put(floor(ranuni(0)*100) + 1, 3.);
            Construction = ifc(ranuni(0) < 0.5, "Residential", "Commercial");
            CoverageType = ifc(ranuni(0) < 0.5, "Basic", "Comprehensive");
            Premium = round(ranuni(0)*2000, 0.01);
            BuildingValue = round(ranuni(0)*500000, 0.01);
            ContentsValue = round(ranuni(0)*200000, 0.01);
            output;
        end;
    end;
run;

/* Simulate data for ClaimInformation table */
data ClaimInformation;
    do ClaimID = 1 to 100;
        PolicyID = floor(ranuni(0)*100) + 1;
        ClaimDate = intnx('month', '01JAN2023'd, -floor(ranuni(0)*24)); /* Random claim date within the last 2 years */
        Description = "Description_" || put(floor(ranuni(0)*10) + 1, 2.);
        ClaimAmount = round(ranuni(0)*5000, 0.01); /* Random claim amount */
        ClaimStatus = ifc(ranuni(0) < 0.8, "Paid", "Pending");
        output;
    end;
run;

/* Simulate data for EarnedPremium table */
data EarnedPremium;
    /* Seed for random number generation */
    call streaminit(123);

    /* Generate simulated data */
    do PolicyID = 1 to 100;
        EffectiveDate = intnx('month', '01JAN2024'd, ceil(12*ranuni(123)));
        ExpirationDate = intnx('month', EffectiveDate, ceil(24*ranuni(123)));
        PolicyHolderID = 'PH00' || compress(put(int(1 + 1000*ranuni(123)), z3.));
        PolicyType = ifc(ranuni(123) < 0.5, 'Auto', 'Property');
        PremiumAmount = 5000 + int(5000*ranuni(123));
        GeographicRegion = ifc(ranuni(123) < 0.5, 'Ontario', 'Quebec');
        PaymentStatus = ifc(ranuni(123) < 0.8, 'Paid', 'Unpaid');
        PolicyStatus = 'Active';
        PolicyDuration = int(12 + 12*ranuni(123)); /* Number of months */
        output;
    end;
run;

/* Calculate Loss Ratio */
proc sql;
    /* Create a temporary table to store policy-level loss and earned premium */
    create table LossRatioTemp as
    select
        ip.PolicyID,
        coalesce(sum(ci.ClaimAmount), 0) as TotalClaims,
        sum(ip.PremiumAmount) as EarnedPremium
    from
        EarnedPremium ip
    left join
        ClaimInformation ci
    on
        ip.PolicyID = ci.PolicyID
    group by
        ip.PolicyID;

    /* Calculate loss ratio */
    create table LossRatio as
    select
        PolicyID,
        TotalClaims,
        EarnedPremium,
        TotalClaims / EarnedPremium as LossRatio
    from
        LossRatioTemp;
quit;

/** \endcond */