/**
   \file
   \ingroup    SASUNIT_UTIL_OS_LINUX

   \brief      escapes blanks with backslashes if runnign under linux or aix

   \version    \$Revision: 635 $
   \author     Klandwich
   \date       \$Date: 2019-02-28 16:50:25 +0100 (Do., 28 Feb. 2019) $

   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/linux/_escapeblanks.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.

   \param   i_string   string to escape blanks in

   \return           modified string
*/ /** \cond */ 

%MACRO _escapeblanks (i_string
                     );

   %IF "&i_string" EQ "" %THEN %RETURN;
   %LET i_string = %sysfunc(tranwrd(&i_string., %str( ),%str(\ )));
   &i_string.

%MEND _escapeblanks;
/** \endcond */
