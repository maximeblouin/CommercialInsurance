/**
   \file
   \ingroup    SASUNIT_UTIL

   \brief      delete all SAS datasets in the form WORK.DATAxxx, see tempFileName.sas

          define global symbol g_deltempfiles_debug if datasets should not be deleted

          if l_first_temp has been set to a number by the calling program, (see macro tempFileName) 
          only temporary datasets beginning with that number will be deleted. 

   \%delTempFiles;

   \version    Revision: 743
   \author     Klandwich
   \date       2020-10-05
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/_deltempfiles.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
			   
*/ 
/** \cond */ 
%MACRO _delTempFiles;

   %IF NOT %symexist(g_deltempfiles_debug) %THEN %DO;

      DATA _null_;
         SET sashelp.vtable END=eof;
         WHERE libname = 'WORK' AND memname LIKE 'DATA%';
         IF _n_=1 THEN 
            CALL EXECUTE ('PROC SQL NOPRINT;');
      %IF %symexist(l_first_temp) %THEN %DO;
         %IF &l_first_temp NE %THEN %DO;
         IF input(substr(memname,5),8.) >= &l_first_temp;
         %END;
      %END;
         CALL execute ('DROP TABLE ' !! memname !! ';');
         IF eof THEN 
            CALL execute ('QUIT;');
      RUN;

   %END;

%MEND _delTempFiles;
/** \endcond */