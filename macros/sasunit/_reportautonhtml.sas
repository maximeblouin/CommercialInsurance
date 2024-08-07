/**
   \file
   \ingroup    SASUNIT_REPORT

   \brief      create a list of units under test for HTML report

   \version    \$Revision: 799 $
   \author     Klandwich
   \date       \$Date: 2022-02-22 15:20:37 +0100 (Di., 22 Feb. 2022) $
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/_reportautonhtml.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
            
   \param   i_repdata      input data set (created in reportSASUnit.sas)
   \param   o_html         flag to output file in HTML format
   \param   o_path         path for output file
   \param   o_file         name of the outputfile without extension
   \param   o_pgmdoc       Switch for generartion of program_documentation (0/1)
   \param   o_crossref     Flag if cross reference was triggered (0 / 1) (optional: Default=G_CROSSREF)
   \param   o_testcoverage Flag if test coverage was triggered (0 / 1) (optional: Default=G_TESTCOVERAGE)
   \param   i_style        Name of the SAS style and css file to be used. 
   \param   i_language     Language of the report (DE, EN) - refer to _nls (optional: Default=&G_LANGUAGE.

*/ /** \cond */ 
%MACRO _reportAutonHTML (i_repdata     = 
                        ,o_html        = 0
                        ,o_path        =
                        ,o_file        =
                        ,o_pgmdoc      =
                        ,o_crossref    =
                        ,o_testcoverage=
                        ,i_style       =
                        ,i_language    =&G_LANGUAGE.
                        );

   /*-- determine number of scenarios 
     and number of test cases per unit under test ----------------------------*/
   %LOCAL 
      d_rep1 
      d_rep2 
      l_tcg_res 
      l_pgmLibraries 
      l_pgmLib 
      l_title 
      l_logpath 
      l_cAuton 
      l_numOfRealScenarios
      l_htmlTitle_center
      l_htmlTitle_left
      l_htmlTitle_right
      l_titleShort
   ;

   %let l_title     =%nrbquote(^{style [url="http://sourceforge.net/projects/sasunit/" postimage="SASUnit_Logo.png"]SASUnit});
   %let l_title     =%str(&g_project. | &l_title. &g_nls_reportAuton_002. | &g_nls_reportAuton_001.);
   %let l_titleShort=%str(&g_project. | &g_nls_reportAuton_002. | &g_nls_reportAuton_001.);
   %*** because in HTML we want to open the link to SASUnit in a new window, ***;
   %*** we need to insert raw HTML ***;
   %let l_htmlTitle_center=<a href="http://sourceforge.net/projects/sasunit/" class="link" title="SASUnit" target="_blank">SASUnit <img src="SASUnit_Logo.png" alt="SASUnit" title="SASUnit" width=26px height=26px align="top" border="0"></a>;
   %let l_htmlTitle_center=%str(&g_project | &l_htmlTitle_center. &g_nls_reportHome_001. | &g_nls_reportAuton_001.);
   %let l_htmlTitle_left  = <a href="https://sourceforge.net/projects/sasunit/reviews" class="link" title="&g_nls_reportHome_038." target="_blank"><img alt="&g_nls_reportAuton_029.";
   %let l_htmlTitle_left  = &l_htmlTitle_left. src="https://img.shields.io/badge/-%scan(&g_nls_reportAuton_029.,1)%20%scan(&g_nls_reportAuton_029.,2)%20%nrstr(&#x2605&#x2605&#x2605&#x2605&#x2606)-brightgreen.svg"</a>;
   %let l_htmlTitle_right = <a href="https://sourceforge.net/projects/sasunit/files/Distributions/stats/timeline" class="link" title="&g_nls_reportHome_038." target="_blank">;
   %let l_htmlTitle_right = &l_htmlTitle_right.<img alt="SASUnit Downloads" src="https://img.shields.io/sourceforge/dm/sasunit.svg"></a>;

   %_tempFileName(d_rep1)
   %_tempFileName(d_rep2)

   PROC MEANS NOPRINT NWAY missing DATA=&i_repdata (KEEP=exa_auton exa_id scn_id cas_id);
      class exa_auton exa_id scn_id cas_id;
      OUTPUT OUT=&d_rep1. (rename=(_FREQ_=scn_tst));
   RUN;

   PROC MEANS NOPRINT NWAY missing DATA=&d_rep1. (KEEP=exa_auton exa_id scn_id scn_tst);
      class exa_auton exa_id scn_id;
      OUTPUT OUT=&d_rep2. (rename=(_FREQ_=scn_cas)) sum(scn_tst)=scn_tst;
   RUN;

   /*-- Keep only one observation per examinee and scenario ---*/
   PROC SORT DATA=&i_repdata. out=work._auton_report;
      BY exa_auton exa_id scn_id;
   RUN;

   DATA work._auton_report;
      SET work._auton_report;
      BY exa_auton exa_id scn_id;
      IF (first.scn_id);
   RUN;

   DATA work._auton_report;
      MERGE work._auton_report &d_rep2.;
      BY exa_auton exa_id scn_id;
   RUN;

   PROC SORT DATA=work._auton_report;
      BY exa_auton exa_pgm scn_id;
   RUN;

   PROC DATASETS NOLIST NOWARN LIB=%scan(&d_rep1.,1,.);
      DELETE %SCAN(&d_rep1.,2,.);
      DELETE %SCAN(&d_rep2.,2,.);
   QUIT;
   
   /* Determine number of real scenarios found in traget.scn */
   proc sql noprint;
      select count(*) into :l_numOfRealScenarios
      from target.scn
      where not missing(scn_start);
   quit;
   %let l_numOfRealScenarios=&l_numOfRealScenarios.;

   /* Visualize crossreference data */
   %IF (&o_crossref. EQ 1 AND &l_numOfRealScenarios. > 0) %THEN %DO;
      PROC SQL;
         create view prepareDependency as
         select distinct cas_obj as name
         from target.cas
      QUIT;

      DATA macrolistDependency;
         SET prepareDependency;
         /* remove .sas extension */
         name = substr(name, 1, length(name)-4);
         /* get program name in case absolute path has been specified */
         pos = find(name,'/',-999);
         IF pos GT 0 THEN DO;
            len = length(trim(name));
            name = substr(name,pos+1,len-pos);
         END;
      RUN;

      /* Create .json Files for visualisation with D3 */
      %_dependency(i_dependencies = &d_listcalling.
                  ,i_macroList    = macrolistDependency
                  );
      /* Use Json Files to create JavaScript file containing dependency information */
      %_dependency_agg(i_path = &g_reportFolder./tempDoc/crossreference
                      ,o_file = &l_output./js/data.refs.js
                      );

      /* Delete data sets after json files have been created */
      PROC DATASETS NOLIST NOWARN LIB=%scan(&d_listcalling,1,.);
         DELETE %SCAN(&d_macrolist,2,.);
         DELETE %SCAN(&d_listcalling,2,.);
      QUIT;
   %END;
   
   %IF (&o_testcoverage. EQ 1  AND &l_numOfRealScenarios. > 0) %THEN %DO;
       /*-- in the log subdir: append all *.tcg files to one file named 000.tcg
        This is done in order to get one file containing coverage data 
        of all calls to the macros under test -----------------------------------*/

      %LET l_rc =%_delFile("&g_scnLogFolder/000.tcg");

      %LET l_logpath=%_escapeBlanks(&g_scnLogFolder.);
      %_mkdir (&g_reportFolder./testDoc/testCoverage);

      FILENAME allfiles "&l_logpath./*.tcg";
      DATA _NULL_;
         INFILE allfiles end=done dlm=',';
         FILE "&l_logpath./000.tcg";
         INPUT row :$256.;
         PUT row;
      RUN;
      
      data WORK._MCoverage_all_macros;
         length MacName $40;
         infile "&l_logpath/000.tcg";
         input;
         RecordType = input (scan (_INFILE_, 1, ' '), ??8.);
         FirstLine  = input (scan (_INFILE_, 2, ' '), ??8.);
         LastLine   = input (scan (_INFILE_, 3, ' '), ??8.);
         MacName    = scan (_INFILE_, 4, ' ');
      run;
   
      proc sort data=WORK._MCoverage_all_macros nodupkey;
         by MacName Firstline RecordType LastLine;
      run;
            
      /*-- for every unit under test (see �target� database ): 
       call new macro _reporttcghtml.sas once in order to get a html 
       file showing test coverage for the given unit under test. For every call, 
       use the 000.tcg file as coverage analysis text file ---------------------*/
      
      PROC SQL NOPRINT;
         SELECT DISTINCT cas_obj 
         INTO :l_unitUnderTestList SEPARATED BY '*'
         FROM work._auton_report;
      QUIT;

      /* Add col tcg_pct to data set &d_rep1 to store coverage percentage for report generation */
      DATA work._auton_report (COMPRESS=YES);
         LENGTH tcg_pct 8;
         SET work._auton_report;
         tcg_pct = .;
      RUN;

      %LET l_listCount=%sysfunc(countw(&l_unitUnderTestList.,'*'));
      %do i = 1 %to &l_listCount;
         %LET l_currentUnit=%lowcase(%scan(&l_unitUnderTestList,&i,*));
         %IF "%sysfunc(compress(&l_currentUnit.))" EQ "" %THEN %DO;
            %LET l_tcg_res = .;
         %END;
         %ELSE %DO;
            /*determine where macro source file is located*/ 
            %let l_currentUnitLocation=;
            %let l_currentUnitFileName=;
            %IF (%SYSFUNC(FILEEXIST(&l_currentUnit.))) %THEN %DO; /*full absolute path given*/
               %_getAbsPathComponents(
                       i_absPath         = &l_currentUnit
                     , o_fileName        = l_currentUnitFileName
                     , o_pathWithoutName = l_currentUnitLocation
                     )
            %END; 
            %ELSE %DO; /*relative path given*/
               %IF (%SYSFUNC(FILEEXIST(&g_root./&l_currentUnit.))) %THEN %DO; /*relative path in root dir */
                  %_getAbsPathComponents(
                       i_absPath         = &g_root./&l_currentUnit.
                     , o_fileName        = l_currentUnitFileName
                     , o_pathWithoutName = l_currentUnitLocation
                     )
               %END;
               %ELSE %DO; /*relative path in one of the sasautos dirs */
                  %IF (%SYSFUNC(FILEEXIST(&g_sasunit./&l_currentUnit.))) %THEN %DO;
                      %_getAbsPathComponents(
                       i_absPath         = &g_sasunit./&l_currentUnit.
                     , o_fileName        = l_currentUnitFileName
                     , o_pathWithoutName = l_currentUnitLocation
                     )
                  %END;
                  %ELSE %IF (%SYSFUNC(FILEEXIST(&g_sasunit_os./&l_currentUnit.))) %THEN %DO;
                      %_getAbsPathComponents(
                       i_absPath         = &g_sasunit_os./&l_currentUnit.
                     , o_fileName        = l_currentUnitFileName
                     , o_pathWithoutName = l_currentUnitLocation
                     )
                  %END;
                  %ELSE %DO;
                     %LET j = 0;
                     %DO %UNTIL ("&l_currentUnitLocation." NE "" OR &j. EQ 10);
                        %IF (%SYSFUNC(FILEEXIST(&&g_sasautos&j/&l_currentUnit.))) %THEN %DO;
                           %_getAbsPathComponents(
                                i_absPath         = &&g_sasautos&j/&l_currentUnit.
                              , o_fileName        = l_currentUnitFileName
                              , o_pathWithoutName = l_currentUnitLocation
                             )
                        %END;
                        %LET j = %EVAL(&j + 1);
                     %END;
                  %END;
               %END;
            %END;
            %let l_tcg_res=.;

            %IF ("&l_currentUnitFileName." NE "" AND "&l_currentUnitLocation." NE "" 
                 AND %SYSFUNC(FILEEXIST(&l_currentUnitLocation./&l_currentUnitFileName.)) 
                 AND %SYSFUNC(FILEEXIST(&g_scnLogFolder./000.tcg)) ) %THEN %DO;
                 %_reporttcghtml(i_macroName                = &l_currentUnitFileName.
                                ,i_macroLocation            = &l_currentUnitLocation.
                                ,i_mCoverageName            = _MCoverage_all_macros
                                ,i_mCoverageLibrary         = WORK
                                ,o_outputFile               = tcg_%SCAN(&l_currentUnitFileName.,1,.)
                                ,o_outputPath               = &g_reportFolder./testDoc/testCoverage
                                ,o_resVarName               = l_tcg_res
                                ,o_html                     = &o_html.
                                ,i_style                    = &i_style.
                                );
            %END;
         %END; /* %ELSE %DO; */
         /* store coverage percentage for report generation */
         PROC SQL NOPRINT;
           UPDATE work._auton_report
             SET tcg_pct=&l_tcg_res.
             WHERE upcase(cas_obj) EQ "%upcase(&l_currentUnit.)";
           UPDATE target.exa
             SET exa_tcg_pct=&l_tcg_res./100
             WHERE upcase(exa_pgm) EQ "%upcase(&l_currentUnit.)";
         QUIT;
      %end; /*do i = 1 to &l_listCount*/
      
      PROC DELETE DATA=WORK._MCoverage_all_macros;
      RUN;
   %END;

   PROC SQL NOPRINT;
      SELECT DISTINCT exa_auton 
      INTO :l_pgmLibraries SEPARATED BY '�'
      FROM work._auton_report;
   QUIT;

   title;
   footnote;
   options nocenter;

   title j=c %sysfunc(quote (&l_title.));

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
                         ,i_current = 4
                         )
   %end;

   options missing=" ";
   %LET l_listCount=%sysfunc(countw(&l_pgmLibraries.,'�'));
   %do i = 1 %to &l_listCount.;
      %LET l_pgmLib=%lowcase(%scan(&l_pgmLibraries,&i,�));
      %LET l_cAuton=;
      %IF (l_pgmLib ne .) %THEN %DO;
         %LET l_cAuton=%sysfunc (putn(&l_pgmLib.,z3.))_;
      %END;
      %ELSE %DO;
         %LET l_cAuton=%sysfunc (putn(99,z3.))_;
      %END;
      data work._current_auton;
         length pgmColumn scenarioColumn caseColumn assertColumn
                %IF &o_testcoverage. EQ 1 %THEN %DO;
                   coverageColumn
                %END;
                %IF &o_crossref. EQ 1 %THEN %DO;
                   crossrefColumn
                %END;
                resultColumn
                linkTitle0  linkTitle1  LinkTitle2  LinkTitle3  LinkTitle4  LinkTitle5
                linkColumn0 linkColumn1 LinkColumn2 LinkColumn3 LinkColumn4 LinkColumn5 $1000
                _autonColumn scn_abs_path pgmdoc_name $400;
         length autonColumn $600;
         set work._auton_report (where=(exa_auton=&l_pgmLib.));
         ARRAY sa(0:29) tsu_sasautos tsu_sasautos1-tsu_sasautos29;
         label 
            pgmColumn="&g_nls_reportAuton_005."
            scenarioColumn="&g_nls_reportAuton_006."
            caseColumn="&g_nls_reportAuton_007."
            assertColumn="&g_nls_reportAuton_014."
            %IF &o_testcoverage. EQ 1 %THEN %DO;
               coverageColumn="&g_nls_reportAuton_016." [%]
            %END;
            %IF &o_crossref. EQ 1 %THEN %DO;
               crossrefColumn="&g_nls_reportAuton_022."
            %END;
            resultColumn="&g_nls_reportAuton_008.";

         if (cas_obj="^_") then cas_obj="";
         scn_abs_path = resolve ('%_abspath(&g_root,' !! trim(scn_path) !! ')');

         %_render_dataColumn(i_sourceColumn=scn_cas
                            ,o_targetColumn=caseColumn
                            );
         %_render_dataColumn(i_sourceColumn=scn_tst
                            ,o_targetColumn=assertColumn
                            );
         %_render_iconColumn(i_sourceColumn=scn_res
                            ,o_html=&o_html.
                            ,o_targetColumn=resultColumn
                            );
         if (exa_auton = .) then do;
            _autonColumn = "&g_nls_reportAuton_015.";
         end;
         else do;
            if (exa_auton = 0) then do;
               _autonColumn = tsu_sasunit;
               linkTitle0   = symget("g_sasunit");
            end;
            else if (exa_auton = 1) then do;
               _autonColumn = tsu_sasunit_os;
               linkTitle0   = symget("g_sasunit_os");
            end;
            else do;
               _autonColumn = sa(exa_auton-2);
               linkTitle0   = symget("g_sasautos" !! compress(put(exa_auton-2, best4.)));
            end;
            linkColumn0  = "file:///" !! linkTitle0;
            linkTitle0   = "&g_nls_reportAuton_009. " !! linkTitle0;
         end;
         %_render_dataColumn(i_sourceColumn=_autonColumn
                            ,i_linkColumn=LinkColumn0
                            ,i_linkTitle=LinkTitle0
                            ,o_targetColumn=autonColumn
                            );
         autonColumn="&g_nls_reportAuton_003.: " !! trim(autonColumn);

         *** Any destination that renders links shares this if ***;
         %if (&o_html.) %then %do;
            LinkTitle1  = "&g_nls_reportAuton_009." !! byte(13) !! exa_filename;
            LinkTitle2  = "&g_nls_reportAuton_010." !! byte(13) !! scn_abs_path;
            LinkTitle3  = "&g_nls_reportAuton_017. " !! cas_obj;
            LinkTitle4  = trim(cas_obj) !! " &g_nls_reportAuton_025.";
            LinkTitle5  = trim(cas_obj) !! " &g_nls_reportAuton_026.";
            pgmexa_name = catt (put (exa_auton, z2.), "_", tranwrd (exa_pgm, ".sas", ""));
            
            *** HTML-links are destination specific ***;
            %if (&o_html.) %then %do;
               LinkColumn1 = catt ("testDoc/src/", put (coalesce (exa_auton,99),z2.), "/", exa_pgm);
               LinkColumn2 = catt ("cas_overview.html#SCN", PUT(scn_id,z3.), "_");
               IF compress(cas_obj) ne '' THEN DO;
                  IF index(cas_obj,'/') GT 0 THEN DO;
                     LinkColumn3 =  'testDoc/testCoverage/tcg_'||trim(LEFT(SCAN(SUBSTR(cas_obj, findw(cas_obj, SCAN(cas_obj, countw(cas_obj,'/'),'/'))),1,".") !! ".html"));
                  END;
                  ELSE DO;
                     LinkColumn3 =  'testDoc/testCoverage/tcg_'||TRIM(LEFT(SCAN(cas_obj,1,".") !! ".html"));
                  END;
               END;
               LinkColumn4 = "&g_nls_reportAuton_023.";
               LinkColumn5 = "&g_nls_reportAuton_024.";

               pgmColumn=catt ('^{style [htmlid="AUTON', put(exa_auton,z3.), '_', put(exa_id,z3.),'_"');
               if (&o_pgmdoc. = 1 and fileexist ("&g_reportFolder./doc/pgmDoc/" !! trim(pgmexa_name) !! ".html")) then do;
                  pgmColumn=catt (pgmColumn, ' url="pgmDoc/', pgmexa_name, '.html" flyover="&g_nls_reportAuton_028."]', cas_obj,'}');
               end;
               else do;
                  pgmColumn=catt (pgmColumn, ' url="', LinkColumn1, '" flyover="', LinkTitle1, '"]', cas_obj,'}');
               end;
            %end;
            %_render_dataColumn(i_sourceColumn=scn_id
                               ,i_format=z3.
                               ,i_linkColumn=LinkColumn2
                               ,i_linkTitle=LinkTitle2
                               ,o_targetColumn=scenarioColumn
                               );
            %IF &o_testcoverage. EQ 1 %THEN %DO;
               %_render_dataColumn(i_sourceColumn=tcg_pct
                                  ,i_format=3.
                                  ,i_linkColumn=LinkColumn3
                                  ,i_linkTitle=LinkTitle3
                                  ,o_targetColumn=coverageColumn
                                  );
            %END;
            %IF &o_crossref. EQ 1 %THEN %DO;            
               %_render_crossrefColumn (i_sourceColumn       = %sysfunc(trim(cas_obj))
                                       ,o_targetColumn       = crossrefColumn
                                       ,i_linkColumn_caller  = LinkColumn4
                                       ,i_linkTitle_caller   = LinkTitle4
                                       ,i_linkColumn_called  = LinkColumn5
                                       ,i_linkTitle_called   = LinkTitle5
                                       );
            %END;
         %END;
      RUN;

      %IF (&i. = &l_listCount.) %THEN %DO;
         %_reportFooter(o_html=&o_html.);
      %END;
      
      %IF (&o_html.) %THEN %DO;
         ods html4 anchor="AUTON&l_cAuton.";
      %END;
      
      PROC REPORT DATA=work._current_auton nowd missing spanrows
            style(lines)=blindData
            ;

         columns autonColumn exa_pgm pgmColumn scenarioColumn caseColumn assertColumn
            %IF &o_testcoverage. EQ 1 %THEN %DO;
                coverageColumn
            %END;
            %IF &o_crossref. EQ 1 %THEN %DO;
               crossrefColumn
            %END;
                resultColumn autonColumn;

         define autonColumn    / noprint;
         define exa_pgm        / order noprint;
         define pgmColumn      / order;
         define scenarioColumn / order style(column)=[just=right];
         define caseColumn     / order style(column)=[just=right];
         define assertColumn   / order style(column)=[just=right];
         %IF &o_testcoverage. EQ 1 %THEN %DO;
            define coverageColumn / order style(column)=[just=right];
         %END;
         %IF &o_crossref. EQ 1 %THEN %DO;
            define crossrefColumn / order style(column)=[just=right];
         %END;
         define resultColumn / order style(COLUMN)=[background=white];

         compute before _page_;
            line @1 autonColumn $;
         endcomp;
      RUN;

      *** Supress title between testcases ***;
      %IF (&i. = 1) %THEN %DO;
         title;
      %END;

      *** Render separation line between program libraries ***;
      %IF (&o_html. AND &i. ne &l_listCount.) %THEN %DO;
         ods html4 text="^{RAW <hr size=""1"">}";
      %END;

      PROC DELETE data=work._current_auton;
      RUN;
   %END;
   OPTIONS missing=.;


   %IF (&o_html.) %THEN %DO;
      %_closeHtmlPage(&i_style.);
   %END;

   TITLE;
   FOOTNOTE;
   OPTIONS center;
   

   PROC DELETE DATA=work._auton_report;
   RUN;
%MEND _reportAutonHTML;
/** \endcond */