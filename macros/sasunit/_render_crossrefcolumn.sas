/**
   \file
   \ingroup    SASUNIT_REPORT

   \brief      Renders layout of cross reference column.
               Two links are render:
               - who is calling this module
               - which modules are called by this module

   \version    Revision: 743
   \author     Klandwich
   \date       2020-10-05
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/_render_crossrefcolumn.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
			   
   \param   i_sourceColumn       SourceColumn with basic contents
   \param   o_targetColumn       Name of output column
   \param   i_linkColumn_caller  Link to HTML page with calling sequence of module
   \param   i_linkTitle_caller   Flyover for this link
   \param   i_linkColumn_called  Link to HTML page with called sequence of module
   \param   i_linkTitle_called   Flyover for this link
   
*/ /** \cond */ 
%macro _render_crossrefColumn (i_sourceColumn       =
                              ,o_targetColumn       =
                              ,i_linkColumn_caller  =
                              ,i_linkTitle_caller   =
                              ,i_linkColumn_called  =
                              ,i_linkTitle_called   =
                              );
   len = length(trim(cas_obj));
   cas_pgm_strip = substrn(cas_obj, 1, len-4);
   
   href_caller     = "crossref.html?casPgm="||trim(cas_pgm_strip)||'%nrstr(&)call=caller';
   href_called     = "crossref.html?casPgm="||trim(cas_pgm_strip)||'%nrstr(&)call=called';

   &o_targetColumn. = catt ('^{style [flyover="', &i_linkTitle_caller., '" url="' !! href_caller !! '"] ', &i_linkColumn_caller.,'} ^n ');
   &o_targetColumn. = catt (&o_targetColumn., '^{style [flyover="', &i_linkTitle_called., '" url="' !! href_called !! '"] ', &i_linkColumn_called., '}');
   
%mend _render_crossrefColumn;
/** \endcond */