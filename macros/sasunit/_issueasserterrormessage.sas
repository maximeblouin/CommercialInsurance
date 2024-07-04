/** 
   \file
   \ingroup    SASUNIT_LOG4SAS

   \brief      Issues an error message within an assert to a logger
   
   \details    Asserts will issue messages into a separate log file when using log4sas.
               When an assert fails we want to issue a real error message.
               This is fatal when not using log4sas because it will generate additional erros in the log file

   \version    \$Revision: 743 $
   \author     \$Author: klandwich $
   \date       \$Date: 2020-10-05 11:49:23 +0200 (Mo., 05 Okt. 2020) $
   
   \param     message      Message to be captured by the logger

   \return    message      Message in the associated logger and appender
*//** \cond */
%macro _issueasserterrormessage(message);
   %_issueErrorMessage (&g_log4SASAssertLogger., &message.);
%mend _issueasserterrormessage;
/** \endcond */