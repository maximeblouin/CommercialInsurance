/**
   \file
   \ingroup    SASUNIT_UTIL_OS_WIN

   \brief      execute an command file by operation system command

   \version    \$Revision: 752 $
   \author     Klandwich
   \date       \$Date: 2020-10-08 09:35:43 +0200 (Do., 08 Okt. 2020) $
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/windows/_executecmdfile.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
            
   \param   i_cmdFile            Command file to be executed by the OS
   \param   i_operator           Operator for evaluation of the shell command return code
   \param   i_expected_shell_rc  Command file to be executed by the OS

*/ 
/** \cond */ 

%macro _executeCMDFile(i_cmdFile
                      ,i_operator
                      ,i_expected_shell_rc
                      );
                 
   %_xcmd("&i_cmdFile.", &i_operator., &i_expected_shell_rc.)

%mend _executeCMDFile;   

/** \endcond */
