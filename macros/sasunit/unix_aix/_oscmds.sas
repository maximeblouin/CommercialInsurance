/**
   \file
   \ingroup    SASUNIT_UTIL_OS_UNIX_AIX

   \brief      set global macro variables for OS commands.

   \version    \$Revision: 807 $
   \author     Klandwich
   \date       \$Date: 2022-03-02 14:39:19 +0100 (Mi., 02 März 2022) $

   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/unix_aix/_oscmds.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
*/ /** \cond */  
%macro _oscmds;

   %global 
      g_removedir 
      g_copydir
      g_endcommand
      g_makedir
      g_sasstart
      g_splash
      g_infile_options
      g_osCmdFileSuffix
      g_assertTextIgnoreCase
      g_assertTextCompressBlanks
      ;
      
   %local
      l_macroName 
   ;   
   %LET l_macroName=&sysmacroname;

   %LET g_removedir                 =rm -r -f;
   %LET g_copydir                   =cp -R;
   %LET g_endcommand                =%str( );
   %LET g_makedir                   =mkdir;
   %LET g_sasstart                  ="%sysfunc(pathname(sasroot))/bin/sas_&g_language.";
   %LET g_splash                    =;   
   %LET g_infile_options            =;
   %LET g_osCmdFileSuffix           =sh;
   %LET g_assertTextIgnoreCase      =-i;
   %LET g_assertTextCompressBlanks  =-b;
   
   %*************************************************************;
   %*** Check if XCMD is allowed                              ***;
   %*************************************************************;
   %IF %_handleError(&l_macroName.
                 ,NOXCMD
                 ,(%sysfunc(getoption(XCMD)) = NOXCMD)
                 ,Your SAS Session does not allow XCMD%str(,) therefore functionality is restricted.
                 ,i_msgtype=WARNING
                 ) 
   %THEN %DO;
      * Should only be a warning, so reset error flag *;
      %let G_ERROR_CODE =;
   %END;
   %ELSE %DO;
      %_xcmd(umask 0033);
   %END;
   
   options nobomfile;

%mend _oscmds;
/** \endcond */