/** 
   \file
   \ingroup    SASUNIT_CNTL

   \brief      Creates test data base table tsu.

   \version    Revision: 743
   \author     Klandwich
   \date       2020-10-05
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/_createtestdatatsu.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
            
   \param   libref Library for the test database (optional: Default=target)

*//** \cond */
%macro _createTestDataTSU (libref=target);
   PROC SQL NOPRINT;
      CREATE TABLE &libref..tsu(COMPRESS=CHAR)
      (                                         /* test suite */
          tsu_parameterName   CHAR(50)          /* name of the parameter */             
         ,tsu_parameterValue  CHAR(1000)        /* value of zhe parameter */
         ,tsu_parameterScope  CHAR(1)           /* scope of parameter ('G' / 'L') */
      );
   QUIT;
%mend _createTestDataTSU;
/** \endcond */