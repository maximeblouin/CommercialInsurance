/**
   \file
   \ingroup    SASUNIT_REPORT

   \brief      renders the layout of the actual column for _render_assertRowExpression

   \version    Revision: 743
   \author     Klandwich
   \date       2020-10-05
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/_render_assertrowexpressionact.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
			   
   \param   i_sourceColumn name of the column holding the value
   \param   o_html         Test report in HTML-format?
   \param   o_targetColumn name of the target column holding the ODS formatted value

*/ /** \cond */  
%macro _render_assertRowExpressionAct (i_sourceColumn=
                                      ,o_html=0
                                      ,o_targetColumn=
                                      );
   href     = catt ('_',put (scn_id, z3.),'_',put (cas_id, z3.),'_',put (tst_id, z3.));
   %if (&o_html.) %then %do;
      href_exp = catt (href,'_are_rep.html');
   %end;
   &o_targetColumn. = catt (&i_sourceColumn.
                           ,"^n^{style [flyover=""&g_nls_reportRowExpression_005."" url="""
                           ,href_exp
                           , """] &g_nls_reportRowExpression_004.}"
                           );
%mend _render_assertRowExpressionact;
/** \endcond */