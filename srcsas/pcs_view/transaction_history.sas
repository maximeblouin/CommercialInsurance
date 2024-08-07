/**
    \file srcsas/pcs_view/transaction_history.sas
    \brief Creates a view of the transaction history for each policy.
    \details This program creates a view of the transaction history
        for each policy.
    \author Maxime Blouin
    \date 07AUG2024
    \todo Check the tax calculation for Quebec policies and other provinces.
    \todo Join the full name for the performer and the requestor.
    \todo Ensure the Type and Reason format is correct.
    \todo Better formatting for Type.
    \todo Better formatting for Reason (format cancellation Code (d3, ...))
    \todo Le requestor n'est pas toujours rempli dans PCS, donc ce n'est pas le champ authorizedperson
    \todo si Performer eq ipbsys alors IPB System user
*/ /** \cond */
proc sql;

    %connect2Oracle();

    create table pcs_view.transaction_history as
    select
        policynumber as policynumber label="Policy #",
        coalescec(txsubtype, txtype) as type label="Type",
        datepart(txdate) as transaction_date label="Transaction Date" format=yymmdds10.,
        datepart(txeffectivedate) as effective_date label="Effective Date" format=yymmdds10.,
        revisionno as transaction_no label="#",
        coalescec(txreason, txreasontext) as reason label="Reason",
        case
            when riskstatecd = 'QC' then 1.09 * mnt_prim_souscr
            else mnt_prim_souscr
        end as transaction_premium label="Transaction Premium" format=dollar16.2,
        case
            when riskstatecd = 'QC' then 1.09 * premiumamt_policy
            else premiumamt_policy
        end as ending_premium label="Ending Premium" format=dollar16.2,
        createdby as performer label="Performer",
        authorizedperson as requestor label="Requestor",
        mnt_prim_souscr as transaction_premium_no_tax label="Transaction Premium (No Tax)" format=dollar16.2,
        premiumamt_policy as ending_premium_no_tax label="Ending Premium (No Tax)" format=dollar16.2
    from connection to oracle(
        select
            info_policy.policynumber,
            info_policy.txsubtype,
            info_policy.txtype,
            info_policy.revisionno,
            info_policy.txreason,
            info_policy.txreasontext,
            info_policy.premiumamt_policy,
            info_policy.createdby,
            info_policy.authorizedperson,
            info_policy.riskstatecd,
            prime_souscrite.txdate,
            prime_souscrite.txeffectivedate,
            prime_souscrite.mnt_prim_souscr
        from trvap1q.trv_dacces_info_policy info_policy
        left join (
            select
                policynumber,
                no_seq_trans,
                riskstatecd,
                txdate,
                txeffectivedate,
                sum(mnt_prim_souscr) as mnt_prim_souscr
            from trvap1q.trv_dacces_prime_souscrite
            group by
                policynumber,
                no_seq_trans,
                riskstatecd,
                txdate,
                txeffectivedate
        ) prime_souscrite
        on info_policy.policynumber = prime_souscrite.policynumber
        and info_policy.revisionno = prime_souscrite.no_seq_trans
        order by
            info_policy.policynumber,
            info_policy.revisionno desc
    );

    disconnect from oracle;
quit;

/*Correctif pour les transactions dupliqués*/
/* compute the sum of transaction_premium and transaction_premium_no_tax, the max of effective_date*/
proc summary nway missing data=pcs_view.transaction_history;
    class policynumber type transaction_date transaction_no reason
        ending_premium performer requestor ending_premium_no_tax;
    var transaction_premium transaction_premium_no_tax effective_date;
    output out=pcs_view.transaction_history (drop=_type_ _freq_)
        sum(transaction_premium)=transaction_premium
        sum(transaction_premium_no_tax)=transaction_premium_no_tax
        min(effective_date)=effective_date;
run;

data pcs_view.transaction_history (
    label="PCS Transaction History");
    retain policynumber type transaction_date effective_date transaction_no reason
        transaction_premium ending_premium performer requestor
        transaction_premium_no_tax ending_premium_no_tax;
    set pcs_view.transaction_history;
run;

proc sort data=pcs_view.transaction_history;
    by policynumber descending transaction_no;
run;
/** \endcond */