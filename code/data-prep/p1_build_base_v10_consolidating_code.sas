
******************************************************************************;
*** PROGRAM:  P1_BUILD_BASE_V10_CONSOLIDATING_CODE.SAS                     ***;                       
***                                                                        ***;
*** LOCATION: GOODLAND Server:                                             ***;
***           /projects/Lumina_SocIndOfPostSec/Code/generation_6_progs     ***;
*** PROGRAMMERS:    Jeff Harrington and Nick Mader                         ***;
*** DESCRIPTION:   This program selects applicable obs from the yearly     ***;
***                pulls of CPS data, and preps the data for the birth     ***;
***                cohort builds, as well as the data analysis.            ***;
***                                                                        ***;
***                                                                        ***;
*** CREATED:       10/23/13                                                ***;
*** UPDATES:       02/26/14 by Jeff Harrington                             ***;
***                   Deleted and modified code per comments by Nick Mader ***;
***                   (related to streamlining program flow and correcting ***;
***                   improper yearly initializations and data updates).   ***;
***                02/07/14 by Nick Mader                                  ***;
***                   Have changed organization of the commands to         ***;
***                   condense code, and make year-to-year contrasts       ***;
***                   easier to see.                                       ***;
***                10/23/13 by Jeff Harrington                             ***;
***                   Corrected Array calls (removed erroneous 'if').      ***;
***                   Re-ran to product complete cohort build.             ***;
***                   Removed unnecessary libnames per Nick notes          ***;
***                10/19/13 by Nick Mader                                  ***;
***                   Organizing code to, at end, produce cohort averages  ***;
***                   08/01/13 by Jeff Harrington                          ***;
***                   Re-name per archival program plan.                   ***;
***                   Clean-up unnecessary commented code.                 ***;
***                   Adjust per new cohort build method.                  ***;
***                05/20/13 by Jeff Harrington                             ***;
***                   Clean up extraneous code, add comments, and add code ***;
***                   to produce initial descriptives for var evaluation   ***;
***                   (for deadline of 5/31/13).                           ***;
***                04/09/13 by Jeff Harrington                             ***;
***                   Adjust code to remove the use of the hhid2 var from  ***;
***                   the hierarchy of joins.                              ***;
***                                                                        ***;        
******************************************************************************;
options nomprint nomlogic nosymbolgen spool;
libname here '/projects/Lumina_SocIndOfPostSec/Data';
libname cpschek '/researchdata/il/cps/geocoded_results';
filename discvars '/projects/Lumina_SocIndOfPostSec/Code/generation_6_progs/p2_build_discrete_indicators_v7_final_education_updates.sas';
filename varlab '/projects/Lumina_SocIndOfPostSec/Code/var_labels.sas';
filename varform '/projects/Lumina_SocIndOfPostSec/Code/var_formats.sas';

**************************;
***USER DEFINED FORMATS***;
**************************;
%include varform;
run;

/**STANDARDIZE DATA FOR EACH YEARLY DATA FILE (1968-2011)**/

%MACRO ReadSurveyYearData;
	%DO y = 1968 %TO 2011;
			
	/***DECLARE RENAMING STATEMENTS***/
		%IF       1968 <= &y. AND &y. <= 1972 %THEN %LET RenameStatement = (rename=(faminctmp=faminc));
		%ELSE %IF 1973 <= &y. AND &y. <= 1988 %THEN %LET RenameStatement = (rename=(faminctmp=faminc spntmp=spneth));
		%ELSE %LET RenameStatement = ;
		
	/***INITIALIZE LENGTHS AND DATA TYPES FOR VARIABLES NOT COMING IN FOR DIFFERENT SURVEY YEARS***/
	%IF 1968 <= &y. AND &y. <= 1969 %THEN %LET LengthStatement = length lnmom lndad dipged grdatn hsged hhtype famnum parent famrel famtyp 
       chgrd spneth col faminctmp 3 hhwgt wgt 6 hhid2 $ 5;
  %IF 1970 <= &y. AND &y. <= 1972 %THEN %LET LengthStatement = length lnmom lndad dipged grdatn hsged hhtype famnum parent famrel famtyp 
       chgrd hhwgt wgt 6 hhid2 $ 5 spneth faminctmp 3;
	%IF 1973 <= &y. AND &y. <= 1978 %THEN %LET LengthStatement = length lnmom lndad dipged grdatn hsged hhtype famnum parent famrel famtyp chgrd 3 hhwgt wgt 6 faminctmp spntmp 3;
	%IF 1979 <= &y. AND &y. <= 1983 %THEN %LET LengthStatement = length lnmom lndad dipged grdatn hsged hhtype famnum parent famrel famtyp chgrd 3 hhwgt 6 faminctmp spntmp 3;
	%IF 1984 <= &y. AND &y. <= 1987 %THEN %LET LengthStatement = length lnmom lndad dipged grdatn hsged 3 hhwgt 6 faminctmp spntmp 3;
	%IF 1988 <= &y. AND &y. <= 1988 %THEN %LET LengthStatement = length lnmom lndad dipged grdatn 3 hhwgt 6 faminctmp spntmp 3; 
	%IF 1989 <= &y. AND &y. <= 1991 %THEN %LET LengthStatement = length lnmom lndad dipged grdatn hhrel 3;
	%IF 1992 <= &y. AND &y. <= 1993 %THEN %LET LengthStatement = length lnmom lndad dipged _educ hhrel 3;
	%IF 1994 <= &y. AND &y. <= 1995 %THEN %LET LengthStatement = length lnmom lndad dipged _educ hhrel 3 wgt 6;
	%IF 1996 <= &y. AND &y. <= 1997 %THEN %LET LengthStatement = length lnmom lndad dipged _educ hhrel 3 wgt 6; 
	%IF 1998 <= &y. AND &y. <= 1999 %THEN %LET LengthStatement = length lnmom lndad _educ hhrel 3 wgt 6;
	%IF 2000 <= &y. AND &y. <= 2000 %THEN %LET LengthStatement = length lnmom lndad famrel famtyp  _educ hhrel 3 wgt 6;
	%IF 2001 <= &y. AND &y. <= 2003 %THEN %LET LengthStatement = length lnmom lndad _educ hhrel 3 wgt 6;
	%IF 2004 <= &y. AND &y. <= 2005 %THEN %LET LengthStatement = length lnmom lndad momtyp dadtyp _educ hhrel 3 wgt 6;
	%IF 2006 <= &y. AND &y. <= 2006 %THEN %LET LengthStatement = length lnmom lndad momtyp dadtyp _educ hhrel 3;
	%IF 2007 <= &y. AND &y. <= 2011 %THEN %LET LengthStatement = length _educ hhrel 3;
		
    %IF 1968 <= &y. AND &y. <= 1973 %THEN %LET KeepVars = _year recnum lineno hhid rrp mis wgtfnl hhnum state age sex race grdatt schatt _educ colftpt hhrel faminc;
    %IF 1973 <= &y. AND &y. <= 1983 %THEN %LET KeepVars = _year recnum lineno hhid rrp mis wgtfnl hhnum state age sex race spneth grdatt schatt _educ col colftpt hhrel faminc;
    %IF 1984 <= &y. AND &y. <= 1988 %THEN %LET KeepVars = _year recnum lineno hhid rrp mis wgtfnl famwgt famnum hhnum state age sex race spneth grdatt chgrd schatt _educ col colftpt famrel hhrel famtyp faminc parent hhtype ;
    %IF 1989 <= &y. AND &y. <= 1991 %THEN %LET KeepVars = _year recnum lineno hhid rrp mis wgtfnl famwgt hhwgt vetwgt famnum hhnum state age sex race spneth grdatt chgrd schatt _educ hsged col colftpt famrel famtyp faminc parent hhtype ;    
    %IF 1992 <= &y. AND &y. <= 1993 %THEN %LET KeepVars = _year recnum lineno hhid rrp mis wgtfnl famwgt hhwgt vetwgt famnum hhnum state age sex race spneth grdatt chgrd schatt hsged col colftpt famrel famtyp faminc parent hhtype ;
    %IF 1994 <= &y. AND &y. <= 1997 %THEN %LET KeepVars = _year recnum lineno hhid rrp mis wgtfnl famwgt hhwgt vetwgt wgtl famnum hhnum state age sex race spneth grdatt grdatn chgrd schatt hsged col colftpt famrel famtyp faminc parent hhtype  ;
    %IF 1998 <= &y. AND &y. <= 1999 %THEN %LET KeepVars = _year recnum lineno hhid rrp mis wgtfnl famwgt hhwgt vetwgt wgtbls famnum hhnum state age sex race spneth grdatt grdatn chgrd schatt hsged dipged col colftpt famrel 
    famtyp faminc parent hhtype ;
    %IF 2000 <= &y. AND &y. <= 2000 %THEN %LET KeepVars = _year recnum lineno hhid rrp mis hhwgt famnum hhnum state age sex race spneth grdatt grdatn chgrd schatt hsged dipged col colftpt parent hhtype ;
    %IF 2001 <= &y. AND &y. <= 2003 %THEN %LET KeepVars = _year recnum lineno hhid rrp mis wgtfnl famwgt hhwgt vetwgt wgtbls famnum hhnum state age sex race spneth grdatt grdatn chgrd schatt hsged dipged col colftpt famrel famtyp 
    faminc parent hhtype ;
    %IF 2005 <= &y. AND &y. <= 2006 %THEN %LET KeepVars = _year recnum lineno hhid rrp mis wgtfnl famwgt hhwgt vetwgt wgtbls famnum hhnum state age sex race spneth hisp grdatt grdatn chgrd schatt  hsged dipged col colftpt famrel famtyp 
    faminc parent hhtype  ;
    %IF 2004 <= &y. AND &y. <= 2004 %THEN %LET KeepVars = _year recnum lineno hhid rrp mis wgtfnl famwgt hhwgt vetwgt wgtbls famnum hhnum state age sex race spneth hisp grdatt grdatn chgrd hsged dipged col colftpt famrel famtyp faminc parent hhtype;
    %IF 2007 <= &y. AND &y. <= 2011 %THEN %LET KeepVars = _year recnum lineno hhid rrp mis wgtfnl famwgt hhwgt vetwgt wgtbls famnum hhnum state age sex race spneth hisp grdatt grdatn chgrd schatt hsged dipged col colftpt famrel famtyp faminc parent 
    hhtype momtyp dadtyp lnmom lndad;


	/***START DATA STEP***/
	data cps_allvars_&y. &RenameStatement.; 
		&LengthStatement.;
		SET here.cps_allvars_&y.(KEEP=&KeepVars.);
		
		/***INITIALIZE FIELD VALUES FOR FIELDS NOT INCLUDED WITH THIS YEAR'S DATA***/
		/**PER UNICON DOCUMENTATION, THE WGT FIELD CONTAINS ALL MISSING VALUES FOR THE YEARS 1968-1969, AND FOR 1973-1978.
		   IN ADDITION, THE WGT FIELD IS NOT PRESENT IN THE DATA FOR THE YEARS 1994-2005.  CONSEQUENTLY, THE WGT FIELD IS
		   INITIALIZED TOA MISSING VALUE FOR THESE RANGES OF YEARS **/
			%IF (1968 <= &y. AND &y. <= 1969) OR (1973 <= &y. AND &y. <= 1978) OR (1994 <= &y. AND &y. <= 2005) %THEN %DO; wgt = .; %END;
			%IF 1968 <= &y. AND &y. <= 1983 %THEN %DO; famnum=.; hhtype=.; parent=.; famrel=.; famtyp=.; famwgt=.; chgrd=.; %END;
			%IF 1968 <= &y. AND &y. <= 1987 %THEN %DO; hsged = .; %END;
			%IF 1968 <= &y. AND &y. <= 1969 %THEN %DO; col = .; %END;
			%IF 1968 <= &y. AND &y. <= 1991 %THEN %DO; grdatn = .; %END;
			%IF 1968 <= &y. AND &y. <= 1997 %THEN %DO; dipged = .; %END;
			%IF 1968 <= &y. AND &y. <= 1988 %THEN %DO; hhwgt = .; %END;
			%IF 1968 <= &y. AND &y. <= 2003 %THEN %DO; lnmom = .; lndad = .; %END;
			%IF 1989 <= &y. AND &y. <= 2011 %THEN %DO; hhrel = .; %END;
			%IF 1992 <= &y. AND &y. <= 2011 %THEN %DO; _educ = .; %END;
			%IF 1968 <= &y. AND &y. <= 1997 %THEN %DO; wgtbls=.;  %END;
			%IF 1968 <= &y. AND &y. <= 1993 %THEN %DO; wgtl=.;  %END;		
		  %IF 1968 <= &y. AND &y. <= 1984 %THEN %DO; vetwgt=.;  %END;				


		/***DATA PREPARATION STEPS THAT APPLY TO ALL SURVEY YEARS***/
		%IF 1968 <= &y. AND &y. <= 2011 %THEN %DO;
			if famnum=-1 or age=-1 then delete;
			if mis in(. 5 6 7 8) then delete; ***EXCLUDE 2ND ROTATION DATA TO ELIMINATE THE EFFECT OF SAME PERSON SAMPLED TWICE***;
			if age^ in(-1,.) and 0<=age<15 then popstatnew=1; else if age>=15 then popstatnew=2; ***NEW 2-CATEGORY POPSTAT FIELD FOR ALL YEARS (NO ARMED FORCES ASPECT)***;
			if grdatn=. then grdatn=00; ***SET MISSING GRADE ATTAINED TO 
		%END;

		/***PREPARE VARIABLES THAT APPEAR IN SUBSETS OF SURVEY YEARS***/
			%IF 1968 <= &y. AND &y. <= 2003 %THEN %DO;

			%END;
			%IF 1988 <= &y. AND &y. <= 1993 %THEN %DO; if hsged = 8 then hsged = -9; %END;
			%IF 1968 <= &y. AND &y. <= 1993 %THEN %DO; if grdatt in(. 99) then grdatt = -1; %END;
			
	  	%IF 1968 <= &y. AND &y. <= 1980 %THEN if col in(. 9) then %DO; col = -1; else col = col + 1; %END;
			%IF 1981 <= &y. AND &y. <= 2011 %THEN %DO;     if col in(. 9) then col = -1; %END;

		/***COLLAPSING RACE VALUES TO FEWER CATEGORIES******/
		  %IF       1968 <= &y. AND &y. <= 1995 %THEN %DO; if race in(3 4 5) then race3 = 3; else race3 = race; %END; 
			%ELSE %IF 1996 <= &y. AND &y. <= 2002 %THEN %DO; if race in(3 4  ) then race3 = 3; else race3 = race; %END;
			%ELSE %IF 2003 <= &y. AND &y. <= 2011 %THEN %DO; if race >= 3      then race3 = 3; else race3 = race; %END;

		/***ADJUST FAMILY INCOME CATEGORIES***/
			%IF       1968 <= &y. AND &y. <= 1973 %THEN %DO; if faminc="A" then faminctmp=10; else faminctmp=input(faminc,3.); %END;
			%ELSE %IF 1974 <= &y. AND &y. <= 1988 %THEN %DO;
				if      faminc = "A" then faminctmp = 10;
				else if faminc = "B" then faminctmp = 11;
				else if faminc = "C" then faminctmp = 12;
				else if faminc = "D" then faminctmp = 13;
				else faminctmp = input(faminc,3.); %END;
				
			/* NSM: Can this be more simply applied to all years, since faminc is (presumably) initialized for all years? */
			%IF 1968 <= &y. AND &y. <= 1988 %THEN %DO; drop faminc; %END; 

		/***ADJUST SPANISH ETHNICITY DESIGNATIONS***/
		 %IF 1968 <= &y. AND &y. <= 1972 %THEN %DO;
				spneth=.; %END;
			%ELSE %IF 1973 <= &y. AND &y. <= 1988 %THEN %DO;
				if      spneth in("1" "2" "3") then spneth = "1";
				else if spneth="4"             then spneth = "2";
				else if spneth="5"             then spneth = "3";
				else if spneth="6"             then spneth = "4";
				else if spneth="7"             then spneth = "5";
				else if spneth in("." "8" "9" "A") then spneth = "9";
				spntmp = input(spneth, 3.);
				if spntmp in(. 9) then spntmp=-1;
				drop spneth; %END;
			%ELSE %IF 1989 <= &y. AND &y. <= 2002 %THEN %DO;
				if      spneth in(1 2 3)  then spneth = 1;
				else if spneth = 4        then spneth = 2;
				else if spneth = 5        then spneth = 3; 
				else if spneth = 6        then spneth = 4;
				else if spneth = 7        then spneth = 5;
				else if spneth in(8 9 10) then spneth =-1;    
			%END;

		/***DIVIDE WEIGHT FIELD IN ORDER TO PRODUCE PROPER DECIMAL POSITION***/
		  %IF 1968 <= &y. AND &y. <= 1993 %THEN %LET WgtDenom = 100;
			%IF 1994 <= &y. AND &y. <= 2011 %THEN %LET WgtDenom = 10000;
			
				array WgtStd{6} wgtfnl famwgt vetwgt hhwgt wgtbls wgtl;
			do i = 1 to 6;
				WgtStd(i) = WgtStd(i)/&WgtDenom.;
			end;		

		/***RESTRICT OUTPUT DATA***/
			%DO; if hhid = ""   or lineno = . then delete; %END;
	
	%END;
%MEND; 

run;

/**CALL MACRO TO PROCESS CUSTOMIZED UPDATES PER YEAR OF SURVEY**/
%ReadSurveyYearData;

***SET THE 1968-2003 DATA TOGETHER WITH THE 2004-2011 DATA***;
data cps_allvars_1968_2011(rename=(fminc=faminc));
	length agecat 3 hhid $15;
	set cps_allvars_1968 cps_allvars_1969
	    cps_allvars_1970 cps_allvars_1971 cps_allvars_1972 cps_allvars_1973 cps_allvars_1974
	    cps_allvars_1975 cps_allvars_1976 cps_allvars_1977 cps_allvars_1978 cps_allvars_1979
	    cps_allvars_1980 cps_allvars_1981 cps_allvars_1982 cps_allvars_1983 cps_allvars_1984
	    cps_allvars_1985 cps_allvars_1986 cps_allvars_1987 cps_allvars_1988 cps_allvars_1989
	    cps_allvars_1990 cps_allvars_1991 cps_allvars_1992 cps_allvars_1993 cps_allvars_1994 
	    cps_allvars_1995 cps_allvars_1996 cps_allvars_1997 cps_allvars_1998 cps_allvars_1999
	    cps_allvars_2000 cps_allvars_2001 cps_allvars_2002 cps_allvars_2003 cps_allvars_2004 
	    cps_allvars_2005 cps_allvars_2006 cps_allvars_2007 cps_allvars_2008 cps_allvars_2009
	    cps_allvars_2010 cps_allvars_2011;
	                               				   
	  if age^ in(-1,.) and 0<=age<=10 then agecat = 1;
		else if 10 < age <= 20 then agecat = 2;
		else if 20 < age <= 40 then agecat = 3;
		else if 40 < age <= 60 then agecat = 4;
		else if 60 < age <= 80 then agecat = 5;
		else if 80 < age       then agecat = 6;
		  
		if 1968<=_year<=1973 then do;
			if      faminc =  0 then fminc =   500;
			else if faminc =  1 then fminc =  1500;
			else if faminc =  2 then fminc =  2500;
			else if faminc =  3 then fminc =  3500;
			else if faminc =  4 then fminc =  4500;
			else if faminc =  5 then fminc =  5500;
			else if faminc =  6 then fminc =  6750;
			else if faminc =  7 then fminc =  8750;
			else if faminc =  8 then fminc = 12500;
			else if faminc =  9 then fminc = 20000;
			else if faminc = 10 then fminc = .;
		end;
		else if 1974<=_year<=1981 then do;
			if      faminc =  0 then fminc =   500;
			else if faminc =  1 then fminc =  1500;
			else if faminc =  2 then fminc =  2500;
			else if faminc =  3 then fminc =  3500;
			else if faminc =  4 then fminc =  4500;
			else if faminc =  5 then fminc =  5500;
			else if faminc =  6 then fminc =  6750;
			else if faminc =  7 then fminc =  8750;
			else if faminc =  8 then fminc = 11000;
			else if faminc =  9 then fminc = 13500;
			else if faminc = 10 then fminc = 17500;
			else if faminc = 11 then fminc = 22500;
			else if faminc = 12 then fminc = 37500;
			else if faminc in (13 .) then fminc=.;
		end;
		else if 1982<=_year<=1988 then do;
			if      faminc =  0 then fminc =  2500;
			else if faminc =  1 then fminc =  6250;
			else if faminc =  2 then fminc =  8750;
			else if faminc =  3 then fminc = 11250;
			else if faminc =  4 then fminc = 13750;
			else if faminc =  5 then fminc = 16250;
			else if faminc =  6 then fminc = 18750;
			else if faminc =  7 then fminc = 22500;
			else if faminc =  8 then fminc = 27500;
			else if faminc =  9 then fminc = 32500;
			else if faminc = 10 then fminc = 37500;
			else if faminc = 11 then fminc = 45000;
			else if faminc = 12 then fminc = 62500;
			else if faminc in (13 .) then fminc=.;
		end;
		else if 1989<=_year<=1993 then do;
			if      faminc =  0 then fminc =  2500;
			else if faminc =  1 then fminc =  6250;
			else if faminc =  2 then fminc =  8750;
			else if faminc =  3 then fminc = 11250;
			else if faminc =  4 then fminc = 13750;
			else if faminc =  5 then fminc = 17500;
			else if faminc =  6 then fminc = 22500;
			else if faminc =  7 then fminc = 27500;
			else if faminc =  8 then fminc = 32500;
			else if faminc =  9 then fminc = 37500;
			else if faminc = 10 then fminc = 45000;
			else if faminc = 11 then fminc = 55000;
			else if faminc = 12 then fminc = 67500;
			else if faminc in(13 19) then fminc=.;
		end;
		else if 1994<=_year<=2002 then do;
			if      faminc =  1 then fminc =  2500;
			else if faminc =  2 then fminc =  6250;
			else if faminc =  3 then fminc =  8750;
			else if faminc =  4 then fminc = 11250;
			else if faminc =  5 then fminc = 13750;
			else if faminc =  6 then fminc = 17500;
			else if faminc =  7 then fminc = 22500;
			else if faminc =  8 then fminc = 27500;
			else if faminc =  9 then fminc = 32500;
			else if faminc = 10 then fminc = 37500;
			else if faminc = 11 then fminc = 45000;
			else if faminc = 12 then fminc = 55000;
			else if faminc = 13 then fminc = 67500;
			else if faminc = 14 then fminc = .;
		end;
		else if 2003<=_year<=2011 then do;
			if      faminc =  1 then fminc =  2500;
			else if faminc =  2 then fminc =  6250;
			else if faminc =  3 then fminc =  8750;
			else if faminc =  4 then fminc = 11250;
			else if faminc =  5 then fminc = 13750;
			else if faminc =  6 then fminc = 17500;
			else if faminc =  7 then fminc = 22500;
			else if faminc =  8 then fminc = 27500;
			else if faminc =  9 then fminc = 32500;
			else if faminc = 10 then fminc = 37500;
			else if faminc = 11 then fminc = 45000;
			else if faminc = 12 then fminc = 55000;
			else if faminc = 13 then fminc = 67500;
			else if faminc = 14 then fminc = 87500;
			else if faminc = 15 then fminc = 125000;
			else if faminc = 16 then fminc = .;
		end;
		drop faminc famwgt vetwgt hhwgt wgtbls wgtl;		  

		format agecat agecatf. famtyp famtypf. famrel famrelf. hhrel hhrelf. schatt schattf.;
run;

proc contents data=cps_allvars_1968_2011; run;

***APPLY CPI DEFLATOR TO FAMILY INCOME TO STANDARDIZE INCOME OVER TIME***;
proc sql;
	create table cps_allvars_1968_2011 as
	select a.*, a.faminc*b.v2010deflator as FamilyInc_Defl format=8.0
	from cps_allvars_1968_2011 as a left join here.cpi_1913_2013_deflator as b
	on a._year=b.year;
	
proc freq data=cps_allvars_1968_2011; where _year=2011; tables FamilyInc_Defl / list missprint; run; 

proc sql;
	create table cps_allvars_1968_2011_faminc as
	select hhid, max(FamilyInc_Defl) as FamilyInc_Defl_Max format=8.0, mean(FamilyInc_Defl) as FamilyInc_Defl_Avg format=8.0
	from cps_allvars_1968_2011
	group by hhid;
	
proc freq data=cps_allvars_1968_2011_faminc; tables FamilyInc_Defl_Max / list missprint; run; 
	
***RE-JOIN MAXIMUM FAMINC VALUE BACK TO ALL RECORDS FOR A PARTICULAR HOUSEHOLD***;
proc sql;
	create table cps_allvars_1968_2011 as
	select a.*, b.FamilyInc_Defl_Max, b.FamilyInc_Defl_Avg
	from cps_allvars_1968_2011 as a left join cps_allvars_1968_2011_faminc as b
	on a.hhid=b.hhid;

data cps_allvars_1968_2011; 
	length hhidtmp $21;
	set cps_allvars_1968_2011;
	yearchar=put(_year,4.);
	statechar=put(state,3.);
  /**NOTE:  ADDING YEAR AND STATE TO CREATE EXPANDED HHID BECAUSE FOR 1994 1995 THE HHID NUMBERS ARE DUPLICATED**/
  hhidtmp=cats(hhid,yearchar);
  hhidtmp=cats(hhidtmp,statechar);
  drop hhid;  	
run;

proc sort data=cps_allvars_1968_2011; by _year state hhidtmp lineno; run;
data cps_allvars_1968_2011(rename=(hhidtmp=hhid));
	set cps_allvars_1968_2011;
  by _year state hhidtmp lineno;
  if first.lineno;
 run;
 
proc freq data=cps_allvars_1968_2011; 
	where _year=2011; 
	tables _year*FamilyInc_Defl_Max _year*FamilyInc_Defl_Avg / list missing; title5 "LOOK AT VARIOUS FREQ DISTIBUTIONS"; run; title5; run; 

proc freq data=cps_allvars_1968_2011; tables _year / list missing; run;

proc sort data=cps_allvars_1968_2011; by hhid lineno; run;
	
data cps_allvars_1968_2011;
	set cps_allvars_1968_2011;
	by hhid lineno;
	if substr(hhid,12,1)=" " then hhid=cats(hhid,0);
	if hsged in(. 9) then hsged=-1;
	***CREATE VAR TO IDENTIFY WHICH PRE-1968 COHORT TO ASSIGN RECORDS***;
	cohort_yr=_year-age;
	drop bothpar;
run;

proc print data=cps_allvars_1968_2011 n; 	where hhid="9240521195081980"; 
	var hhid lineno age _year;
	title5 "LOOK AT 1980 BASE DATA BEFORE COHORT BUILD"; 
run; title5; run;  

***CALL THE PROGRAM TO BUILD THE DISCRETE INDICATOR VARS***;
%include discvars;

run;

endsas;


