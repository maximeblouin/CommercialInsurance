/**
   \file
   \ingroup    SASUNIT_REPORT

   \brief      create a list of test cases for HTML report

   \version    \$Revision: 759 $
   \author     Klandwich
   \date       \$Date: 2020-10-09 11:01:09 +0200 (Fr., 09 Okt. 2020) $
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/_reportcashtml.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
            
   \param   i_repdata      input dataset (created in reportSASUnit.sas)
   \param   o_html         flag to output file in HTML format
   \param   o_path         path for output file
   \param   o_file         name of the outputfile without extension
   \param   o_pgmdoc       Switch for generartion of program_documentation (0/1)
   \param   i_style        Name of the SAS style and css file to be used. 

*/ /** \cond */ 
%MACRO _reportCasHTML (i_repdata = 
                      ,o_html    = 0
                      ,o_path    =
                      ,o_file    =
                      ,o_pgmdoc  =
                      ,i_style   =
                      );

   %LOCAL
      l_nls_reportcas_errors
      l_anzScenarios
      l_scnid
      l_title 
      l_footnote
      l_htmlTitle_center
      l_htmlTitle_left
      l_htmlTitle_right
      l_titleShort
   ;

   %LET l_nls_reportcas_errors   = %STR(error(s));

   %let l_title     =%nrbquote(^{style [url="http://sourceforge.net/projects/sasunit/" postimage="SASUnit_Logo.png"]SASUnit});
   %let l_title     =%str(&g_project. | &l_title. &g_nls_reportCas_002. |  &g_nls_reportCas_001.);
   %let l_titleShort=%str(&g_project. | &g_nls_reportCas_002. | &g_nls_reportCas_001.);
   %*** because in HTML we want to open the link to SASUnit in a new window, ***;
   %*** we need to insert raw HTML ***;
   %let l_htmlTitle_center=<a href="http://sourceforge.net/projects/sasunit/" class="link" title="SASUnit" target="_blank">SASUnit <img src="SASUnit_Logo.png" alt="SASUnit" title="SASUnit" width=26px height=26px align="top" border="0"></a>;
   %let l_htmlTitle_center=%str(&g_project | &l_htmlTitle_center. &g_nls_reportHome_001. | &g_nls_reportCas_001.);
   %let l_htmlTitle_left  = <a href="https://sourceforge.net/projects/sasunit/reviews" class="link" title="&g_nls_reportHome_038." target="_blank"><img alt="&g_nls_reportAuton_029.";
   %let l_htmlTitle_left  = &l_htmlTitle_left. src="https://img.shields.io/badge/-%scan(&g_nls_reportAuton_029.,1)%20%scan(&g_nls_reportAuton_029.,2)%20%nrstr(&#x2605&#x2605&#x2605&#x2605&#x2606)-brightgreen.svg"</a>;
   %let l_htmlTitle_right = <a href="https://sourceforge.net/projects/sasunit/files/Distributions/stats/timeline" class="link" title="&g_nls_reportHome_038." target="_blank">;
   %let l_htmlTitle_right = &l_htmlTitle_right.<img alt="SASUnit Downloads" src="https://img.shields.io/sourceforge/dm/sasunit.svg"></a>;

   data work._case_report;
      SET &i_repdata. end=eof;
      BY scn_id cas_id;

      LENGTH 
         scn_abs_path abs_path    $  256 
         hlp         $  20
         errcountmsg $ 50
         LinkTitle1
         LinkTitle2
         LinkTitle3
         LinkTitle4
         LinkTitle5
         LinkColumn1
         LinkColumn2
         LinkColumn3
         LinkColumn4
         LinkColumn5 $200
         scnIdColumn idColumn $80
         scnDescriptionColumn descriptionColumn $1000
         scnProgramColumn programColumn $1000
         scnLast_runColumn last_runColumn $1000
         scnDurationColumn durationColumn $1000
         resultColumn $1000;
         ;
      label idColumn="&g_nls_reportCas_011."
         scnIdColumn="&g_nls_reportCas_011."
         scnDescriptionColumn="&g_nls_reportCas_003."
         descriptionColumn="&g_nls_reportCas_012."
         scnProgramColumn="&g_nls_reportCas_004."
         programColumn="&g_nls_reportCas_013."
         scnLast_runColumn="&g_nls_reportCas_022."
         last_runColumn="&g_nls_reportCas_014."
         scnDurationColumn="&g_nls_reportCas_008."
         durationColumn="&g_nls_reportCas_015."
         resultColumn="&g_nls_reportCas_016."
         ;

      *** initalizing variables that MAY be used in a specific assert   ***;
      if (_N_=1) then do;
         hlp="";
      end;
         
      if (first.cas_id) then do;
         *** Columns for scenario overview ***;
         IF scn_errorcount GT 0 THEN DO;
            errcountmsg = '(' !! compress(put(scn_errorcount, 3.)) !! ' ' !! "&l_nls_reportcas_errors." !! ')';
         END;
         ELSE DO;
            errcountmsg = '';
         END;

         scn_abs_path = resolve ('%_abspath(&g_root,' !! trim(scn_path) !! ')');
         scn_pgm      = scan (scn_abs_path, -1, "/");
         scn_duration = put (scn_end - scn_start, ??&g_nls_reportScn_013.) !! " s";
         c_scnid      = put (scn_id, z3.);
         pgmdoc_name  = catt ("scn_", put (scn_id, z3.));

         %_render_idColumn   (i_sourceColumn=scn_id
                             ,i_format=z3.
                             ,o_targetColumn=ScnIdColumn
                             );
         %_render_dataColumn (i_sourceColumn=scn_desc
                             ,o_targetColumn=scnDescriptionColumn
                             );
         %_render_dataColumn (i_sourceColumn=scn_duration
                             ,o_targetColumn=scnDurationColumn
                             );

         *** Any destination that renders links shares this if ***;
         %if (&o_html.) %then %do;
            LinkTitle1   = "&g_nls_reportScn_010" !! byte(13) !! scn_abs_path;
            LinkTitle2   = "&g_nls_reportScn_011";
            *** HTML-links are destinations specific ***;
            %if (&o_html.) %then %do;
               if (&o_pgmdoc. = 1 and fileexist ("&g_reportFolder./doc/pgmDoc/"!!trim(pgmdoc_name)!!".html")) then do;
                  LinkColumn1 = catt ("pgmDoc/", pgmdoc_name, ".html");
               end;
               else do;
                  LinkColumn1 = catt ("testDoc/src/scn/scn_", put (scn_id,z3.), ".sas");
               end;
               LinkColumn2  = catt ("testDoc/", c_scnid,  "_log.html");
            %end;
            %_render_dataColumn (i_sourceColumn=scn_path
                                ,i_linkColumn  =LinkColumn1
                                ,i_linkTitle   =LinkTitle1
                                ,o_targetColumn=scnProgramColumn
                                );
            scnLast_runColumn = catt ('^{style [flyover="',LinkTitle2,'" url="',LinkColumn2,'"]', put (scn_start, ??&g_nls_reportScn_012.),'}'
                                     ,"^{style logerrcountmsg ", errcountmsg, '}');
         %end;

         *** Columns for test cases ***;
         if (cas_obj="^_") then cas_obj="";
         IF exa_auton = . THEN DO;
            abs_path = resolve ('%_abspath(&g_root,' !! trim(cas_obj) !! ')');   
         END;
         ELSE IF exa_auton = 0 THEN DO;
            abs_path = resolve ('%_abspath(&g_sasunit' !! ',' !! trim(cas_obj) !! ')');
         END;
         ELSE IF exa_auton = 1 THEN DO;
            abs_path = resolve ('%_abspath(&g_sasunit_os' !! ',' !! trim(cas_obj) !! ')');
         END;
         ELSE DO;
            abs_path = resolve ('%_abspath(&g_sasautos' !! put (exa_auton-2,1.) !! ',' !! trim(cas_obj) !! ')');
         END;

         duration    = put (cas_end - cas_start, ??&g_nls_reportScn_013.) !! " s";
         c_casid     = put (cas_id, z3.);
         pgmdoc_name = catt (put (exa_auton, z2.), "_", tranwrd (exa_pgm, ".sas", ""));

         %_render_idColumn   (i_sourceColumn=cas_id
                             ,i_format=z3.
                             ,o_targetColumn=idColumn
                             );
         %_render_dataColumn (i_sourceColumn=duration
                             ,o_targetColumn=durationColumn
                             );
         %_render_iconColumn (i_sourceColumn=cas_res
                             ,o_html=&o_html.
                             ,o_targetColumn=resultColumn
                             );
         *** Any destination that renders links shares this if ***;
         %if (&o_html.) %then %do;
            LinkTitle3  = "&g_nls_reportCas_017 " !! c_casid;
            LinkTitle4  = "&g_nls_reportCas_018" !! byte(13) !! abs_path;
            LinkTitle5  = "&g_nls_reportCas_006";
            *** HTML-links are destinations specific ***;
            %if (&o_html.) %then %do;
               LinkColumn3 = catt ("testDoc/cas_", c_scnid, "_", c_casid,  ".html");
               if (&o_pgmdoc. = 1 and fileexist ("&g_reportFolder./doc/pgmDoc/" !! trim(pgmdoc_name) !! ".html")) then do;
                  LinkColumn4 = catt ("pgmDoc/", pgmdoc_name, ".html");
               end;
               else do;
                  LinkColumn4 = catt ("testDoc/src/", put (coalesce (exa_auton,99),z2.), "/", exa_pgm);
               end;
               LinkColumn5 = catt ("testDoc/", c_scnid, "_", c_casid, "_log.html");
            %end;

            %_render_dataColumn (i_sourceColumn=cas_desc
                                ,i_linkColumn=LinkColumn3
                                ,i_linkTitle=LinkTitle3
                                ,o_targetColumn=descriptionColumn
                                );
            %_render_dataColumn (i_sourceColumn=cas_obj
                                ,i_linkColumn=LinkColumn4
                                ,i_linkTitle=LinkTitle4
                                ,o_targetColumn=programColumn
                                );
            %_render_dataColumn (i_sourceColumn=cas_start
                                ,i_format=&g_nls_reportCas_007.
                                ,i_linkColumn=LinkColumn5
                                ,i_linkTitle=LinkTitle5
                                ,o_targetColumn=last_runColumn
                                );
         %end;
         output;
      end;
   run;
   
   proc sql noprint;
      select max (scn_id) into :l_anzScenarios from work._case_report;
   quit;

   options nocenter;

   title j=c %sysfunc(quote(&l_title.));

   %if (&o_html.) %then %do;
      %*** because in HTML we want to open the link to SASUnit in a new window, ***;
      %*** we need to insert raw HTML ***;
      title j=l %sysfunc (quote(^{RAW &l_htmlTitle_left.}))
            j=c %sysfunc (quote(^{RAW &l_htmlTitle_center.}))
            j=r %sysfunc (quote(^{RAW &l_htmlTitle_right.}))
      ;
            
      ods html4 file="&o_path./&o_file..html" 
                    (TITLE=%sysfunc (quote (&l_titleShort.)))
                    headtext='<link rel="shortcut icon" href="./favicon.ico" type="image/x-icon" />'
                    metatext="http-equiv=""Content-Style-Type"" content=""text/css"" /><meta http-equiv=""Content-Language"" content=""&i_language."" /"
                    style=styles.&i_style. stylesheet=(URL="css/&i_style..css")
                    encoding="&g_rep_encoding.";
      %_reportPageTopHTML(i_title   = &l_titleShort.;
                         ,i_current = 3
                         )
   %end;
   %do l_scnid=1 %to &l_anzScenarios.;
      data work._current_scn;
         set work._case_report (where=(scn_id=&l_scnid.));
      run;

      data work._current_scn_overview;
         set work._current_scn (where=(cas_id=1));
         length Name $20 Value $1000;
         Name="&g_nls_reportCas_011."; Value=c_scnid;output;
         Name="&g_nls_reportCas_003."; Value=scnDescriptionColumn;output;
         Name="&g_nls_reportCas_004."; Value=scnProgramColumn;output;
         Name="&g_nls_reportCas_022."; Value=scnLast_runColumn;output;
         Name="&g_nls_reportCas_008."; Value=scnDurationColumn;output;
         keep Name Value;
      run;
      *** Create specific HTML-Anchors ***;
      %if (&o_html.) %then %do;
         ods html4 anchor="SCN%sysfunc(putn(&l_scnid.,z3.))_";
      %end;
      proc print data=work._current_scn_overview noobs label 
            style(report)=blindTable [borderwidth=0]
            style(column)=blindData
            style(header)=blindHeader;
      run;

      *** Supress title between testcases ***;
      %if (&l_scnid. = 1) %then %do;
         title;
      %end;

      *** Show footnote only once ***;
      %if (&l_scnid. = &l_anzScenarios.) %then %do;
         %_reportFooter(o_html=&o_html.);
      %end;

      proc report data=work._current_scn nowd missing
            style(lines)=blindData
            ;

         columns idColumn descriptionColumn programColumn last_runColumn durationColumn resultColumn;

         define idColumn         / display style(Column)=rowheader;
         define durationColumn   / display style(Column)=[just=right];
         define resultColumn     / display style(Column)=[background=white];

         compute before _page_;
            line @1 "&g_nls_reportCas_010."; 
         endcomp;
      run;

      *** Render separation line between scenarios ***;
      %if (&o_html. AND &l_scnid. ne &l_anzScenarios.) %then %do;
         ods html4 text="^{RAW <hr size=""1"">}";
      %end;

      proc delete data=work._current_scn_overview;
      run;
      proc delete data=work._current_scn;
      run;
   %end;

   %if (&o_html.) %then %do;
      %_closeHtmlPage(&i_style.);
   %end;

   proc delete data=work._case_report;
   run;

   %*** Reset title and footnotes ***;
   title;
   footnote;

   options center;
%MEND _reportCasHTML;
/** \endcond */