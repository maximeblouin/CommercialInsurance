/**
   \file
   \ingroup    SASUNIT_UTIL 

   \brief      standardizes a path makes it relative to a root path

   \version    Revision: 743
   \author     Klandwich
   \date       2020-10-05
   
   \sa         For further information please refer to https://sourceforge.net/p/sasunit/wiki/User%27s%20Guide/
               Here you can find the SASUnit documentation, release notes and license information.
   \sa         \$HeadURL: https://svn.code.sf.net/p/sasunit/code/tags/v2.1/saspgm/sasunit/_stdpath.sas $
   \copyright  This file is part of SASUnit, the Unit testing framework for SAS(R) programs.
               For copyright information and terms of usage under the GPL license see included file readme.txt
               or https://sourceforge.net/p/sasunit/wiki/readme/.
			   
   \param   i_root       root path
   \param   i_path       path to be standardized
   \return  standardized path

*/ /** \cond */ 
%MACRO _stdPath(i_root
               ,i_path
               );

   %IF %LENGTH(&i_root) = 0 %THEN %DO;
     %_issueErrorMessage (&g_currentLogger.,_stdPath: i_root parameter must not be blank);
     %RETURN;
   %END;

   %LET i_root = %sysfunc(translate(&i_root,/,\));

   %IF %LENGTH( %SYSFUNC(COMPRESS(&i_root,/)) ) = 0 %THEN %DO;
     %_issueErrorMessage (&g_currentLogger.,_stdPath: i_root parameter must not be blank);
     %RETURN;
   %END;

   %IF "%substr(&i_root,%length(&i_root),1)" NE "/"
      %THEN %LET i_root = &i_root/;
   %LET i_path = %sysfunc(translate(&i_path,/,\));
   %IF "%substr(&i_path,%length(&i_path),1)" EQ "/"
      %THEN %LET i_path = %substr(&i_path,1,%eval(%length(&i_path)-1));

   %IF %index(%upcase(&i_path)/, %upcase(&i_root)) %THEN %DO;
      %IF %length (&i_path) > %length(&i_root) %THEN %DO;
         %substr(&i_path,%eval(%length(&i_root)+1))
      %END;
   %END;
   %ELSE %DO;
         &i_path
   %END;
%MEND _stdPath;
/** \endcond */