/**
   \file
   \ingroup    SASUNIT_SETUP

   \brief      Wrapper macro for sasunitsetup that deals with parameters and autocall paths


   \version    \$Revision: 774 $
   \author     Klandwich
   \date       \$Date: 2021-05-10 14:56:09 +0200 (Mo., 10 Mai 2021) $
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/runsasunitsetup.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
            
   \param i_sasunitRootFolder    Path and name of the root folder of SASUnit
   \param i_projectRootFolder    Path and name of the root folder of the project
   \param i_sasunitLogFolder     Path and name of the folder for SASUnit suite log files (run_all.log and new ones)
   \param i_sasunitScnLogFolder  Path and name of the folder for SASUnit scenario log files (001.log, 001_001.log etc.)
   \param i_sasunitTestDBFolder  Path and name of the folder for SASUnit test data base (tsu, exa, scn, cas, tst)
   \param i_projectBinFolder     Path and name of the folder where the binaries of the project should reside
   \param i_sasunitLanguage      Language that should be used inside SASUnit (de or en)
   \param i_sasunitRunAllPgm     Path an name of run_all.sas
   \param i_operatingSystem      Operating system that is used to execute SASUnit
   \param i_sasVersion           SAS Version that is used to run SASUnit
   \param i_sasExe               Path and name of the sas executable
   \param i_sasConfig            Path and name of the sas config file
   \param i_sasunitReportFolder  Path and name of the folder where the documentation should be geenarted in
   \param i_sasunitLogLevel      Default logging level for SASUnit suite
   \param i_sasunitScnLogLevel   Default logging level for SASUnit scenarios
   \param i_OSEncoding           Encoding of OS which can be different from encoding of SAS session
*/ /** \cond */
%let g_sSASUnitRootFolder     = %sysget (SASUNIT_ROOT);
%let g_sProjectRootFolder     = %sysget (SASUNIT_PROJECTROOT);
%let g_sSASUnitLogFolder      = %sysget (SASUNIT_LOG_PATH);
%let g_sSASUnitScnLogFolder   = %sysget (SASUNIT_SCN_LOG_PATH);
%let g_sasunitTestDBFolder    = %sysget (SASUNIT_TESTDB_PATH);
%let g_sSASUnitRunAllPgm      = %sysget (SASUNIT_RUNALL);
%let g_sSASUnitHostOS         = %sysget (SASUNIT_HOST_OS);
%let g_sSASUnitSASVersion     = %sysget (SASUNIT_SAS_VERSION);
%let g_sSASUnitSASExe         = %sysget (SASUNIT_SAS_EXE);
%let g_sSASUnitConfig         = %sysget (SASUNIT_SAS_CFG);
%let g_sSASUnitLanguage       = %sysget (SASUNIT_LANGUAGE);
%let g_sSASUnitReportFolder   = %sysget (SASUNIT_REPORT_PATH);
%let g_sSASUnitLogLevel       = %sysget (SASUNIT_LOG_LEVEL);
%let g_sSASUnitScnLogLevel    = %sysget (SASUNIT_SCN_LOG_LEVEL);
%let g_currentLogger          = App.Program;
%let g_OSEncoding             = %sysget (SASUNIT_HOST_ENCODING);

options mrecall mprint;
options append=(SASAUTOS=("&g_sSASUnitRootFolder./saspgm/sasunit" "&g_sSASUnitRootFolder./saspgm/sasunit/%lowcase(%sysget(SASUNIT_HOST_OS))"));

%SASUnitSetup(i_sasunitRootFolder   =&g_sSASUnitRootFolder.
             ,i_projectRootFolder   =&g_sProjectRootFolder.
             ,i_sasunitLogFolder    =&g_sSASUnitLogFolder.
             ,i_sasunitScnLogFolder =&g_sSASUnitScnLogFolder.
             ,i_sasunitTestDBFolder =&g_sasunitTestDBFolder.
             ,i_projectBinFolder    =&g_sProjectRootFolder./bin
             ,i_sasunitLanguage     =&g_sSASUnitLanguage.
             ,i_sasunitRunAllPgm    =&g_sSASUnitRunAllPgm.
             ,i_operatingSystem     =&g_sSASUnitHostOS.
             ,i_sasVersion          =&g_sSASUnitSASVersion.
             ,i_sasExe              =&g_sSASUnitSASExe.
             ,i_sasConfig           =&g_sSASUnitConfig.
             ,i_sasunitReportFolder =&g_sSASUnitReportFolder.
             ,i_sasunitLogLevel     =&g_sSASUnitLogLevel.
             ,i_sasunitScnLogLevel  =&g_sSASUnitScnLogLevel.
             ,i_OSEncoding          =&g_OSEncoding.
             );     
/** \endcond */             