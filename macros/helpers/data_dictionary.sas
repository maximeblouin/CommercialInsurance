/**
    \file
    \ingroup    HELPERS
    \brief      Macro for generating a data dictionary
    \details    This macro generates a data dictionary for specified datasets,
                including variable information and formats.
    \author     Maxime Blouin
    \date       29APR2024
    \param      i_project Name of the data project (not used)
    \param      i_dslist List of datasets to include in the data dictionary
    \param      o_htmlpath Output HTML path for the data dictionary
    \param      o_framename Name of the HTML frame (not used)
    \sa         https://support.sas.com/resources/papers/proceedings/proceedings/sugi27/p099-27.pdf
    \remark     Here's an example usage of the `data_dictionary`:
                %data_dictionary(
                    i_project=SasHelp Data,
                    i_dslist=stpsamp.* sashelp.cars sample_data,
                    o_htmlpath=%sysfunc(pathname(HOME))/CommercialInsurance,
                    o_framename=data_dict.htm);
    \todo       The HTML frame is not working. We should have left pane with the list of dataset link.
                When we click on the link the metadata show up on the right panel. So parameter &o_framename.
                is not used.
*/

/** \cond */

%macro data_dictionary(
    i_project=,
    i_dslist=,
    o_htmlpath=,
    o_framename=);

    /* Step 1: Flesh out the dataset list */
    %let NewDS=;

    %let NumDS = %sysfunc(countw(&i_dslist));
    %put &=NumDS;
    %do i = 1 %to &NumDS;
        %let _piece = %upcase(%scan(&i_dslist, &i, %str( )));
        %put &=_piece.;

        /* Check if _piece is empty */
        %if (%length(&_piece) <= 0) %then %do;
            %goto CONTINUE_LOOP;
        %end;

        /* Process table without libname */
        %if %index(&_piece, .) eq 0 %then %do;
            %let _piece = "WORK.&_piece";
            %let NewDS=&NewDS &_piece;
        %end;

        /* Process wildcards */
        %else %if %index(&_piece, *) ne 0 %then %do;
            proc sql noprint;
                select CAT('"', compress(libname||'.'||memname), '"')
                into :BigList separated by ' '
                from sashelp.vstable
                where libname eq "%scan(&_piece,1,.)";
            quit;
            %let NewDS=&NewDS &BigList;
        %end;

        /* Process table with libname */
        %else %if %index(&_piece, .) ne 0 %then %do;
            %let _piece = "&_piece";
            %let NewDS=&NewDS &_piece;
        %end;

        %CONTINUE_LOOP:
    %end;

    %put &=NewDS.;

    /* Step 2: Get Variable Information */
    /* SQL query to retrieve variable information */
    proc sort data=sashelp.vcolumn out=vcolumn; by libname memname; run;
    proc sort data=sashelp.vtable out=vtable; by libname memname; run;

    data DSinfo (keep = libname memname name type length label format informat idxusage);
        merge vcolumn (keep = libname memname name type length label format informat idxusage)
            vtable (keep = libname memname);
        by libname memname;
        where catx('.', libname, memname) in (&NewDS);
    run;

    /* Step 3: Get a List of the Available Formats */
    /* Retrieve FMTSEARCH value */
    %let FmtList = %upcase(%cmpres(%sysfunc(getoption(fmtsearch))));
    /* Strip parentheses from the value */
    %let FmtList = %sysfunc(compress(&FmtList, "()"));
    %put &=FmtList.;

    %if %sysfunc(fileexist(work.formats)) %then %do;
        %let fixfmtp = %str(WORK) || " " || %sysfunc(compress(&FmtList, '()'));
    %end;
    %else %do;
        %let fixfmtp = %sysfunc(compress(&FmtList, '()'));
    %end;

    %put &=fixfmtp.;

    %let NumCats= %sysfunc(countw(&FmtList));

    /* Process FMTSEARCH value */
    data _FmtList;
        length FormatEntry $100;

        %do i = 1 %to &NumCats;
            %let CatName = %scan(&FmtList, &i, %str( ));
            %put &=CatName.;
            /* One-level catalog name */
            %if %index(&CatName, .) eq 0 %then
                %do;
                    %put "A";
                    FormatEntry = "&CatName..FORMATS";
                %end;
            /* Two-level catalog name */
            %else %do;
                %put "B";
                FormatEntry = "&CatName";
            %end;
            ListPosition = &i;
            output;
        %end;
    run;

    /* Step 4: Match Formats to Variable List */

    /* Unduplicate dataset by format name and position in the FMTSEARCH list */
    proc sort data=_FmtList nodupkey out=_FmtListUndup;
        by FormatEntry ListPosition;
    run;

    /* Create _FormatsToFind dataset containing format name and type */
    proc sql;
        create table _FormatsToFind as
        select distinct
            FormatEntry as ObjName,
            'FORMAT' as ObjType
        from _FmtListUndup;
    quit;

    /* Create _FmtHits dataset containing matched formats */
    proc sql;
        create table _FmtHits as
        select distinct
            h.FormatEntry as ObjName,
            'FORMAT' as ObjType,
            f.fmtname as Format,
            f.libname,
            f.memname
        from _FmtListUndup as h
        inner join sashelp.vformat as f
        on h.FormatEntry = catx('.', f.libname, f.memname)
        order by h.ListPosition;
    quit;

    /* SQL query to match formats to variables */
    proc sql;
        create table _FormatsFound as
        select h.*, Format
        from _FmtHits h, _FormatsToFind f
        where h.ObjName eq f.ObjName and h.ObjType eq f.ObjType
        order by libname, memname;
    quit;

    /* Step 5: Generate HTML files for formats */
    /* Create a macro variable containing all format names */
    proc sql noprint;
        select distinct format, libname
        into :format_array separated by ' ', :fmtlib_array separated by ' '
        from _FormatsFound;
    quit;

    %put &=format_array.;
    %put &=fmtlib_array.;

    /* Loop through the format names and create CNTLOUT datasets */
    %let num_formats = %sysfunc(countw(&format_array.));
    %do i = 1 %to &num_formats.;
        %let lib=%scan(&fmtlib_array., &i., ' ');
        %put &=lib.;
        %let FmtName=%scan(&format_array., &i., ' ');
        %put &=FmtName.;
        /* PROC REPORT to generate HTML files */
        ods html
            body="formats/&&lib..&FmtName..htm"
            path="&o_htmlpath" (url=none)
            style=HTMLBlue;

        title "Contents of format: &FmtName - (in catalog: &&lib)";

        /* Create CNTLOUT dataset for the current format */
        proc format cntlout=_temp;
            select &FmtName.;
        run;

        /* Determine whether the format contained any ranges or if all start and end values were the same. */

        %let Ranges = 0;
        data _null_;
            set _temp;

            if Start ne End then call symputx('Ranges', 1);
        run;

        %if &Ranges gt 0 %then %do;
            proc sql;
                select
                    Start label='Range Start',
                    End label='Range End',
                    Label
                from _temp;
            quit;
        %end;
        %else %do;
            proc sql;
                select
                    Start label='Value',
                    Label
                from _temp;
            quit;
        %end;
        ods html close;

        /* Add fmtlink and FormatLib to work.DSinfo */
        data DSinfo;
            format fmtlink $256. FormatLib $8.;
            set DSinfo;

            if format eq "&FmtName.." then do;
                fmtlink="&o_htmlpath./formats/&&lib..&FmtName..htm";
                FormatLib="&lib.";
            end;
        run;

        title;
    %end;

    /* Step 6: Generate Dataset Output */
    ods html
        body="&o_htmlpath./index.htm"
        headtext="<title>Data Dictionary - Project: &i_project</title>";

    %let num_datasets = %sysfunc(countw(%str(&NewDS), %str( )));
    %put &=num_datasets.;

    %do i = 1 %to &num_datasets;
        %let datasetname=%scan(%sysfunc(compress(&NewDS.,'"')), &i, %str( ));
        %put &=datasetname.;
        %let _lib = %scan(&datasetname., 1, %str(.));
        %put &=_lib.;
        %let memname = %scan(&datasetname., 2, %str(.));
        %put &=memname.;
        %let path=TODO;
        %let MEMLABEL=TODO;

        /* Define other variables */
        %let maxlen = 32;

        proc report data=DSinfo (where=(libname eq "&_lib." and memname eq "&memname."))
                nowd headline headskip split='*'
                contents='Variable List';
            column name fmtlink type length format
                FormatLib informat idxusage label;

            define name / order order=data 'Variable*Name' width=&maxlen;
            define type / display 'Type' width=6;
            define length / display 'Length' width=8;
            define format / display 'Format' width=10;
            define FormatLib / display 'Format*Catalog' width=15;
            define informat / display noprint;
            define idxusage / display 'Index*Usage' width=11;
            define label / display 'Label';
            define fmtlink / display noprint;

            compute before _page_ /
                    style = [just=left
                            font_face=Arial
                            font_size=3
                            background=white
                            foreground=red];
                DSN = "Dataset Name: &memname (in &path)";
                DSL = "Dataset Label: &memlabel";
                line ' ';
                line @1 DSN $120.;
                line @1 DSL $120.;
                line ' ';
            endcomp;

            compute format;
                if not missing(fmtlink) then call define('format',"URL",fmtlink);
            endcomp;
        run;
    %end;
    ods html close;

%mend data_dictionary;

/** \endcond */
