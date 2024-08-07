/**
   \file
   \ingroup    SASUNIT_ASSERT 

   \brief      This assert checks whether a certain number of records exist in a data set specified by parameters i_libref and i_memname.
   
   \deatils    Furthermore a where condition can be specified (if not specified set to 1) as well as the number of expected records 
               in the data set that meet the given where condition.
               
               All counted records are displayed in a report page.

   \version    \$Revision: 816 $
   \author     Klandwich
   \date       \$Date: 2022-05-23 07:58:13 +0200 (Mo., 23 Mai 2022) $
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/assertrecordcount.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
            
   \param     i_libref         library containing the data set
   \param     i_memname        data set to be tested    
   \param     i_operator       optional: logical operator to compare i_recordsExp and l_actual; if not specified "EQ" is assumed as default.
   \param     i_recordsExp     number of records expected: a numeric value >= 0
   \param     i_where          optional: where condition to be checked. Set to 1 by default. 
   \param     i_desc           description of the assertion to be checked \n
                               default: "Check for a specific number of records"
   
*/ /** \cond */ 
%MACRO assertRecordCount(i_libref         = 
                        ,i_memname        = 
                        ,i_operator       = EQ
                        ,i_recordsExp     = 
                        ,i_where          = 1
                        ,i_desc           = Check for a specific number of records
                        );

   /*-- verify correct sequence of calls-----------------------------------------*/
   %GLOBAL g_inTestCase;
   %endTestCall(i_messageStyle=NOTE);
   %IF %_checkCallingSequence(i_callerType=assert) NE 0 %THEN %DO;      
      %RETURN;
   %END;

   %LOCAL l_dsname l_result l_actual l_casid l_tstid l_path;
   %LET l_dsname   = %sysfunc(catx(., &i_libref., &i_memname.));
   %LET l_result   = 2;
   %LET l_actual   = -999;
   %LET i_operator = %sysfunc(upcase(&i_operator.));
   %LET l_errmsg   =;
   
   %IF &i_where. = %THEN %LET i_where=1;
  
   %*************************************************************;
   %*** Check preconditions                                   ***;
   %*************************************************************;
   
   %*** check for valid libref und existence of data set***;
   %IF ((%sysfunc (libref (&i_libref.)) NE 0) or (%sysfunc(exist(&l_dsname)) EQ 0)) %THEN %DO;
      %LET l_actual =-1;
      %LET l_errmsg =Libref is invalid or table does not exist;
      %goto Update;
   %END;

   %*** check for valid parameter i_recordsExp ***;
   DATA _NULL_;
      IF (INPUT(&i_recordsExp., 32.) =.)  then call symput('l_actual',"-3");
      ELSE IF (&i_recordsExp. < 0) then call symput('l_actual',"-4");;
   RUN;
   
   %IF (&l_actual. EQ -3 OR &l_actual. EQ -4) %THEN %DO;
      %LET l_errmsg =Parameter i_recordsExp does not contain a number;
      %goto Update;
   %END;

   %*** check for valid parameter i_operator***;
   DATA _NULL_;
     IF NOT("&i_operator." IN ("EQ", "NE", "GT", "LT", "GE", "LE", "=", "<", ">", ">=", "<=", "~=")) THEN call symput('l_actual',"-5");
   RUN;     
   %IF (&l_actual. EQ -5) %THEN %DO;
      %LET l_errmsg =Parameter i_operator contains an invalid operator;
      %goto Update;
   %END;

   %*************************************************************;
   %*** start tests                                           ***;
   %*************************************************************;
   
   %*** Determine results***;
   PROC SQL noprint;
      create table work._arcTable as
         select *
            from &l_dsname.
            where &i_where.
         ;
      select count(*) into :l_actual 
         from &l_dsname.
         where &i_where.
      ;
   QUIT;
   %IF (&SQLRC. NE 0) %THEN %DO;
      %LET l_actual = -2;
      %LET l_result = 2;
      %goto Update;
   %END;

   %*** Determine results***;
   %IF (&l_actual. &i_operator. &i_recordsExp. AND &l_actual. NE -999) %THEN %DO;
      %LET l_result = 0;
   %END;

   %_getScenarioTestId (i_scnid=&g_scnid, r_casid=l_casid, r_tstid=l_tstid);

   %*** create subfolder ***;
   %if (&g_runMode.=SASUNIT_BATCH) %then %do;
      %_createTestSubfolder (i_assertType   =assertrecordcount
                            ,i_scnid        =&g_scnid.
                            ,i_casid        =&l_casid.
                            ,i_tstid        =&l_tstid.
                            ,r_path         =l_path
                            );

      %*** create library listing ***;
      *** Capture tables instead of ODS DOCUMENT ***;
      libname _arcLib "&l_path.";
      data _arcLib._arcTable;
         set WORK._arcTable;
      run;
      libname _arcLib clear;
   %end;

   proc datasets lib=work nolist memtype=(data view);
      delete _arcTable;
   quit;
%Update:
   *** update result in test database ***;
   %_asserts(i_type     = assertRecordCount
            ,i_expected = %str(&i_operator. &i_recordsExp.)
            ,i_actual   = %str(&l_actual.)
            ,i_desc     = &i_desc.
            ,i_result   = &l_result.
            ,i_errmsg   = &l_errmsg.;
            )
%MEND;
/** \endcond */