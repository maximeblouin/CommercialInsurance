/**
   \file
   \ingroup    SASUNIT_UTIL_OS_WIN

   \brief      copy a complete directory tree.
               Uses Windows XCOPY or Unix cp

   \version    \$Revision: 801 $
   \author     \$Author: klandwich $
   \date       \$Date: 2022-02-22 15:21:57 +0100 (Di., 22 Feb. 2022) $

   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/windows/_copydir.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.

   \param   i_from       root of directory tree
   \param   i_to         copy to 
   \return  operation system return code or 0 if OK
*/ /** \cond */ 

%macro _copyDir (i_from
                ,i_to
                );

   %LOCAL l_i_from l_i_to logfile;

   /* save and modify os command options */
   %local xwait xsync xmin;
   %let xwait=%sysfunc(getoption(xwait));
   %let xsync=%sysfunc(getoption(xsync));
   %let xmin =%sysfunc(getoption(xmin));
   options noxwait xsync xmin;

   %let l_i_from  = %_makeSASUnitPath(&i_from.);
   %let l_i_from  = %_adaptSASUnitPathToOS(&l_i_from.);
   %let l_i_to    = %_makeSASUnitPath(&i_to.);
   %let l_i_to    = %_adaptSASUnitPathToOS(&l_i_to.);
   %let logfile = %sysfunc(pathname(work))\___log.txt;
   
   %PUT _LOCAL_;

   /*-- XCOPY
        /E copy directories (even empty ones) and files recursively 
        /I do not prompt before file or directory creation
        /Y do not prompt before overwriting target
     --*/
   %sysexec (xcopy &l_i_from &l_i_to /E /I /Y > "&logfile" 2>&1);
   
   %_issueDebugMessage (&g_currentLogger., _copyDir: %str(======== OS Command Start ========));
    /* Evaluate sysexec�s return code*/
   %IF &sysrc. = 0 %THEN %DO;
      %_issueDebugMessage (&g_currentLogger., _copyDir: Sysrc : 0 -> SYSEXEC SUCCESSFUL);
   %END;
   %ELSE %DO;
      %_issueErrorMessage (&g_currentLogger., _copyDir: &sysrc -> An Error occured);
   %END;

   /* put sysexec command to log*/
   %_issueDebugMessage (&g_currentLogger., _copyDir: xcopy &l_i_from &l_i_to /E /I /Y > "&logfile");
      
   %if (&g_currentLogLevel. = DEBUG or &g_currentLogLevel. = TRACE) %then %do;
      /* write &logfile to the log*/
      data _null_;
         infile "&logfile" truncover lrecl=512;
         input line $512.;
         putlog line;
      run;
   %end;

   %_issueDebugMessage (&g_currentLogger., _copyDir: %str(======== OS Command End ========));
   
   options &xwait &xsync &xmin;

%mend _copyDir;
/** \endcond */