/**
   \file
   \ingroup    SASUNIT_UTIL_OS_WIN

   \brief      macro function, that makes path containing only slashes. For windows you need to use translate function 

   \version    \$Revision: 737 $
   \author     \$Author: klandwich $
   \date       \$Date: 2020-03-18 11:10:56 +0100 (Mi., 18 März 2020) $
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/windows/_makesasunitpath.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
            
*/ /** \cond */
%macro _makeSASUnitPath (path);
   %local l_path;
   %let l_path=&path.;
   %if (%length (&path.) > 0) %then %do;
      %let l_path = %qsysfunc (dequote (&path.));
      %let l_path = %qsysfunc (translate (&l_path., /, \));
   %end;
   &l_path.
%mend _makeSASUnitPath; 
/** \endcond */

