/** 
   \file
   \ingroup    SASUNIT_UTIL_OS_WIN

   \brief      set global macro variables for OS commands.

   \version    \$Revision: 788 $
   \author     Klandwich
   \date       \$Date: 2022-01-25 08:09:17 +0100 (Di., 25 Jan. 2022) $
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/windows/_oscmds.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
*/ /** \cond */  
%macro _oscmds;

   %global 
      g_copydir
      g_endcommand
      g_makedir
      g_removedir
      g_sasstart
      g_splash
      g_dateformat
      g_infile_options
      g_osCmdFileSuffix
      g_assertTextIgnoreCase
      g_assertTextCompressBlanks
      ;

   %local
      l_filename
      l_macroName 
   ;   
   
   %LET l_macname=&sysmacroname;

   %LET g_copydir                   =xcopy /E /I /Y;
   %LET g_endcommand                =%str( );
   %LET g_makedir                   =md;
   %LET g_removedir                 =rd /S /Q;
   %LET g_sasstart                  ="%sysfunc(pathname(sasroot))/sas.exe";
   %LET g_splash                    =-nosplash;
   %LET g_infile_options            =IGNOREDOSEOF;
   %LET g_osCmdFileSuffix           =cmd;
   %LET g_assertTextIgnoreCase      =/C;
   %LET g_assertTextCompressBlanks  =/W;

   * retrieve dateformat from WINDOWS registry *;
   * Set default if anything goes wrong *;
   %LET g_dateformat  = _NONE_;

   %*************************************************************;
   %*** Check if XCMD is allowed                              ***;
   %*************************************************************;
   %IF %_handleError(&l_macname.
                 ,NOXCMD
                 ,(%sysfunc(getoption(XCMD)) = NOXCMD)
                 ,Your SAS Session does not allow XCMD%str(,) therefore functionality is restricted.
                 ,i_msgtype=WARNING
                 ) 
   %THEN %DO;
      * Should only be a warning, so reset error flag *;
      %let G_ERROR_CODE =;
      %GOTO Exit;
   %END;

   %let xwait=%sysfunc(getoption(xwait));
   %let xsync=%sysfunc(getoption(xsync));
   %let xmin =%sysfunc(getoption(xmin));

   options noxwait xsync xmin;

   %let l_filename = %sysfunc (pathname (work))\retrive_dateformat.txt;
   %sysexec (reg query "HKCU\Control Panel\International" /v sShortDate > "&l_filename.");

   options &xwait &xsync &xmin;

   data _null_;
      length g_dateformat $40 dateformat $80;
      infile "&l_filename.";
      input;
      if index (upcase (_INFILE_), "REG_SZ") then do;
         dateformat = lowcase (scan (_INFILE_,3," "));
         * Building SAS-format name from WIN-Dateformat *;
         * Set default for dateformat *;
         g_dateformat = "nldate.";
         * Check if monthname is displayed *;
         if (index (dateformat,"mmm")=0) then do;
            * Check order of day month year *;
            index_d=index (dateformat,"d");
            index_m=index (dateformat,"m");
            index_y=index (dateformat,"y");
            if (index_y < index_m) then do;
               if (index_d < index_m) then do;
                  g_dateformat = "yyddmm10.";
               end;
               else do;
                  g_dateformat = "yymmdd10.";
               end;
            end;
            else do;
               if (index_d > index_m) then do;
                  g_dateformat = "mmddyy10.";
               end;
               else do;
                  g_dateformat = "ddmmyy10.";
               end;
            end;
         end;
         call symputx ("G_DATEFORMAT", trim (g_dateformat));
      end;
   run;
%exit:   
%mend _oscmds;
/** \endcond */