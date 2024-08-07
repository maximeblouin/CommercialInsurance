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
*/ /** \cond */
proc sql;

    %connect2Oracle();

    create table pcs_view.transaction_history as
    select
        policynumber as policynumber label="Policy #",
        coalescec(txsubtype, txtype) as type label="Type",
        txdate as transaction_date label="Transaction Date" format=yymmdd10.,
        txeffectivedate as effective_date label="Effective Date" format=yymmdd10.,
        revisionno as transaction_no label="#",
        coalescec(txreason, txreasontext) as reason label="Reason",
        case
            when stateprovcd = 'QC' then 1.09 * mnt_prim_souscr
            else mnt_prim_souscr
        end as transaction_premium label="Transaction Premium" format=dollar16.2,
        case
            when stateprovcd = 'QC' then 1.09 * premiumamt_policy
            else premiumamt_policy
        end as ending_premium label="Ending Premium" format=dollar16.2,
        createdby as performer label="Performer",
        authorizedperson as requestor label="Requestor"
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
            prime_souscrite.txdate,
            prime_souscrite.txeffectivedate,
            prime_souscrite.stateprovcd,
            prime_souscrite.mnt_prim_souscr
        from trvap1q.trv_dacces_info_policy info_policy
        left join (
            select
                nk_policy,
                policynumber,
                no_seq_trans,
                stateprovcd,
                txdate,
                txeffectivedate,
                sum(mnt_prim_souscr) as mnt_prim_souscr
            from trvap1q.trv_dacces_prime_souscrite
            group by nk_policy
        ) prime_souscrite
        on info_policy.nk_policy = prime_souscrite.nk_policy
        order by
            info_policy.policynumber,
            info_policy.revisionno desc
    );

    disconnect from oracle;
quit;
/** \endcond */