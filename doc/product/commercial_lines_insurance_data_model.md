# Commercial Lines Insurance Data Model

- [Commercial Lines Insurance Data Model](#commercial-lines-insurance-data-model)
  - [Introduction](#introduction)
  - [Basic insurance ratios](#basic-insurance-ratios)
  - [Dynamic Filters](#dynamic-filters)
  - [Fact Tables](#fact-tables)
    - [Fact\_Premiums Table](#fact_premiums-table)
    - [Fact\_Claims Table](#fact_claims-table)
    - [Fact\_Quotes Table](#fact_quotes-table)
    - [Fact\_Expenses Table](#fact_expenses-table)
  - [Dimension Tables (Shared Across Facts)](#dimension-tables-shared-across-facts)
    - [Agent Dimension Table (Dim\_Agent)](#agent-dimension-table-dim_agent)
    - [Large/Major Account Number (LMA) Dimension Table (Dim\_LMA)](#largemajor-account-number-lma-dimension-table-dim_lma)
    - [Dim\_Policy](#dim_policy)
    - [Dim\_Date (Date Dimension)](#dim_date-date-dimension)
    - [Dim\_Claim\_Status](#dim_claim_status)
    - [Dim\_Claim\_Type](#dim_claim_type)
    - [Dim\_Claim\_Cause](#dim_claim_cause)
  - [DAX Measures for Insurance Ratios](#dax-measures-for-insurance-ratios)

## Introduction

For Actuarial Analysis and Operational Reporting

This star data model will be used as input in the risk detection rules and algorithms.

## Basic insurance ratios

The data model allows for the calculation of the following insurance ratios:

**Frequency**:

$$\text{Frequency} = \frac{\text{Number of Claims}}{\text{Number of Exposures}}$$

**Severity**:

$$\text{Severity} = \frac{\text{Losses}}{\text{Number of Claims}}$$

**Pure Premium**:

$$\text{Pure Premium} = \frac{\text{Losses}}{\text{Number of Exposures}} = \text{Frequency} \times \text{Severity}$$

**Average Premium**:

$$\text{Average Premium} = \frac{\text{Premium}}{\text{Number Exposures}}$$

**Loss Ratio**:

$$\text{Loss Ratio} = \frac{\text{Losses}}{\text{Premium}} = \frac{\text{Pure Premium}}{\text{Average Premium}}$$

**Loss Adjustment Expense (LAE) Ratio**:

$$\text{LAE Ratio} = \frac{\text{Loss Adjustment Expenses}}{\text{Losses}}$$

**Underwriting Expense Ratio**:

$$\text{UW Expense Ratio} = \frac{\text{UW Expenses}}{\text{Premium}}$$

**Operating Expense Ratio**:

$$\text{OER} = \text{UW Expense Ratio} + \frac{\text{LAE}}{\text{Earned Premium}}$$

**Combined Ratio**:

$$\text{Combined Ratio} = \text{Loss Ratio} + \frac{\text{LAE}}{\text{Earned Premium}} + \frac{\text{Underwriting Expenses}}{\text{Written Premium}}$$

**Retention Ratio**:

$$\text{Retention Ratio} = \frac{\text{Number of Policies Renewed}}{\text{Number of Potential Renewal Policies}}$$

**Close Ratio**:

$$\text{Close Ratio} = \frac{\text{Number of Accepted Quotes}}{\text{Number of Quotes}}$$

## Dynamic Filters

The data model should allow for dynamic filtering on the following dimensions:

| Dimension | Description | Example |
| --------- | ----------- | ------- |
| Policy Type | Type of policy (Auto, Property, etc.) | Auto |
| Agent | Agent Name | John Doe |
| Company | Insurance Company Name | ABC Insurance |
| Communication Channel | Channel through which policy was sold | Agent, Direct, etc. |
| Policy Status | Status of policy (Active, Expired, etc.) | Active |
| Claim Status | Status of claim (Open, Closed, etc.) | Open |
| Transaction Type | Type of transaction (New Business, Renewal, Endorsement, etc.) | New Business |
| Renewal Cycle | Policy Renewal Cycle | 1 |
| TIV (Total Insured Value) | Total value of insured property or auto | $1,000,000 |
| Large/Major Account Number (LMA) | Unique identifier for large accounts | LMA123456 |
| Risk Appetite | Risk appetite of the insurance company | 2 |
| Reinsurance Indicator | Flag for reinsurance | Yes |

## Fact Tables

### Fact_Premiums Table

**Grain**: One record per premium transaction.

**Columns**:

| Column Name | Description | Data Type | Example |
| ----------- | ----------- | --------- | ------- |
| Policy_Number | Unique identifier for policy | Integer | GC123456 |
| Risk_ID | Unique identifier for risk | Integer | 1 |
| Transaction_No | Transaction Number | Integer | 1 |
| Transaction_Date | Date of transaction | Date | 2021-01-01 |
| Transaction_Type | Type of transaction (New Business, Renewal, Endorsement, etc.) | String | New Business |
| Renewal_Cycle | Policy Renewal Cycle | Integer | 1 |
| Agent_ID | Agent ID | Integer | 1 |
| Premium_Amount | Premium Amount | Decimal | 1100.00 |
| Premium_Amount_CGL | Premium Amount for Commercial General Liability | Decimal | 500.00 |
| Premium_Amount_Property | Premium Amount for Property | Decimal | 300.00 |
| Premium_Amount_Earthquake | Premium Amount for Earthquake | Decimal | 100.00 |
| Premium_Amount_Flood | Premium Amount for Flood | Decimal | 100.00 |
| Premium_Amount_Liability | Premium Amount for Liability | Decimal | 100.00 |
| Premium_Amount_Builder_Risk_Per_Project | Premium Amount for Builder Risk Per Project | Decimal | 0.00 |
| Premium_Amount_Builder_Risk_Blanket | Premium Amount for Builder Risk Blanket | Decimal | 0.00 |
| Premium_Amount_Auto | Premium Amount for Auto | Decimal | 0.00 |
| Large_Major_Account_Number | Large/Major Account Number (LMA) | Integer | LMA123456 |

**Constraints**:

- `Policy_Number`, `Transaction_No` is the primary key.
- `Large_Major_Account_Number` is a foreign key to `Dim_LMA`.

### Fact_Claims Table

**Grain**: One record per claim filed.

**Columns**:

| Column Name | Description | Data Type | Example |
| ----------- | ----------- | --------- | ------- |
| Claim_Number | Unique identifier for claim | Integer | 1 |
| Claim_Amount | Amount of claim | Decimal | 100.00 |
| Claim_Paid | Amount paid on claim | Decimal | 100.00 |
| Claim_Date | Date of claim | Date | 2021-01-01 |
| Loss_Adjustment_Expense | Expense incurred in adjusting the claim | Decimal | 100.00 |
| Claim_Reserve | Reserve set aside for claim | Decimal | 100.00 |
| Reinsurance_Recovery | Amount recovered from reinsurance | Decimal | 100.00 |
| Policy_Number | Policy Number (foreign key to Dim_Policy) | Integer | GC123456 |
| Claim_Status | Status of claim (Open, Closed, etc.) | String | Open |

**Constraints**:

- `Claim_Number` is the primary key.
- `Policy_Number` is a foreign key to `Dim_Policy`.
- `Claim_Status` is a foreign key to a `Dim_Claim_Status` table.
- `Claim_Date` is a foreign key to `Dim_Date`.
- `Claim_Type` is a foreign key to `Dim_Claim_Type`.
- `Claim_Cause` is a foreign key to `Dim_Claim_Cause`.

### Fact_Quotes Table

**Grain**: One record per quote issued.

**Columns**:

| Column Name | Description | Data Type | Example |
| ----------- | ----------- | --------- | ------- |
| Quote_Number (unique quote identifier)
| Quote_Amount (for premium offered in the quote)
| Quote_Status (Accepted, Declined, Pending)
| Quote_Conversion_Indicator (flag for quote converted to policy)
| Quote_Issue_Date (capture when the quote was issued)
| Quote_Bound_Date (date when accepted)
| Policy_Number (if converted to policy, foreign key to Dim_Policy)
| Quote_Date (foreign key to Dim_Date)
| Agent_ID (foreign key to Dim_Agent)

### Fact_Expenses Table

**Grain**: One record per expense incurred related to policies.

**Columns**:

| Column Name | Description | Data Type | Example |
| ----------- | ----------- | --------- | ------- |
| Policy_Number (foreign key to Dim_Policy)
| Underwriting_Expense
| Operating_Expense
| Commission_Expense | Commission paid to agents | Decimal | 100.00 |
| Transaction_Date (foreign key to Dim_Date)

## Dimension Tables (Shared Across Facts)

### Agent Dimension Table (Dim_Agent)

**Columns**:

| Column Name | Description | Data Type | Example |
| ----------- | ----------- | --------- | ------- |
| Agent_ID
| Agent_Name
| Agent_Location
| Agent_Tenure

### Large/Major Account Number (LMA) Dimension Table (Dim_LMA)

**Columns**:

| Column Name | Description | Data Type | Example |
| ----------- | ----------- | --------- | ------- |
| Large_Major_Account_Number | Unique identifier for large accounts | Integer | LMA123456 |
| LMA_Name | Name of large account | String | ABC Corp |
| Rebate_Percentage | Rebate percentage for large account | Decimal | 0.10 |

### Dim_Policy

**Columns**:

| Column Name | Description | Data Type | Example |
| ----------- | ----------- | --------- | ------- |
| Policy_Number | Unique identifier for policy | Integer | GC123456 |
| Policy_Renewal_Cycle | Policy Renewal Cycle | Integer | 1 |
| Policy_Start_Date | Date the policy was issued | Date | 2021-01-01 |
| Policy_End_Date | Date the policy expires | Date | 2022-01-01 |
| Policy_Status | Status of policy | String | Active |
| Policy_Type | Type of policy | String | Auto |
| Policy_Term | Term of policy in months | Integer | 12 |
| Policy_TIV | Total Insured Value | Decimal | 1000000.00 |
| Cancellation_Reason | Reason for policy cancellation | String | Non-Payment |

**Constraints**:

- `Policy_Number` and `Policy_Renewal_Cycle` is the primary key.
- Check `Policy_Status` is either Active, Renewed, Expired, or Canceled.
- Check `Policy_Type` is either Auto or Property.

### Dim_Date (Date Dimension)

**Columns**:

| Column Name | Description | Data Type | Example |
| ----------- | ----------- | --------- | ------- |
| Date_ID | Unique identifier for date | Integer | 20210101 |
| Year | Year | Integer | 2021 |
| Month
| Day
| Quarter
| Week

### Dim_Claim_Status

**Columns**:

| Column Name | Description | Data Type | Example |
| ----------- | ----------- | --------- | ------- |
| Claim_Status_ID
| Claim_Status_Name

### Dim_Claim_Type

**Columns**:

| Column Name | Description | Data Type | Example |
| ----------- | ----------- | --------- | ------- |
| Claim_Type_ID
| Claim_Type_Name

### Dim_Claim_Cause

**Columns**:

| Column Name | Description | Data Type | Example |
| ----------- | ----------- | --------- | ------- |
| Claim_Cause_ID
| Claim_Cause_Name

## DAX Measures for Insurance Ratios

**Earned Premium**:

Create a DAX Measure for Days In Force.

```DAX
Days In Force = 
VAR StartDate = MAX(Dim_Policy[Policy_Start_Date])
VAR EndDate = MIN(Dim_Policy[Policy_End_Date])
VAR CurrentStart = MAX(Dim_Date[Start_Date])
VAR CurrentEnd = MIN(Dim_Date[End_Date])
RETURN
DATEDIFF(
    MAX(StartDate, CurrentStart),
    MIN(EndDate, CurrentEnd),
    DAY
)
```

Calculate the Total Policy Duration in Days

```DAX
Policy Duration = DATEDIFF(Dim_Policy[Policy_Start_Date], Dim_Policy[Policy_End_Date], DAY)
```

Create a DAX Measure for Earned Premium

```DAX
Earned Premium = 
VAR DaysInForce = [Days In Force]
VAR TotalPolicyDuration = [Policy Duration]
RETURN
DIVIDE(
    SUM(Fact_Premiums[Premium_Amount]) * DaysInForce,
    TotalPolicyDuration
)
```

**Frequency**:

```DAX
Frequency = DIVIDE(COUNTROWS(Fact_Claims), COUNTROWS(Fact_Premiums))
```

**Severity**:

```DAX
Severity = DIVIDE(SUM(Fact_Claims[Claim_Amount]), COUNTROWS(Fact_Claims))
```

**Pure Premium**:

```DAX
Pure Premium = DIVIDE(SUM(Fact_Claims[Claim_Amount]), COUNT(Fact_Premiums[Policy_Number]))
```

**Average Premium**:

```DAX
Average Premium = DIVIDE(SUM(Fact_Premiums[Premium_Amount]), COUNT(Fact_Premiums[Policy_Number]))
```

**Loss Ratio**:

```DAX
Loss Ratio = DIVIDE(SUM(Fact_Claims[Claim_Amount]), SUM(Fact_Premiums[Earned_Premium]))
```

**Loss Adjustment Expense (LAE) Ratio**:

```DAX
LAE Ratio = DIVIDE(SUM(Fact_Claims[Loss_Adjustment_Expense]), SUM(Fact_Premiums[Earned_Premium]))
```

**Underwriting Expense Ratio**:

```DAX
Underwriting Expense Ratio = DIVIDE(SUM(Fact_Expenses[Underwriting_Expense]), SUM(Fact_Premiums[Written_Premium]))
```

**Operating Expense Ratio**:

```DAX
Operating Expense Ratio = DIVIDE(SUM(Fact_Expenses[Operating_Expense]), SUM(Fact_Premiums[Earned_Premium]))
```

**Combined Ratio**:

```DAX
Combined Ratio = [Loss Ratio] + [LAE Ratio] + [Underwriting Expense Ratio] + [Operating Expense Ratio]
```

**Retention Ratio**:

```DAX
Retention Ratio = DIVIDE(COUNTROWS(FILTER(Dim_Policy, Dim_Policy[Policy_Status] = "Renewed")), COUNTROWS(Dim_Policy))
```

**Close Ratio**:

```DAX
Close Ratio = DIVIDE(COUNTROWS(FILTER(Fact_Quotes, Fact_Quotes[Quote_Status] = "Accepted")), COUNTROWS(Fact_Quotes))
```
