/**
    \file
    \ingroup    HELPERS_OS_WINDOWS
    \brief      Run a SAS job on Windows
    \details    This macro is used to run a SAS job on Windows and
                capture the log output to a specified location.
                It also has the option to use the SAS Code Analyzer (SCAPROC).
    \author     Maxime Blouin
    \date       13AUG2024
    \remark     Leave the o_log_folder and o_sca_folder empty to use the default location.
    \remark     The SCAPROC procedure implements the SAS Code Analyzer, which
                captures information about input, output, and the use of macro
                symbols from a SAS job while it is running.
    \sa         https://support.sas.com/resources/papers/proceedings17/1104-2017.pdf
    \param      i_sas_job     (char) SAS job to run
    \param      i_verbose     (char) Verbose mode (YES/NO default: NO)
    \param      o_graphviz_folder (char) Specifies the graphviz output directory (optional)
    \param      o_log_folder  (char) Specifies the SAS log output directory (optional)
    \param      o_sca_folder  (char) Specifies the SAS Code Analyzer output directory (optional)
*/ /** \cond */
%macro run_sas_job(
    i_sas_job=,
    i_verbose=NO,
    o_graphviz_folder=,
    o_log_folder=,
    o_sca_folder=);

    /* Remove quotes from inputs. */
    %let i_sas_job = %sysfunc(dequote(&i_sas_job));
    %let o_graphviz_folder = %sysfunc(dequote(&o_graphviz_folder));
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
    %local l_log_filename l_sca_filename l_runtime l_graphviz_filename;
    %let l_runtime = %sysfunc(datetime(), B8601DT.); /* ISO 8601 datetime format YYYYMMDDTHHMMSS */
    %let l_graphviz_filename = &o_graphviz_folder.\%sysfunc(scan(%sysfunc(scan(&i_sas_job, -1, %str(\))), 1, .))_&l_runtime..dot;
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

        %let scaproc_dir=%sysfunc(pathname(WORK));

        /*list the directory to see the file created*/
        data _null_;
            infile "&l_sca_filename";
            input;
            put _infile_;
        run;

        /*read in the info and parse into a SAS table*/
        filename scaproc "&l_sca_filename";

        data scaproc;
            length word1-word6 $ 46;
            retain step 1;
            infile scaproc;
            input;
            put _infile_;
            if _infile_=:'/* JOBSPLIT: ';
            word1=scan(_infile_,2,' ');
            word2=scan(_infile_,3,' ');
            word3=scan(_infile_,4,' ');
            word4=scan(_infile_,5,' ');
            word5=scan(_infile_,6,' ');
            word6=scan(_infile_,7,' ');
            if word2='DATASET' & word3='INPUT' then
                in=strip(word4)||'~'||scan(word5,1,'.')||'.'||scan(word5,2,'.');
            if word2='DATASET' & word3='OUTPUT' then
                out=strip(word4)||'~'||scan(word5,1,'.')||'.'||scan(word5,2,'.');
            if word2='DATASET' & word3='UPDATE' then
                out=strip(word4)||'~'||scan(word5,1,'.')||'.'||scan(word5,2,'.');
            if word2='PROCNAME' then procname=word3;
            if word2='ELAPSED' then elapsed=input(word3,8.3);
            output;

            if index(_infile_,'STEP SOURCE FOLLOWS') then step+1;
        run ;

        /*merge the data into one record for each step*/
        proc sql noprint;
            create table flow as
            select
                coalesce(a.step,b.step,c.step) as step,
                a.procname,
                coalesce(scan(b.in,1,'~'),scan(c.in,1,'~')) as in_access,
                coalesce(scan(b.out,1,'~'),scan(c.out,1,'~')) as out_access,
                coalesce(scan(b.in,2,'~'),scan(c.in,2,'~')) as in,
                coalesce(scan(b.out,2,'~'),scan(c.out,2,'~')) as out,
                d.elapsed
            from scaproc(where=(procname>'')) as a
            full join scaproc(where=(in>'')) as b
                on a.step=b.step
            full join scaproc(where=(out>'')) as c
                on a.step=c.step
            left join scaproc(where=(elapsed>0)) as d
                on a.step=d.step
            order by calculated step;

            create table procnames as
            select distinct procname
            from flow
            where procname is not missing and (missing(in) or missing(out)) ;
        quit ;

        /*create percentiles for use in making diagram*/
        proc univariate data=work.flow noprint;
            var elapsed;
            output out = _stats
            pctlpts = 50 60 70 80 90 95 99
            pctlpre = pct;
        run;

        /* Put the percentile into macro variables */
        data _null_;
            length varname $32;
            dsid=open("_stats");
            call set(dsid);
            rc=fetch(dsid);
            do i=1 to attrn(dsid, 'nvars');
                call symputx(
                    varname(dsid, i),
                    getvarn(dsid, i));
            end;

            dsid=close(dsid);
        run;

        /* Create .DOT directives to make a diagram */
        data work.graphviz(keep=line);
            length
                line $ 140
                p $ 32
                color penwidth $ 12;

            if _n_=1 then do;
                line="// Percentiles: 50:&pct50 60:&pct60 70:&pct70 80:&pct80 90:&pct90 95:&pct95 99:&pct99";
                output;

                line='digraph test {';
                output;

                *line='rankdir=LR';
                *output;

                line="graph [label=""&i_sas_job. \n &l_runtime.""]";
                output;

                line='node [shape=box color=lightblue style=filled]';
                output;

                dsid=open('procnames');
                do while(fetch(dsid)=0);
                    p=getvarc(dsid,1);
                    line=quote(strip(p))||'[shape=ellipse color=lightgreen]';
                    output;
                end;

                dsid=close(dsid);
            end;

            set flow end=end;

            in=quote(strip(in));
            out=quote(strip(out));
            procname=quote(strip(procname));

            if elapsed>=&pct50 then color='color=red';
            else color='';

            if elapsed>=&pct99 then penwidth='penwidth=7';
            else if elapsed>=&pct95 then penwidth='penwidth=6';
            else if elapsed>=&pct90 then penwidth='penwidth=5';
            else if elapsed>=&pct80 then penwidth='penwidth=4';
            else if elapsed>=&pct70 then penwidth='penwidth=3';
            else if elapsed>=&pct60 then penwidth='penwidth=2';
            else penwidth='';

            if in_access='MULTI' or out_access='MULTI' then style='style=dashed';
            else style='style=solid ';

            if compress(in,'"')>'' & compress(out,'"')>'' then
                line=strip(in)||'->'||strip(out)||' [label=" '||lowcase(strip(dequote(procname)))||' ('||strip(put(elapsed,8.3))||')" '||strip(color)||' '||strip(penwidth)||' '||strip(style)||'];';
            else if compress(in,'"')>'' & compress(out,'"')='' then
                line=strip(in)||'->'||strip(procname)||' [label="('||strip(put(elapsed,8.3))||')" '||strip(color)||' '||strip(penwidth)||' '||strip(style)||'];';
            else if compress(in,'"')='' & compress(out,'"')>'' then
                line=strip(procname)||'->'||strip(out)||' [label="('||strip(put(elapsed,8.3))|| ')" '||strip(color)||' '||strip(penwidth)||' '||strip(style)||'];';
            else
                line='// '||strip(procname)||' ('||strip(put(elapsed,8.3))||')';
            output;

            if end then do;
                line='}';
                output;
            end;
        run;

        data _null_;
            set work.graphviz;
            file "&l_graphviz_filename.";
            put line;
            file print;
            put line;
        run;
    %end;

    /* Reset the log destination. */
    proc printto;
    run;

    filename log_file clear;

    %put INFO: SAS Logging has been reset to the default location.;

%mend run_sas_job;
/** \endcond */