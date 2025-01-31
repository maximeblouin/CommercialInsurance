/**
    \file
    \ingroup    HELPERS
    \brief      Establish and configure a connection to Oracle database.
    \details    This macro is used to establish a connection to an Oracle database
                and configure session parameters such as PARALLEL_DEGREE_LIMIT and TIMEOUT.
                It also allows specifying additional parameters for the connection.
    \author     Maxime Blouin
    \date       07APR2024
    \param      i_authdomain        Authentication domain for Oracle connection
    \param      i_path              Path to the Oracle database
    \param      i_defer=no          Whether to defer password validation (default: no)
    \param      i_preserve_comments Whether to preserve comments in SQL queries (default: no)
    \param      i_readbuff          Read buffer size for data retrieval (default: 250)
    \param      i_parallel_limit    Maximum degree of parallelism allowed for queries
    \param      i_timeout           Timeout value for queries
    \remark     Here's an example usage of the `connect2oracle` macro within a `proc sql` block:

            proc sql;
                %connect2oracle(
                    i_authdomain=YourAuthDomain,
                    i_path=YourOracleDBPath,
                    i_defer=yes,
                    i_preserve_comments=yes,
                    i_readbuff=50,
                    i_parallel_limit=8,
                    i_timeout=600
                );

                select *
                from connection to Oracle (
                    ...
                );

                disconnect from Oracle;
            quit;
*/ /** \cond */
%macro connect2oracle(
    i_authdomain=,          /* Authentication domain for Oracle connection */
    i_path=,                /* Path to the Oracle database */
    i_defer=no,             /* Whether to defer password validation (default: no) */
    i_preserve_comments=no, /* Whether to preserve comments in SQL queries (default: no) */
    i_readbuff=250,         /* Read buffer size for data retrieval (default: 250) */
    i_parallel_limit=,      /* Maximum degree of parallelism allowed for queries */
    i_timeout=              /* Timeout value for queries */);

    connect to Oracle as Oracle (
        authdomain=&i_authdomain
        path=&i_path
        defer=&i_defer
        preserve_comments=&i_preserve_comments
        readbuff=&i_readbuff);

    execute (
        alter session set "PARALLEL_DEGREE_LIMIT"=&i_parallel_limit;
    ) by Oracle;

%mend connect2oracle;
/** \endcond */