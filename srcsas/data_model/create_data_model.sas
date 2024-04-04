/**
    \file
    \ingroup    DATA_MODEL
    \brief      Create tables for the data model
    \author     Maxime Blouin
    \date       04APR2024
*/ /** \cond */

/* Create PolicyHolder table */
proc sql;
    create table PolicyHolder (
        PolicyHolderID char(10) label="Policy Holder ID" primary key,
        Name char(50) label="Policy Holder Name",
        Address char(100) label="Policy Holder Address",
        City char(50) label="City",
        ProvinceCode char(2) format=$province_fmt. label="Province Code",
        PostalCode char(10) label="Postal Code",
        Phone char(15) label="Phone Number"
    );
quit;

/* Create InsurancePolicy table */
proc sql;
    create table InsurancePolicy (
        PolicyID char(10) label="Policy ID" primary key,
        PolicyHolderID char(10) label="Policy Holder ID",
        StartDate date format=date9. label="Policy Start Date",
        EndDate date format=date9. label="Policy End Date",
        WrittenPremium numeric(10,2) format=dollar32.2 label="Written Premium",
        PolicyType char(20) label="Policy Type",
        PolicyStatus char(20) label="Policy Status",
        BrokerID char(10) label="Broker ID",
        CoverageType char(50) label="Coverage Type"
    );
quit;

/* Create AutoInsurancePolicy table */
proc sql;
    create table AutoInsurancePolicy (
        VehicleID char(10) label="Vehicle ID" primary key,
        PolicyID char(10) label="Policy ID",
        Make char(50) label="Vehicle Make",
        Model char(50) label="Vehicle Model",
        VehiculeYear num label="Vehicle Year",
        Premium numeric(10,2) format=dollar32.2 label="Policy Premium",
        VIN char(17) label="Vehicle Identification Number"
    );
quit;

/* Create PropertyInsurancePolicy table */
proc sql;
    create table PropertyInsurancePolicy (
        PropertyID char(10) label="Property ID" primary key,
        PolicyID char(10) label="Policy ID",
        Address char(100) label="Property Address",
        Construction char(50) label="Property Construction",
        CoverageType char(50) label="Coverage Type",
        Premium numeric(10,2) format=dollar32.2 label="Policy Premium",
        BuildingValue numeric(10,2) format=dollar32.2 label="Building Value",
        ContentsValue numeric(10,2) format=dollar32.2 label="Contents Value"
    );
quit;

/* Create ClaimInformation table */
proc sql;
    create table ClaimInformation (
        ClaimID char(10) label="Claim ID" primary key,
        PolicyID char(10) label="Policy ID",
        ClaimDate date format=date9. label="Claim Date",
        Description char(100) label="Claim Description",
        ClaimAmount numeric(10,2) format=dollar32.2 label="Claim Amount",
        ClaimStatus char(20) label="Claim Status"
    );
quit;

/* Create InsuranceTransaction table */
proc sql;
    create table InsuranceTransaction (
        TransactionID char(10) label="Transaction ID" primary key,
        PolicyID char(10) label="Policy ID",
        TransactionDate date format=date9. label="Transaction Date",
        TransactionType char(20) label="Transaction Type",
        Amount numeric(10,2) format=dollar32.2 label="Transaction Amount"
    );
quit;

/* Create EarnedPremium table */
proc sql;
    create table EarnedPremium (
        PolicyID char(10) label="Policy ID" primary key,
        EffectiveDate date format=date9. label="Effective Date",
        ExpirationDate date format=date9. label="Expiration Date",
        PolicyHolderID char(10) label="Policy Holder ID",
        PolicyType char(50) label="Policy Type",
        PremiumAmount numeric(10,2) format=dollar32.2 label="Premium Amount",
        GeographicRegion char(50) label="Geographic Region",
        PaymentStatus char(20) label="Payment Status",
        PolicyStatus char(20) label="Policy Status",
        PolicyDuration num label="Policy Duration" /* Number of months or years */
    );
quit;

/* Create LossRatio table */
proc sql;
    create table LossRatio (
        PolicyID char(10) label="Policy ID" primary key,
        TotalClaims numeric(10,2) format=dollar32.2 label="Total Claims",
        EarnedPremium numeric(10,2) format=dollar32.2 label="Earned Premium",
        LossRatio numeric(10,4) label="Loss Ratio"
    );
quit;
