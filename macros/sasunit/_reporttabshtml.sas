/**
   \file
   \ingroup    SASUNIT_REPORT

   \brief      create tabs on HTML page for report

   \version    Revision: 743
   \author     Klandwich
   \date       2020-10-05
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/_reporttabshtml.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
			   
   \param   i_tabnames     tab labels, in quotes and separated by blanks
   \param   i_pages        page names for hyperlinks for each tab, in quotes and separated by blanks,
                           same number of entries as in i_tabnames
   \param   i_current      number of the active tab, default is 1

*/ /** \cond */ 
%MACRO _reportTabsHTML (i_tabnames
                       ,i_pages
                       ,i_current = 1
                       );

   %let l_string=^{RAW <ul class="tabs">;
   
   %LOCAL i l_class l_string;
   %LET i=1;
   %DO %WHILE(%sysfunc(scanq(&i_tabnames, &i)) NE );
      %LET l_class=;
      %IF &i=&i_current %THEN %DO;
         %let l_class=id="current";
      %END;
      %let l_string=&l_string. <li &l_class.><a href="%sysfunc(compress(%sysfunc(scanq(&i_pages, &i)),%str(%")))">%sysfunc(compress(%sysfunc(scanq(&i_tabnames, &i)),%str(%")))</a></li>;
      %LET i=%eval(&i+1);
   %END;

   %let l_string=&l_string. </ul>};
   title2 %sysfunc(quote(&l_string.));
%MEND _reportTabsHTML;
/** \endcond */