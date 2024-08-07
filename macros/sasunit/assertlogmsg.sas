/**
   \file
   \ingroup    SASUNIT_ASSERT 

   \brief      Check whether a certain message appears in the log.

               If the message does not appear in the log as expected, the check of the assertion will fail.
               If i_not is set to 1, the check of the assertion will fail in case the message is found in the log.

   \version    \$Revision: 791 $
   \author     Klandwich
   \date       \$Date: 2022-01-25 08:13:41 +0100 (Di., 25 Jan. 2022) $
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/assertlogmsg.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
            
   \param   i_logmsg          message of interest (Perl Regular Expression), non-case-sensitive log scan,
                              special characters have to be quoted with a prefixed single backslash,
                              see http://support.sas.com/onlinedoc/913/getDoc/de/lrdict.hlp/a002288677.htm#a002405779
   \param   i_desc            description of the assertion to be checked \n
                              default: "Scan for log messages"
   \param   i_not             negates the assertion, if set to 1 (optional: default = 0)
   \param   i_logfile         for testing purposes it is necessary to provide a logfile name (optional: default = &g_caslogfile.)
   \param   i_case_sensitive  flag if regEx should be treated caseSensitiv 0/1 (optional: default = 1)
   
*/ /** \cond */ 
%MACRO assertLogMsg (i_logmsg          =       
                    ,i_desc            = Scan for log messages  
                    ,i_not             = 0
                    ,i_logfile         = &g_caslogfile.
                    ,i_case_sensitive  = 1
                    );

   /*-- verify correct sequence of calls-----------------------------------------*/
   %GLOBAL g_inTestCase;
   %endTestCall(i_messageStyle=NOTE);
   %IF %_checkCallingSequence(i_callerType=assert) NE 0 %THEN %DO;      
      %RETURN;
   %END;

   %LOCAL 
      l_casid 
      l_msg_found 
      l_actual 
      l_expected 
      l_assert_failed 
      l_errmsg
      l_regex_modfifer
   ;

   PROC SQL NOPRINT;
      /* determine number of the current test case */
      SELECT max(cas_id) INTO :l_casid FROM target.cas WHERE cas_scnid = &g_scnid;
   QUIT;

   %LET l_errmsg=_NONE_;

   %IF (&g_runmode. EQ SASUNIT_INTERACTIVE 
        AND %nrbquote (&i_logfile.) = %str()
       ) %THEN %DO;
      %let l_assert_failed=1;
      %let l_errmsg=Current SASUnit version does not support interactive execution of assertLogMsg.;
      %let l_actual=-1;
      %let l_expected=-1;
      %goto exit;
   %END;

   %if (&i_case_sensitive.) %then %do;
      %let l_regex_modfifer =;
   %end;
   %else %do;
      %let l_regex_modfifer =i;
   %end;

   /* Scanne den Log */
   %LET l_msg_found=0;
   DATA _null_;
      RETAIN pattern_id;
      IF _n_=1 THEN DO;
         pattern_id = prxparse("/&i_logmsg/&l_regex_modfifer.");
      END;
      INFILE "&i_logfile." END=eof TRUNCOVER &g_infile_options.;
      INPUT logrec $char256.;
      logrec = logrec;
      IF prxmatch (pattern_id, logrec) THEN DO;
         call symput ('l_msg_found', '1');
      END;
   RUN;

   %IF &l_msg_found. %THEN %DO;
      %LET l_actual = 1; /* message found */
   %END;
   %ELSE %DO;
      %LET l_actual = 2; /* message not found */
   %END;

   %IF &i_not. %THEN %DO;
      %LET l_expected = 2&i_logmsg; /* message not present */
      %LET l_assert_failed = %eval (&l_msg_found.*2);
   %END;
   %ELSE %DO;
      %LET l_expected = 1&i_logmsg; /* message present */
      %LET l_assert_failed = %eval((NOT &l_msg_found)*2);
   %END;
%exit:
   %_asserts(i_type     =assertLogMsg
            ,i_expected =%str(&l_expected.)
            ,i_actual   =%str(&l_actual.)
            ,i_desc     =&i_desc.
            ,i_result   =&l_assert_failed.
            ,i_errmsg   =&l_errmsg.
            )

%MEND assertLogMsg;
/** \endcond */