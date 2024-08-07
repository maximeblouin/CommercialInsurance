/**
   \file
   \ingroup    SASUNIT_SCN 

   \brief      Start of a new test scenario that comprises an invocation of
               a program under test and one or more assertions.

               internally: 
               - Insertion of relevant data into the test repository
               - Determine execution environment
               - Setting of flags g_inScenario, g_inTestcase and g_inTestCall

   \version    \$Revision: 794 $
   \author     Klandwich
   \date       \$Date: 2022-01-27 12:28:33 +0100 (Do., 27 Jan. 2022) $
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/initscenario.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
            
   \param   i_object          relative or absolute path of the scenario source code file (optional: default=_AUTOMATIC_ -> running program is captured from session metadata.)
   \param   i_desc            description of the test case (optional: No default)

*/ /** \cond */ 
%MACRO initScenario(i_object =_AUTOMATIC_
                   ,i_desc   =_NONE_
                   );

   %global g_inScenario g_inTestCase g_inTestCall g_scnID g_currentLogger g_currentLogLevel g_scenarioLogger g_assertLogger;
   %local l_scenarioPath l_macname;

   %let g_scenarioLogger = App.Program.SASUnitScenario;
   %let g_assertLogger   = App.Program.SASUnitScenario.Asserts;

   %LET g_currentLogger   = &g_scenarioLogger;
   %LET g_currentLogLevel = DEBUG;
   /*** Setting logging information  ***/
   %_setLog4SASLogLevel (loggername =&g_currentlogger.
                        ,level      =&g_currentLogLevel.
                        );   
   
   %_initErrorHandler;
   %LET l_macname=&sysmacroname;
   
   %if (%_handleError(&l_macname.
                     ,CallSequenceScenario
                     ,(&g_inScenario. EQ 1)
                     ,initScenario must not be called twice!
                     ) 
       ) %then %return;
   %if (%_handleError(&l_macname.
                     ,CallSequenceScenario
                     ,(&g_inTestCase. EQ 1)
                     ,initScenario must not be called within a testcase!
                     ) 
       ) %then %return;
   %if (%_handleError(&l_macname.
                     ,CallSequenceScenario
                     ,(&g_inTestCall. EQ 1)
                     ,initScenario must not be called within a testcall!
                     ) 
       ) %then %return;
       
   %let g_inScenario=0;
   %let g_inTestCase=0;
   %let g_inTestCall=0;
   
   %_readEnvMetadata;
   
   %local l_changed l_scnID;
   %let l_scnid =0;

   /* set global macro symbols and librefs / filerefs  */
   /* includes creation of autocall paths */
   %_loadenvironment (i_caller=SCENARIO);
   
   %LET g_currentLogger   = &g_log4SASScenarioLogger.;
   %LET g_currentLogLevel = &g_log4SASScenarioLogLevel.;
   /*** Setting logging information  ***/
   %_setLog4SASLogLevel (loggername =&g_currentLogger.
                        ,level      =&g_currentLogLevel.
                        );   

   %if (%bquote(&i_object.) ne _AUTOMATIC_) %then %do;
       %let l_scenarioPath           =%_stdPath(&g_ROOT, &i_object.);
       %let g_runningProgramFullName =&l_scenarioPath.;
   %end;

   filename _CUR_SCN "&g_runningProgramFullName.";
   proc sql noprint;
      select put (max(1,max(scn_id)+1), z3.) into :g_scnID from target.scn;
      select modate into :l_changed from sashelp.vextfl where fileref="_CUR_SCN";
      select scn_id into :l_scnID 
         from target.scn 
         where "&g_runningProgramFullName." contains trim(scn_path);
      select scn_id into :g_scnID 
         from target.scn 
         where "&g_runningProgramFullName." contains trim(scn_path);
   quit;
   filename _CUR_SCN clear;
   
   %let l_changed="&l_changed."dt;

   proc sql noprint;
      %if (&l_scnID. = 0) %then %do;
        insert into target.scn VALUES (&g_scnID.,"%_stdpath(&g_root., &g_runningProgramFullName.)","&i_desc.",%sysfunc(datetime()),.,&l_changed.,.,.,.,.);
      %end;
      %else %do;
         update target.scn 
            set
                scn_start   =%sysfunc(datetime())
               ,scn_changed =&l_changed.
            %if (%nrbquote(&i_desc.) ne _NONE_) %then %do;
               ,scn_desc    ="&i_desc"
               %end;         
            where scn_id = &g_scnID.;
      %end;
      delete from target.cas where cas_scnid=&g_scnID.;
      delete from target.tst where tst_scnid=&g_scnID.;
   quit;
   
   options linesize=max;
   
   %let g_inscenario=1;

   %_nls(i_language=&g_LANGUAGE.);
   
   %_issueInfoMessage(&g_currentLogger., --------------------------------------------------------------------------------)
   %_issueInfoMessage(&g_currentLogger., Starting scenario (&g_scnid.) &g_runningProgramFullName. (InitScenario))
   %_issueInfoMessage(&g_currentLogger., --------------------------------------------------------------------------------)
   
%MEND initScenario;
/** \endcond */
