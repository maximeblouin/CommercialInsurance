/**
   \file
   \ingroup    SASUNIT_REPORT

   \brief      Creation of XML-based test report according to the JUnit-Sepcification

   \version    Revision: 743
   \author     Klandwich
   \date       2020-10-05
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/_reportjunitxml.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
            
   \param   o_file         Filepath for the XML-report

*/ /** \cond */ 
%MACRO _reportJUnitXML(i_repdata =
                      ,o_file    =
                      );

   /**
    * Preprocess data: Create a table containing the information about the testsuites and testcases.
    */
   %LOCAL _SU_Error;
   %LET _SU_Error = 2; /* Result-Code for failed SASUnit-tests */

   PROC SQL NOPRINT;
      /* Start with the test-scenarion information */
      CREATE TABLE Work.Combined AS
         SELECT DISTINCT  
                  1                     AS isScenario
         ,        0                     AS failures  FORMAT = best12.
         ,        LEFT(PUT(scn_id,z3.)) AS id        LENGTH = 7 FORMAT = $7.       
         ,        0                     AS cas_id
         ,        scn_id                AS scn_id
         ,        scn_desc              AS name
         ,        scn_path              AS classname
         ,        scn_start             AS timestamp FORMAT = e8601dt.
         ,        (scn_end-scn_start)   AS time
         ,        0                     AS tests
         FROM     &i_repdata.
      ;
   
      UPDATE Work.Combined SET time     = 0 WHERE time = .;
      UPDATE Work.Combined SET tests    = (SELECT COUNT(DISTINCT(cas_id)) FROM &i_repdata. WHERE scn_id = Combined.scn_id);
      UPDATE Work.Combined SET failures = (SELECT COUNT(*)                FROM &i_repdata. (where=(tst_res = &_SU_Error.)) WHERE scn_id = Combined.scn_id);

      /* Insert testcases */
      INSERT INTO Work.Combined 
         SELECT  DISTINCT 
                  0                             AS isScenario
         ,        cas_res = &_SU_Error.         AS failures  FORMAT = best12.
         ,        put (scn_id,z3.) !! "-" !! put(cas_id,z3.) 
                                                AS id        LENGTH = 7 FORMAT = $7. 
         ,        cas_id                        AS cas_id
         ,        scn_id                        AS scn_id
         ,        cas_desc                      AS name
         ,        cas_obj                       AS classname 
         ,        cas_start                     AS timestamp FORMAT = e8601dt.
         ,        (cas_end-cas_start)           AS time
         ,        1                             AS tests
         FROM     &i_repdata.
      ;
   QUIT;

   PROC SORT 
      DATA = Work.Combined 
      OUT  = Work.Combined
   ;
      BY /* ASC  */  scn_id
         DESCENDING  isScenario
         /* ASC  */  id
      ;
   RUN;

   /* Assert that the failed tests are listed first */
   PROC SORT
      DATA = &i_repdata.
      OUT  = Work.Failures
   ;
      BY scn_id
         cas_id
         DESCENDING tst_res
         tst_id
      ;
   RUN;

   /* Keep first observation per testcase, i.e. only the first error within a test will be reported */
   DATA Work.Failures ;
      SET Work.Failures;
      BY scn_id
         cas_id
         DESCENDING tst_res
         tst_id
      ;
      if( first.cas_id );
   RUN;

   PROC SQL NOPRINT;
      /* Combine testdata with error messages */
      CREATE TABLE Work.Junit AS 
         SELECT   C.*
            ,     F.tst_errmsg AS message
            ,     F.tst_type   AS type 
            FROM      Work.Combined AS C
            LEFT JOIN Work.Failures AS F
            ON  (    C.SCN_ID = F.SCN_ID
               AND   C.CAS_ID = F.CAS_ID )
      ;

      /* Replace special characters for XML */
      UPDATE Work.Junit SET name = TRANWRD(name, '&', '&amp;' );
      UPDATE Work.Junit SET name = TRANWRD(name, '<', '&lt;'  );
      UPDATE Work.Junit SET name = TRANWRD(name, '>', '&gt;'  );
      UPDATE Work.Junit SET name = TRANWRD(name, '"', '&quot;');

      UPDATE Work.Junit SET message = TRANWRD(message, '&', '&amp;' );
      UPDATE Work.Junit SET message = TRANWRD(message, '<', '&lt;'  );
      UPDATE Work.Junit SET message = TRANWRD(message, '>', '&gt;'  );
      UPDATE Work.Junit SET message = TRANWRD(message, '"', '&quot;');
      UPDATE Work.Junit SET message = '&#160;' where message = "";

      UPDATE Work.Junit SET classname = TRANWRD(classname, '^_', '&#160;');
      UPDATE Work.Junit SET type      = put (TRANWRD(type, '^_', '&#160;'),$32.);
   QUIT;


   /* Print the aggregated table with test information using the JUnit-Tagset */
   options linesize=256;
   ods tagsets.JUnit_XML file="&o_file.";
   PROC PRINT data = Work.JUnit;
   RUN;
   ods tagsets.JUnit_XML close;

   proc datasets lib=work nolist;
      delete Combined Failures Junit;
   run;quit;

%MEND _reportJUnitXML;
/** \endcond */