/**
   \file
   \ingroup    SASUNIT_UTIL

   \brief      Generates a dataset with the names of all files in a directory.
               Wildcards may be used to specify the files to be included

               Resulting SAS dataset has the columns
               membername (name of the file in the directory)
               filename (name of file with absolute path, path separator is slash) 
               changed (last modification data as SAS datetime).

   \version    \$Revision: 793 $
   \author     Klandwich
   \date       \$Date: 2022-01-25 09:25:57 +0100 (Di., 25 Jan. 2022) $
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/_single_dir.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
            
   \param   i_dsPath     name of sas dataset containing one variable directory. For each observation/directory the search will be done.
   \param   i_pattern    pattern which the filemembers must match
   \param   o_members    output dataset, default is work.dir. This dataset contains three columns
                         named membername, filename and changed (optional: default = work.dir)
   \param   o_subDirs    output dataset. This dataset contains one column named directory and
                         holds all subdirectories (optional: default = _NONE_)
*/ /** \cond */ 
%MACRO _single_dir (i_dsPath=
                   ,i_pattern=_NONE_
                   ,o_members=work.dir
                   ,o_subdirs=_NONE_
                   );

   data work._sd_members
      %if (%quote(&i_pattern.) ne _NONE_) %then %do;
         (where=(upcase (membername) like "%qupcase(&i_pattern.)" escape '^'))
      %end;
      %if (&o_subdirs. ne _NONE_) %then %do;
         &o_subdirs. (keep=filename)
      %end;
      ;
      
      length 
         membername 
         filename    $255
         fileref     $8
      ;

      set &i_dsPath.;

      retain filecounter 0;

      rc = filename ("DIR", Directory);
      d_id = dopen("DIR");
      num  = dnum(d_id);
      if (num < 1) then do;
         rc = log4sas_logevent("&g_currentLogger.", "Info" ,"_single_dir: Given directory is empty: " !! catt (Directory));
      end;
      else do;
         rc = log4sas_logevent("&g_currentLogger.", "Debug" ,"_single_dir: Directory """ !! catt (Directory) !! """ contains " !! catt (num) !! " entries.");
      end;
      do i=1 to num;
         membername = dread (d_id, i);
         filename = catx ("/", directory, membername);
         fileref  = "SF" !! put (filecounter, HEX6.);
         rc = filename (fileref, filename);
         d_dir_id = dopen (fileref);
         if (d_dir_id <= 0) then do;
            output work._sd_members;
         end;
         else do;
            d_dir_id = dclose (d_dir_id);
            rc = log4sas_logevent("&g_currentLogger.", "Debug" ,'_single_dir: Directory "' !! catt (Directory) !! '" contains subdirectory "' !! catt (membername) !! '"');
            rc = filename (fileref, "");
            %if (&o_subdirs. ne _NONE_) %then %do;
               output &o_subdirs.;
            %end;
         end;
         filecounter = filecounter + 1;
      end;
      d_id = dclose (d_id);
      rc = filename ("DIR", "");
      keep fileref filename membername;
   run;

   proc sql noprint;
      create table work._single_dir as 
         select m.*
               ,v.modate as changed format=datetime20. informat=datetime.
         from work._sd_members m left join dictionary.extfiles v
         on m.fileref = v.fileref;
   quit;

   data _null_;
      set work._single_dir;
      rc = filename (fileref, "");
   run;

   data &o_members.;
      set work._single_dir (drop=fileref);
   run;

   proc datasets lib=work nolist;
      delete _sd_members _single_dir;
   run;quit;
%MEND _single_dir;
/** \endcond **/
