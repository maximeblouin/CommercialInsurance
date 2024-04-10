%macro list_files(dir, ext);
    %local filrf rc did memcnt name i;
    %let rc=%sysfunc(filename(filrf, &dir));
    %let did=%sysfunc(dopen(&filrf));

    %if &did eq 0 %then
        %do;
            %put Directory &dir cannot be open or does not exist;
            %return;
        %end;

    %do i=1 %to %sysfunc(dnum(&did));
        %let name=%qsysfunc(dread(&did, &i));

        %if %qupcase(%qscan(&name, -1, .))=%upcase(&ext) %then
            %do;
                %let pathname=&dir/&name;
                %put &pathname;
                %include "&pathname.";
            %end;
        %else %if %qscan(&name, 2, .)=%then
            %do;
                %list_files(&dir//&name, &ext);
            %end;
    %end;
    %let rc=%sysfunc(dclose(&did));
    %let rc=%sysfunc(filename(filrf));
%mend list_files;

%list_files(%sysfunc(pathname(HOME))/CommercialInsurance/macros, sas);


libname DATA "/home/maximeblouin0/CommercialInsurance/data/";
