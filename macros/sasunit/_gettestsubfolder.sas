/** 
   \file
   \ingroup    SASUNIT_UTIL

   \brief      Determines and returns the path for test subfolders.

   \version    Revision: 743
   \author     Klandwich
   \date       2020-10-05
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/_gettestsubfolder.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
			   
   \param   i_assertType Type of assert for which the subfolder should be returned
   \param   i_root       path to which the folder should be appended <em>(optional: Default=%sysfunc(pathname(testout)))</em>
   \param   i_scnid      Current scenario id
   \param   i_casid      Current test case is
   \param   i_tstid      Current assert id
   \retval  r_path       Complete absolute path for test outputs

*/ /** \cond */ 
%macro _getTestSubfolder (i_assertType=
                         ,i_root      =%sysfunc(pathname(testout))
                         ,i_scnid     =
                         ,i_casid     =
                         ,i_tstid     =
                         ,r_path      =
                         );

   %local l_scnid_string l_subfoldername;

   %if %nrbquote (&i_assertType.) = %str() %then %do;
      %_issueErrorMessage (&g_currentLogger.,_getTestSubfolder: Please specify a value for i_assertType.);
      %RETURN;
   %end;
   %if %nrbquote (&i_root.) = %str() %then %do;
      %_issueErrorMessage (&g_currentLogger.,_getTestSubfolder: Please specify a value for i_root.);
      %RETURN;
   %end;
   %if not %_existdir (&i_root.) %then %do;
      %_issueErrorMessage (&g_currentLogger.,_getTestSubfolder: Please specify a valid directory for i_root.);
      %RETURN;
   %end;
   %if %nrbquote (&i_scnid.) = %str() %then %do;
      %_issueErrorMessage (&g_currentLogger.,_getTestSubfolder: Please specify a value for i_scnid.);
      %RETURN;
   %end;
   %if %nrbquote (&i_casid.) = %str() %then %do;
      %_issueErrorMessage (&g_currentLogger.,_getTestSubfolder: Please specify a value for i_casid.);
      %RETURN;
   %end;
   %if %nrbquote (&i_tstid.) = %str() %then %do;
      %_issueErrorMessage (&g_currentLogger.,_getTestSubfolder: Please specify a value for i_tstid.);
      %RETURN;
   %end;
   %if %nrbquote (&r_path.) = %str() %then %do;
      %_issueErrorMessage (&g_currentLogger.,_getTestSubfolder: Please specify a value for r_path.);
      %RETURN;
   %end;
   %if not %symexist(&r_path.) %then %do;
      %_issueErrorMessage (&g_currentLogger.,_getTestSubfolder: Macrovariable for return of subfolder path was not declared by a %nrstr(%%)local-statement.);
      %RETURN;
   %end;

   %let l_scnid_string =_%sysfunc(putn (&i_scnid,z3.))_%sysfunc(putn (&i_casid.,z3.))_%sysfunc (putn (&i_tstid.,z3.));
   %let l_subfoldername=&l_scnid_string._%lowcase(&i_assertType.);
   %let &r_path.=%_abspath (i_root=&i_root., i_path=&l_subfoldername.);
%mend;
/** \endcond */