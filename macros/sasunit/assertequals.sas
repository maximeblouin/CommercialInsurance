/** 
   \file
   \ingroup    SASUNIT_ASSERT

   \brief      Check whether there are differences between the value of a macro variable and an expected value. 
   
               The values can be character string or numerical.
               Optionally one can define a deviation for numerical values so that the  values can be deviating from each other less than a maximal deviation of i_fuzz.

   \version    Revision: 743
   \author     Klandwich
   \date       2020-10-05
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/assertequals.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
            
   \param   i_expected     expected value
   \param   i_actual       actual value
   \param   i_desc         description of the assertion to be checked \n
                           default: "Compare Values"
   \param   i_fuzz         optional: maximal deviation of expected and actual values, 
                           only for numerical values 
                           
*/ /** \cond */ 
%MACRO assertEquals (i_expected =      
                    ,i_actual   =      
                    ,i_desc     = Compare Values
                    ,i_fuzz     =      
                    );

   /*-- verify correct sequence of calls-----------------------------------------*/
   %GLOBAL g_inTestCase;
   %endTestCall(i_messageStyle=NOTE);
   %IF %_checkCallingSequence(i_callerType=assert) NE 0 %THEN %DO;      
      %RETURN;
   %END;

   %LOCAL l_expected;
   %LET l_expected = &i_expected;
   %LOCAL l_result;

   /* alphanumerical value? */
   %IF   %sysfunc(prxmatch("^[0-9]*.?[0-9]*$",&i_expected))=0 
      OR %sysfunc(prxmatch("^[0-9]*.?[0-9]*$",&i_actual))=0 %THEN %DO; 
      %LET l_result = %eval((%sysfunc(quote(&i_expected)) NE %sysfunc(quote(&i_actual)))*2);
   %END; 
   /* numerical value and fuzz specified ? */
   %ELSE %IF %quote(&i_fuzz) NE %THEN %DO;
      %LET l_expected = %quote(&l_expected(+-&i_fuzz)); 
      %IF %sysevalf(%sysfunc(abs(%sysevalf(&i_expected - &i_actual))) <= &i_fuzz) 
         %THEN %LET l_result = 0;
      %ELSE %LET l_result = 2;
   %END;
   /* numerical without fuzz */
   %ELSE %DO;
      %IF %quote(&i_expected) = %quote(&i_actual)
         %THEN %LET l_result = 0;
      %ELSE %LET l_result = 2;
   %END;

   %_asserts(
       i_type     = assertEquals
      ,i_expected = &l_expected
      ,i_actual   = &i_actual
      ,i_desc     = &i_desc
      ,i_result   = &l_result
   )
%MEND assertEquals;
/** \endcond */