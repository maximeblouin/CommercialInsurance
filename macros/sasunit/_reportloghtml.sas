/**
    \file
    \ingroup    SASUNIT_REPORT

    \brief      convert log-File into HTML page

                Error and warning messages will be highlighted and a link is created at the top of the page.

    \todo render results using ODS. Technical implementation of links for multiple errors is difficult and must be redesigned for ODS.
    \todo consolidate all logscan logic into datastep functions and use them throughout the project.\nThe SAS option CMPLIB must then be set for all sessions to use these functions.

    \version    Revision: 743
    \author     Klandwich
    \date       2020-10-05

    \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
                Here you can find the SASUnit documentation, release notes and license information.
    \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/_reportloghtml.sas $
    \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
                For copyright information and terms of usage under the GPL license see included file readme.txt
                or https://sourceforge.net/p/sasunit/wiki/readme/.

    \param i_log     Log file with complete path
    \param i_title   String for title
    \param o_html    html file output complete path
    \param r_rc      Name of the macro variable with the return code
                    0 ...  no error, no warning occurred
                    1 ...  Warnings occurred
                    2 ...  Error (possibly also warnings) occurred
                    3 ...  Error in the execution of this macro
*/ /** \cond */
%MACRO _reportLogHTML(i_log     =
                     ,i_title   = SAS-Log
                     ,o_html    = 0
                     ,r_rc      = logrc
                     );

    %LOCAL
        l_macname
        l_log
        l_html
        l_error_count
        l_warning_count
        l_curError
        l_curWarning
        l_sIgnoreLogMessage01
    ;

    %LET l_macname=&sysmacroname;
    %LET l_log  = &i_log;
    %LET l_html = &o_html;

    %LET &r_rc=3;

    /*- First log run to determine the number of errors and warnings*/
    %_checkLog(
        i_logfile = &l_log,
        i_error = &g_error.,
        i_warning = &g_warning.,
        r_errors = l_error_count,
        r_warnings = l_warning_count);

    %IF %_handleError(
            &l_macname,
            LogNotFound,
            &syserr. NE 0,
            Error accessing the log)
        %THEN %GOTO errexit;

    /* TODO consolidate all logscan logic into datastep functions and use them throughout the project.
        The SAS option CMPLIB must then be set for all sessions to use these functions.
    */
    %LET l_sIgnoreLogMessage01 = %STR(ERROR: Errors printed on page);

    DATA _NULL_;

        INFILE "&l_log" END=eof TRUNCOVER &g_infile_options.;
        FILE "&l_html";
        INPUT logline $char255.;

        ATTRIB
            _errorPatternId      LENGTH = 8
            _ignoreErrPatternId  LENGTH = 8
            _warningPatternId    LENGTH = 8
            error_count          LENGTH = 8
            warning_count        LENGTH = 8
        ;
        RETAIN
            _errorPatternId      0
            _ignoreErrPatternId  0
            _warningPatternId    0
            error_count          0
            warning_count        0
        ;

        /* Undo macro quoting: convert
            'CAN' -> "/"
            'SYN' -> "-"
            'SO'  -> ";",
            'RS'  -> ","
            'DLE' -> "%"
            'NAK' -> "+"
            'DC3' -> "("
            'DC4' -> ")"
            'EM'  -> "<"
            'SUB' -> ">"
            'FS'  -> "="
            as well as delete 'BS', 'ACK', 'SOH' 'FF' and 'STX' */
        logline = TRANSLATE(logline, '/', "18"x); * CAN *;
        logline = TRANSLATE(logline, '-', "16"x); * SYN *;
        logline = TRANSLATE(logline, ';', "0E"x); * SO  *;
        logline = TRANSLATE(logline, ',', "1E"x); * RS  *;
        logline = TRANSLATE(logline, '%', "10"x); * DLE *;
        logline = TRANSLATE(logline, '+', "15"x); * NAK *;
        logline = TRANSLATE(logline, '(', "13"x); * DC3 *;
        logline = TRANSLATE(logline, ')', "14"x); * DC4 *;
        logline = TRANSLATE(logline, '<', "19"x); * EM  *;
        logline = TRANSLATE(logline, '>', "1A"x); * SUB *;
        logline = TRANSLATE(logline, '=', "1C"x); * FS  *;
        logline = transtrn(logline, "08"x, trimn(''));
        logline = transtrn(logline, "06"x, trimn(''));
        logline = transtrn(logline, "01"x, trimn(''));
        logline = transtrn(logline, "02"x, trimn(''));
        logline = transtrn(logline, "0C"x, trimn(''));

        IF _n_=1 THEN DO;

            _errorPatternId     = prxparse("/^%UPCASE(&g_error.)[: ]/");
            _warningPatternId   = prxparse("/^%UPCASE(&g_warning.)[: ]/");
            _ignoreErrPatternId = prxparse("/^&l_sIgnoreLogMessage01./");

            /*HTML-Header*/
            PUT '<html>';
            PUT '<head>';
            PUT '<meta http-equiv="Content-Language" content="de">';
            PUT '<meta name="GENERATOR" content="SAS &sysver">';
            PUT '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">';
            PUT "<title>&i_title</title>";
            PUT '</head>';
            /*HTML-Body*/
            PUT '<body>';
            /*Output of a page header with linked overview of error and warning messages*/
            PUT '<p style="background-color:#EAEAEA; font-family:Fixedsys,Courier,monospace">';
            PUT "&g_nls_reportLog_001: &l_error_count. ";
            %DO l_curError = 1 %TO &l_error_count.;
                IF &l_curError=1 THEN PUT '==>';
                PUT '<a href="#error' "%sysfunc(putn(&l_curError,z3.))" '">' "&l_curError." '</a>';
            %END;
            PUT '<br>';
            PUT "&g_nls_reportLog_002: &l_warning_count. ";
            %DO l_curWarning = 1 %TO &l_warning_count.;
                IF &l_curWarning=1 THEN PUT '==>';
                PUT '<a href="#warning' "%sysfunc(putn(&l_curWarning,z3.))" '">' "&l_curWarning." '</a>';
            %END;
            PUT '<br>';
            PUT '</p>';
            PUT '<pre>';
        END;

        /*Output of the log lines. Error and warning messages are highlighted in color and linked*/
        IF prxmatch (_errorPatternId, logline) 
            AND (NOT prxmatch (_ignoreErrPatternId, logline)) THEN DO;
            error_count+1;
            PUT '<span style="color:#FF0000">' @;
            PUT '<a name="error' error_count z3. '">' @;
            l = length(logline);
            PUT logline $varying255. l @;
            PUT '</a>'@;
            PUT '</span>';
        END;
        ELSE IF prxmatch (_warningPatternId, logline) THEN DO;
            warning_count+1;
            PUT '<span style="color:#FF8040">' @;
            PUT '<a name="warning' warning_count z3. '">' @;
            l = length(logline);
            PUT logline $varying255. l @;
            PUT '</a>' @;
            PUT '</span>';
        END;
        ELSE DO;
            /*Replacement of the characters <, > with corresponding HTML codes*/
            DO WHILE (index(logline, '<') > 0);
                textpos = index(logline, '<');
                IF textpos NE 1 THEN
                newlogline = substr(logline, 1, (textpos - 1)) ||'&lt;'||substr(logline, (textpos +length('<')));
                ELSE
                newlogline = '&lt;'||substr(logline, (textpos + length('<')));
                logline = newlogline;
            END;

            DO WHILE (index(logline, '>') > 0);
                textpos = index(logline, '>');
                IF textpos NE 1 THEN
                newlogline = substr(logline, 1, (textpos - 1)) ||'&gt;'||substr(logline, (textpos +length('>')));
                ELSE
                newlogline = '&gt;'||substr(logline, (textpos + length('>')));
                logline = newlogline;
            END;
            /*Output in HTML file*/
            l = length(logline);
            PUT logline $varying255. l;
        END;

        IF eof THEN DO;
            PUT '</pre>';
            PUT '</body>';
            PUT '</html>';
        END;
    RUN;

    %IF %_handleError(
            &l_macname,
            ErrorWriteHTML,
            &syserr. NE 0,
            Error when writing the HTML file)
        %THEN %GOTO errexit;

    %IF &l_error_count > 0 %THEN %LET &r_rc = 2;
    %ELSE %IF &l_warning_count > 0 %THEN %LET &r_rc = 1;
    %ELSE %LET &r_rc=0;

    %GOTO exit;
    %errexit:
    %exit:
%MEND _reportLogHTML;
/** \endcond */