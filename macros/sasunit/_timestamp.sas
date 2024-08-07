/**
   \file
   \ingroup    SASUNIT_UTIL

   \brief      return a formatted timestamp string from a specified datetime value
               or from the current time.

               For instance, to show the current time in the SAS log:: 
               \%PUT \%timestamp; 
               The following call writes a specific datetime to the SAS log: 
               \%PUT \%timestamp('01JAN2000:00:00:00'dt); 

   \version    Revision: 743
   \author     Klandwich
   \date       2020-10-05
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/_timestamp.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
			   
   \param      dt input datetime value or empty to use the current date and time. 

   \return  timestamp in the form yyyy-mm-dd-hh-ss.sss

*/ /** \cond */ 
%MACRO _timestamp(dt);
   %LOCAL dt d t;
   %IF &dt= %THEN %LET dt=%sysfunc(datetime());
   %LET d=%sysfunc(datepart(&dt));
   %LET t=%sysfunc(timepart(&dt));
   %LET h=%sysfunc(hour(&t));
   %LET m=%sysfunc(minute(&t));
   %LET s=%sysfunc(second(&t));
   %sysfunc(putn(&d,yymmdd10.))-%sysfunc(putn(&h,z2.))-%sysfunc(putn(&m,z2.))-%sysfunc(putn(&s,z6.3))
%MEND _timestamp;
/** \endcond */
