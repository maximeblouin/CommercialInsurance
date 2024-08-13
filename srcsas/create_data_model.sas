/**
    \file
    \ingroup    DATA_MODEL
    \brief      Create tables for the fact schema
    \author     Maxime Blouin
    \date       04APR2024
    \remark     Tables created:
                - fact.AutoInsurancePolicy
                - fact.ClaimInformation
                - fact.EarnedPremium
                - fact.InsurancePolicy
                - fact.InsuranceTransaction
                - fact.LossCatastrophe
                - fact.LossRatio
                - fact.PolicyHolder
*/ /** \cond */
proc sql;
    create table fact.AutoInsurancePolicy (
        VehicleID char(10) label="Vehicle ID" primary key,
        PolicyID char(10) label="Policy ID",
        Make char(50) label="Vehicle Make",
        Model char(50) label="Vehicle Model",
        VehiculeYear num label="Vehicle Year",
        Premium numeric(10,2) format=dollar32.2 label="Policy Premium",
        VIN char(17) label="Vehicle Identification Number"
        /* Constraint Specifications */
    );

    create table fact.Catastrophe (
        CatastropheID char(10) label="Catastrophe ID" primary key,
        CatastropheDate date format=date9. label="Catastrophe Date",
        CatastropheType char(50) label="Catastrophe Type",
        CatastropheDescription char(100) label="Catastrophe Description",
        CatastropheAmount numeric(10,2) format=dollar32.2 label="Catastrophe Amount"
        /* Constraint Specifications */
    );

    create table fact.ClaimInformation (
        ClaimID char(10) label="Claim ID" primary key,
        PolicyID char(10) label="Policy ID",
        ClaimDate date format=date9. label="Claim Date",
        Description char(100) label="Claim Description",
        ClaimAmount numeric(10,2) format=dollar32.2 label="Claim Amount",
        ClaimStatus char(20) label="Claim Status"
        /* Constraint Specifications */
    );

    create table fact.EarnedPremium (
        PolicyID char(10) label="Policy ID" primary key,
        EffectiveDate date format=date9. label="Effective Date",
        ExpirationDate date format=date9. label="Expiration Date",
        PolicyHolderID char(10) label="Policy Holder ID",
        PolicyType char(50) label="Policy Type",
        PremiumAmount numeric(10,2) format=dollar32.2 label="Premium Amount",
        GeographicRegion char(50) label="Geographic Region",
        PaymentStatus char(20) label="Payment Status",
        PolicyStatus char(20) label="Policy Status",
        PolicyDuration num label="Policy Duration" /* Number of months */
        /* Constraint Specifications */
    );

    create table fact.InsurancePolicy (
        PolicyID char(10) label="Policy ID" primary key,
        PolicyHolderID char(10) label="Policy Holder ID",
        StartDate date format=date9. label="Policy Start Date",
        EndDate date format=date9. label="Policy End Date",
        WrittenPremium numeric(10,2) format=dollar32.2 label="Written Premium",
        PolicyType char(20) label="Policy Type",
        PolicyStatus char(20) label="Policy Status",
        BrokerID char(10) label="Broker ID",
        CoverageType char(50) label="Coverage Type",
        BusinessCategory char(50) label="Business Category"
        /* Constraint Specifications */
    );

    create table fact.InsuranceTransaction (
        TransactionID char(10) label="Transaction ID" primary key,
        PolicyID char(10) label="Policy ID",
        TransactionDate date format=date9. label="Transaction Date",
        TransactionType char(20) label="Transaction Type",
        Amount numeric(10,2) format=dollar32.2 label="Transaction Amount"
        /* Constraint Specifications */
    );

    create table fact.LossCatastrophe (
        label='Commercial Insurance Loss Catastrophe'
        sortedby=PolicyNumber LocationNumber ClaimNumber) (
        /* Columns Specifications */
        PolicyNumber char(10) label="Policy Number" not null,
        LocationNumber char(10) label="Location Number" not null,
        ClaimNumber char(10) label="Claim Number" not null,
        Guarantee char(10) label="Guarantee",
        ProvinceCode char(2) label="Province Code",
        ClaimDate date format=date9. label="Date of Claim" not null,
        PolicyYear num label="Policy Year",
        ProductType char(20) label="Type of Product",
        AccountingDate date format=date9. label="Accounting Date" not null,
        CoverageType char(4) label="Coverage Type",
        CoverageFlag char(10) label="Coverage Flag",
        ActivityCode num label="Activity Code",
        CatastropheID char(20) label="Catastrophe Id",
        BusinessCategory char(20) label="Business Category",
        PaidAmount numeric(10,2) format=dollar32.2 label="Paid Amount",
        ReserveAmount numeric(10,2) format=dollar32.2 label="Reserve Amount",
        IncurredAmount numeric(10,2) format=dollar32.2 label="Incurred Amount",
        /* Constraint Specifications */
        constraint prim_key primary key(PolicyNumber, LocationNumber, ClaimNumber),
        constraint coverage check(CoverageType in ('RESP', 'PROP'))

        /*
        'LIABILITY': 'ACC' 'BO' 'CGL' 'DO' 'EO' 'POL' 'Umblla'
        'PROPERTY': 'BBC' 'BI' 'CR' 'EQ' 'GeOthCo' 'General' 'IRDC' 'OTH'
        */
    );
    /* Adding indexes for frequently queried columns */
    create index ProvinceCode on fact.LossCatastrophe(ProvinceCode);
    create index CoverageType on fact.LossCatastrophe(CoverageType);
    create index ClaimDate on fact.LossCatastrophe(ClaimDate);

    create table fact.LossRatio (
        PolicyID char(10) label="Policy ID" primary key,
        TotalClaims numeric(10,2) format=dollar32.2 label="Total Claims",
        EarnedPremium numeric(10,2) format=dollar32.2 label="Earned Premium",
        LossRatio numeric(10,4) label="Loss Ratio"
        /* Constraint Specifications */
    );

    create table fact.PolicyHolder (
        PolicyHolderID char(10) label="Policy Holder ID" primary key,
        Name char(50) label="Policy Holder Name",
        Address char(100) label="Policy Holder Address",
        City char(50) label="City",
        Province char(2) format=$province. label="Province",
        Region char(3) format=$region. label="Region",
        PostalCode char(10) label="Postal Code",
        Phone char(15) label="Phone Number"
        /* Constraint Specifications */
    );

    create table fact.PropertyInsurancePolicy (
        PropertyID char(10) label="Property ID" primary key,
        PolicyID char(10) label="Policy ID",
        Address char(100) label="Property Address",
        Construction char(50) label="Property Construction",
        CoverageType char(50) label="Coverage Type",
        Premium numeric(10,2) format=dollar32.2 label="Policy Premium",
        BuildingValue numeric(10,2) format=dollar32.2 label="Building Value",
        ContentsValue numeric(10,2) format=dollar32.2 label="Contents Value"
        /* Constraint Specifications */
    );

    create table fact.OverallRateLevel (
        RateLevelID char(10) label="Rate Level ID" primary key,
        PolicyID char(10) label="Policy ID",
        ClaimID char(10) label="Claim ID",
        EffectiveDate date format=date9. label="Effective Date",
        ReportingDate date format=date9. label="Reporting Date",
        RateLevel numeric(10,2) format=dollar32.2 label="Rate Level",
        RateChange numeric(10,2) format=percent8.2 label="Rate Change",
        RateChangeDate date format=date9. label="Rate Change Date",
        BusinessActivity char(50) label="Business Activity",
        Province char(2) format=$province. label="Province",
        CoverageType char(5) label="Coverage Type",
        EarnedUnits numeric(10,2) label="Earned Units",
        /* Premiums */
        EarnedSystemPremium numeric(10,2) format=dollar32.2 label="Earned System Premium",
        EarnedChargedPremium numeric(10,2) format=dollar32.2 label="Earned Charged Premium",
        WrittenSystemPremium numeric(10,2) format=dollar32.2 label="Written System Premium",
        WrittenChargedPremium numeric(10,2) format=dollar32.2 label="Written Charged Premium",
        /* Premiums excluding non ORL Coverage */
        EarnedSystemPremiumORL numeric(10,2) format=dollar32.2 label="Earned System Premium (With ORL exclusions)",
        EarnedChargedPremiumORL numeric(10,2) format=dollar32.2 label="Earned Charged Premium (With ORL exclusions)",
        WrittenSystemPremiumORL numeric(10,2) format=dollar32.2 label="Written System Premium (With ORL exclusions)",
        WrittenChargedPremiumORL numeric(10,2) format=dollar32.2 label="Written Charged Premium (With ORL exclusions)",
        /* Losses */
        ClaimCount num label="Claim Count",
        LossAmount numeric(10,2) format=dollar32.2 label="Loss Amount",
        ReserveAmount numeric(10,2) format=dollar32.2 label="Reserve Amount",
        CappedLossAmount numeric(10,2) format=dollar32.2 label="Capped Loss Amount",
        /* Losses excluding non ORL Coverage */
        ClaimCountORL num label="Claim Count (With ORL exclusions)",
        LossAmountORL numeric(10,2) format=dollar32.2 label="Loss Amount (With ORL exclusions)",
        ReserveAmountORL numeric(10,2) format=dollar32.2 label="Reserve Amount (With ORL exclusions)",
        CappedLossAmountORL numeric(10,2) format=dollar32.2 label="Capped Loss Amount (With ORL exclusions)"

        /* Constraint Specifications */
    );
quit;

/** \endcond */