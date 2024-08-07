/**
   \file
   \ingroup    SASUNIT_ASSERT

   \brief      This assert compares images on equality. It's an implementation to show how to use assertExternal for a specific purpose. 

   \details    As compare tool imageMagick is used. Make sure to use version 6.9 or above since before the compare method always returned 0.
               Beginning with ImageMagick 6.9 the following return codes are used:
                  0: images match
                  1: images different

               Please refer to <A href="https://sourceforge.net/p/sasunit/wiki/User's%20Guide/" target="_blank">SASUnit User's Guide</A>

   \version    Revision: 743
   \author     Klandwich
   \date       2020-10-05
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/assertimage.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
            
   \param      i_script               Path of shell script
   \param      i_expected             Path of first image file (expected)
   \param      i_actual               Path of second image file (actual)
   \param      i_expected_shell_rc    Optional parameter: Expected return value of called script i_script (default = 0)
                                       0 : image match 
                                       >0: images do not match
   \param      i_modifier             Optional parameter: modifiers for the compare (default = "-metric RMSE")
   \param      i_threshold            Optional parameter: further parameter to be passed to the script. Default is 0. To be used especially with
                                      modifier -metric ae to specify a number of pixels that may be different
   \param      i_desc                 Optional parameter: description of the assertion to be checked (default = "Comparison of images")
*/ /** \cond */ 
%MACRO assertImage (i_script             =
                   ,i_expected           =
                   ,i_actual             =
                   ,i_expected_shell_rc  =0
                   ,i_modifier           =-metric RMSE
                   ,i_threshold          =0
                   ,i_desc               =Comparison of images
                   );

   /*-- verify correct sequence of calls-----------------------------------------*/
   %GLOBAL g_inTestCase;
   %endTestCall(i_messageStyle=NOTE);
   %IF %_checkCallingSequence(i_callerType=assert) NE 0 %THEN %DO;      
      %RETURN;
   %END;

   %LOCAL  l_actual
           l_casid 
           l_cmdFile
           l_errmsg
           l_expected
           l_path
           retVal
           l_result
           l_rc
           l_tstid
           xmin
           xsync
           xwait
           l_image1_extension
           l_image2_extension
   ;

   %LET l_errmsg =;
   %LET l_result = 2;
   %LET l_macname  =&sysmacroname;

   %*************************************************************;
   %*** Check if XCMD is allowed                              ***;
   %*************************************************************;
   %IF %_handleError(&l_macname.
                 ,NOXCMD
                 ,(%sysfunc(getoption(XCMD)) = NOXCMD)
                 ,Your SAS Session does not allow XCMD%str(,) therefore assertImage cannot be run.
                 ) 
   %THEN %DO;
      %LET l_rc    =0;
      %LET l_result=2;
      %LET l_errmsg=Your SAS Session does not allow XCMD%str(,) therefore assertImage cannot be run.;
      %GOTO Update;
   %END;

   %*************************************************************;
   %*** Check preconditions                                   ***;
   %*************************************************************;

   %*** Check if i_script file exists ***;
   %IF (%length(&i_script.) <= 0) %THEN %DO;
      %LET l_rc = -2;
      %LET l_errMsg=Parameter i_script is empty!;
      %GOTO Update;
   %END;
   %IF NOT %SYSFUNC(FILEEXIST(&i_script.)) %THEN %DO;
      %LET l_rc = -3;
      %LET l_errMsg=Script &i_script. does not exist!;
      %GOTO Update;
   %END;

   %*** Check if i_expected is a path ***;
   %IF (%length(&i_expected.) <= 0) %THEN %DO;
      %LET l_rc = -4;
      %LET l_errMsg=Parameter i_expected is empty!;
      %GOTO Update;
   %END;

   %*** Check if i_actual is a path ***;
   %IF (%length(&i_actual.) <= 0) %THEN %DO;
      %LET l_rc = -6;
      %LET l_errMsg=Parameter i_actual is empty!;
      %GOTO Update;
   %END;

   %*** get image file extension ***;
   %let l_image1_extension = %str(.)%sysfunc(scan(&i_expected.,-1,.));
   %let l_image2_extension = %str(.)%sysfunc(scan(&i_actual.,-1,.));

   %*** get current ids for test case and test ***;
   %_getScenarioTestId (i_scnid=&g_scnid, r_casid=l_casid, r_tstid=l_tstid);

   %*** create subfolder ***;
   %if (&g_runMode.=SASUNIT_BATCH) %then %do;
      %_createTestSubfolder (i_assertType   =assertimage
                            ,i_scnid        =&g_scnid.
                            ,i_casid        =&l_casid.
                            ,i_tstid        =&l_tstid.
                            ,r_path         =l_path
                            );

   %end;
   %else %do;
      %let l_path=%sysfunc(pathname(WORK));
   %end;
   
   %*** Check if i_expected exists ***;
   %IF %SYSFUNC(FILEEXIST(&i_expected.)) %THEN %DO;
      %_copyFile(&i_expected.                                       /* input file  */
                ,&l_path./_image_exp&l_image1_extension.            /* output file */
                );
   %END;
   %IF %SYSFUNC(FILEEXIST(&i_actual.)) %THEN %DO;
      %_copyFile(&i_actual.                                         /* input file  */
                ,&l_path./_image_act&l_image2_extension.            /* output file */
                );
   %END;
   
   %*** Check if i_expected exists ***;
   %IF NOT %SYSFUNC(FILEEXIST(&i_expected.)) %THEN %DO;
      %LET l_rc = -5;
      %LET l_errMsg=Image &i_expected. does not exist!;
      %GOTO Update;
   %END;
   
   %*** Check if i_actual exists ***;
   %IF NOT %SYSFUNC(FILEEXIST(&i_actual.)) %THEN %DO;
      %LET l_rc = -7;
      %LET l_errMsg=Image &i_actual. does not exist!;
      %GOTO Update;
   %END;

   %*** Check if i_expected_shell_rc is given ***;
   %IF (%length(&i_expected_shell_rc.) <= 0) %THEN %DO;
      %LET l_rc = -8;
      %LET l_errMsg=Parameter i_expected_shell_rc is empty!;
      %GOTO Update;
   %END;
   
   %*** Parameter i_threshold and i_modifier must not be empty due to changes in  ***;
   %*** implementation of ImageMagick compare routine. Otherwise return codes of  ***;
   %*** assertImage are not stable                                                ***;
   %IF ("&i_threshold." EQ "") %THEN %DO;
      %LET i_threshold = 0;
   %END;
   
   %IF ("&i_modifier." EQ "") %THEN %DO;
      %LET i_modifier =-metric RMSE;
   %END;
   
   %*************************************************************;
   %*** Start tests                                           ***;
   %*************************************************************;

   %_xcmdWithPath(i_cmd_path           ="&i_script."
                 ,i_cmd                ="&i_expected." "&i_actual." "&l_path./_image_diff.png" "&i_modifier." "&i_threshold."
                 ,i_expected_shell_rc  =&i_expected_shell_rc.
                 ,r_rc                 =l_rc
                 );

   %IF &l_rc. = &i_expected_shell_rc. %THEN %DO;
      %LET l_result = 0;
   %END;

%UPDATE:
   %*** update result in test database ***;
   %_ASSERTS(i_type     = assertImage
            ,i_expected = &i_expected_shell_rc.#&l_image1_extension.#&i_expected.
            ,i_actual   = &l_rc.#&l_image2_extension.#&i_actual.
            ,i_desc     = &i_desc.
            ,i_result   = &l_result.
            ,i_errmsg   = &l_errmsg.
            );

%MEND assertImage;
/** \endcond */