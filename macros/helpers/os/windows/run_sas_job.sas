/**
    \file
    \ingroup    HELPERS_OS_WINDOWS
    \brief      Run a SAS job on Windows
    \details    This macro is used to run a SAS job on Windows and
                capture the log output to a specified location.
    \author     Maxime Blouin
    \date       13AUG2024
    \remark     Leave the o_log_folder and o_sca_folder empty to use the default location.
    \remark     The SCAPROC procedure implements the SAS Code Analyzer, which
                captures information about input, output, and the use of macro
                symbols from a SAS job while it is running.
    \todo       If the i_sas_job, o_log_folder, or o_sca_folder is quoted, remove the quotes.
    \param      i_sas_job     (char) SAS job to run
    \param      i_verbose     (char) Verbose mode (YES/NO default: NO)
    \param      o_log_folder  (char) Specifies the SAS log output directory (optional)
    \param      o_sca_folder  (char) Specifies the SAS Code Analyzer output directory (optional)
*/ /** \cond */
%macro run_sas_job(
    i_sas_job=,
    i_verbose=NO,
    o_log_folder=,
    o_sca_folder=);

    /* Remove quotes from inputs. */
    %let i_sas_job = %sysfunc(dequote(&i_sas_job));
    %let o_log_folder = %sysfunc(dequote(&o_log_folder));
    %let o_sca_folder = %sysfunc(dequote(&o_sca_folder));

    /* ERROR handling: Check if i_sas_job exists. */
    %if %sysfunc(fileexist(&i_sas_job)) = 0 %then %do;
        %put ERROR: &i_sas_job does not exist.;
        %return;
    %end;

    /* ERROR handling: Check if o_log_folder exists. */
    %if %sysfunc(fileexist(&o_log_folder)) = 0 %then %do;
        %put ERROR: &i_sas_job does not exist.;
        %return;
    %end;

    /* Declare local variables. */
    %local l_log_filename l_sca_filename l_runtime;
    %let l_runtime = %sysfunc(datetime(), B8601DT.); /* ISO 8601 datetime format YYYYMMDDTHHMMSS */
    %let l_log_filename = &o_log_folder.\%sysfunc(scan(%sysfunc(scan(&i_sas_job, -1, %str(\))), 1, .))_&l_runtime..log;
    %let l_sca_filename = &o_sca_folder.\%sysfunc(scan(%sysfunc(scan(&i_sas_job, -1, %str(\))), 1, .))_&l_runtime..txt;

    /* Route the SAS log to an external file. */
    filename log_file "&l_log_filename";

    %put INFO: Log destination: &l_log_filename;

    proc printto new log=log_file_file;
    run;

    /* Turn on various extra options if verbose. */
    %if %upcase(&i_verbose) = YES %then %do;
        options
            symbolgen
            mprint mlogic
            mautolocdisplay mautocomploc
            notes
            nonumber pagesize=MAX linesize=MAX
            fullstimer
            msglevel=I
            /*mcoverage mexecnote
            mprintnest mlogicnest
            source source2*/;

        /* Print macro variables to the log for debugging. */
        %put _ALL_;
    %end;

    /* Run the SAS Code Analyzer (SCA) procedure. */
    %if %sysfunc(fileexist(&o_sca_folder)) %then %do;
        proc scaproc;
            record "&l_sca_filename" attr opentimes expandmacros;
        run;
    %end;

    /* Run the program. */
    %include "&i_sas_job";

    /* Write SCAPROC output. */
    %if %sysfunc(fileexist(&o_sca_folder)) %then %do;
        proc scaproc;
            write;
        run;
    %end;

    /* Reset the log destination. */
    proc printto;
    run;

    filename log_file clear;

    %put INFO: SAS Logging has been reset to the default location.;

%mend run_sas_job;
/** \endcond */