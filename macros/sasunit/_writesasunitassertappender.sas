/**
   \file
   \ingroup    SASUNIT_SETUP

   \brief      Utility macro for SASUnit setup that writes down the Assert Appender section of logConfigXML


   \version    \$Revision: 746 $
   \author     Klandwich
   \date       \$Date: 2020-10-06 14:47:42 +0200 (Di., 06 Okt. 2020) $
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/_writesasunitassertappender.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
            
   \param      i_logpath               Path where the respective log file should be created
   \param      i_append                Parameter value for appen (optional: Default=FALSE)
*/ /** \cond */
%macro _writeSASUnitAssertAppender (i_logpath=
                                   ,i_append = FALSE
                                   );
      put '   <!-- Appender for tracking outcome of asserts -->';
      put '   <appender name="SASUnitAssertsAppender" class="FileAppender">';
      put "      <param name=""File""           value=""&i_logpath./log4sasunit_asserts.log""/>";
      put "      <param name=""Append""         value=""%upcase(&i_append.)""/>";
      put '      <param name="ImmediateFlush" value="TRUE"/>';
      put '   </appender>';
%mend _writeSASUnitAssertAppender;
/** \endcond */