
******************************************************************************;
*** PROGRAM:  P2_BUILD_DISCRETE_INDICATORS_V7_FINAL_EDUCATION_UPDATES.SAS  ***;                       
***                                                                        ***;
*** LOCATION: GOODLAND Server:                                             ***;
***           /projects/Lumina_SocIndOfPostSec/Code/generation_6_progs     ***;
*** PROGRAMMERS:    Jeff Harrington and Nick Mader                         ***;
*** DESCRIPTION:   This program creates the discrete (binary) indicator    ***;
***                fields from data in the datasets created during the     ***;
***                initial data build, but prior to cohort creation.       ***;
***                                                                        ***;
***                                                                        ***;
*** CREATED:     10/19/13                                                  ***;
*** UPDATES:	   02/26/14 by Jeff harrington                               ***;
***                  Removed extraneous code,a nd streamlined program flow ***;
***                  per comments by Nick Mader.                           ***;
***				           work towards generating cohort averages               ***;
***         	   10/19/13 by Nick Mader                                    ***;
***                  Creating a new centralized version of all files to    ***;
***				           work towards generating cohort averages               ***;
***              08/01/13 by Jeff Harrington                               ***;
***                  Initial program creation.                             ***;
***                  Incorporate new cohort building method.               ***;   
***                                                                        ***;        
******************************************************************************;
options mprint mlogic symbolgen linesize=132;
libname oraora oracle user=&orauser orapw=&orapass path=&oradb;
libname here '/projects/Lumina_SocIndOfPostSec/Data';
filename chrtbld '/projects/Lumina_SocIndOfPostSec/Code/generation_6_progs/p3_build_cohorts_v5_streamline_cohort_build.sas';
filename varlab '/projects/Lumina_SocIndOfPostSec/Code/var_labels.sas';
filename varform '/projects/Lumina_SocIndOfPostSec/Code/var_formats.sas';
%LET OutPath = /projects/Lumina_SocIndOfPostSec/Data/;
	
**************************;
***USER DEFINED FORMATS***;
**************************;
%include varform;
run;
	
data cps_allvars_disc_1968_2011;
		length bothpar 8;
	set here.cps_allvars_1968_2011;

  ******************************************;
  ***CREATE BINARY DEMOGRAPHIC INDICATORS***;
  ******************************************;	
	   ***CREATE BINARY RACE VARS***;
	   if race3 in(-3,-2,-1,.) then Race_WhiteNonH=.;
	     else if race3=1 and spneth ^in(1,2,3,4,5) then Race_WhiteNonH=1;
	       else Race_WhiteNonH=0;
	   if race3 in(-3,-2,-1,.) then Race_BlackNonH=.;
	     else if race3=2 and spneth ^in(1,2,3,4,5) then Race_BlackNonH=1;
	       else Race_BlackNonH=0;
	   if spneth in(1 2 3 4 5) then Race_Hisp=1;
	     else Race_Hisp=0;
	     
     ***CREATE BINARY GENDER VARS***;
    if sex in(-1 .) then do; Gender_Male=.; Gender_Female=.; end;
      else if sex=1 then do; Gender_Male=1; Gender_Female=0; end;
        else do; Gender_Male=0; Gender_Female=1; end;

  *****************************************************;
  ***CREATE BINARY EDUCATIONAL ATTAINMENT INDICATORS***;
  *****************************************************;        
  
	***CREATE BINARY PRE-K VAR***;
		if 1968<=_year<1984 then do;
			if      3 <= age <= 5  and grdatt in(1 2)    then AttendedPreK = 1;
			else if 3 <= age <= 5  and grdatt ^ in(. 20) then AttendedPreK = 0;
			else if age<3 or age>5 or  grdatt in(. 20)   then AttendedPreK = .;
		end;
		else if 1984<=_year<=1986 then do;
			if      3 <= age <= 5  and chgrd in(1 2)    then AttendedPreK = 1;
			else if 3 <= age <= 5  and chgrd ^ in(. 20) then AttendedPreK = 0;
			else if age<3 or age>5 or  chgrd in(. 20)   then AttendedPreK = .;
			end;
		else if 1987<=_year<=1993 then do;
			if      3 <= age <= 5  and chgrd in(1 2)       then AttendedPreK = 1;
			else if 3 <= age <= 5  and chgrd ^ in(. -1 99) then AttendedPreK = 0;
			else if age<3 or age>5 or  chgrd in(. -1 99)   then AttendedPreK = .;
		end;
		else if 1994<=_year<=2011 then do;
			if      3 <= age <= 5  and chgrd in(1 2)    then AttendedPreK = 1;
			else if 3 <= age <= 5  and chgrd ^ in(. -1) then AttendedPreK = 0;
			else if age<3 or age>5 or  chgrd in(. -1)   then AttendedPreK = .;
		end;    	                       

    ***CREATE LESS THAN HIGH SCHOOL VAR (THIS REFERS TO PEOPLE WHO DID NOT COMPLETE HIGH SCHOOL)***;   
		if 1968 <= _year < 1992 then do;
			if      _educ ^ in(. 0) and _educ < 12 and 21 <= age <= 65 then Ed_LtHs = 1;
			else if _educ >= 12                    and 21 <= age <= 65 then Ed_LtHs = 0;
			else Ed_LtHs = .;
		end;
		if 1992 <= _year <= 2011 then do;
			if 31 <= grdatn <= 34 and 21 <= age <= 65 then Ed_LtHs = 1;
			else if grdatn > 34   and 21 <= age <= 65 then Ed_LtHs = 0;
			else Ed_LtHs = .;
		end;
	  	                        
	***CREATE HIGH SCHOOL COMPLETED VIA DIPLOMA VAR***; 	                        
	  if _year >= 1998 then do; 	                        
			if      dipged = 1 and 21 <= age <= 65 then Ed_Grad_Hs_Dip = 1;
	  	    else if dipged = 2 and 21 <= age <= 65 then Ed_Grad_Hs_Dip = 0;
	  	    else Ed_Grad_Hs_Dip = .;
	  end;

	***CREATE HIGH SCHOOL COMPLETED VIA GED/EQUIVALENT VAR***;	  	 
	  if _year >= 1998 then do; 	 	  	                                               
	        if      dipged = 2 and 21 <= age <= 65 then Ed_Grad_Hs_Ged = 1;
	  	    else if dipged = 1 and 21 <= age <= 65 then Ed_Grad_Hs_Ged = 0;
	  	    else Ed_Grad_Hs_Ged = .; 	  	  	                        
	  end;
	
	***CREATE AN INDICATOR OF EITHER HS OR GED CREDENTIAL***;
	  /* Note: */
	  /* Our decision process is to look at only individuals 21 or older (to ensure enough time to complete a HS degree or equivalency), and to presume
	  	that anyone who reports strictly more than a HS degree has obtained a high school degree along the way. Note that this definition of "Hs" includes,
	    and does not distinguish between, both traditional HS diploma and GED. */
	  if      1968 <= _year < 1992 or age < 21 then Ed_Grad_Hs = .;
	  else if 1992 <= _year and 39 <= grdatn    and 21 <= age <= 65 then Ed_Grad_Hs = 1;
	  else if 1992 <= _year and . < grdatn < 39 and 21 <= age <= 65 then Ed_Grad_Hs = 0; *  and dipged ^ in(1 2);
	  	/* Note: the universe responding to dipged is anyone with grdatn = 39, i.e. having either an HS diploma or GED.
	  		There will be individuals who have a HS/GED AND more education who are not in this universe. We should not count these individuals
	  		as not having a HS diploma. */
	  else if 1992 <= _year then Ed_Grad_Hs = .;
	  
 
	***COMPLETED TWELVE YEARS OF SCHOOLING***;
		if 1968 <= _year < 1992 then do;
			if      _educ ^ in(.,0) and _educ >= 12 and 21 <= age <= 65 then Ed_Compl_12Yrs = 1; 
            else if _educ ^ in(.,0) and _educ <  12 and 21 <= age <= 65 then Ed_Compl_12Yrs = 0;
            else Ed_Compl_12Yrs = .;
		end;

    ***CONSTRUCT HYBRID MEASURE OF HS COMPLETION***;
		/* This mixes use of various HS completion measures, to obtain a single series across time. It combines Ed_Compl_12Yrs, which is the closest measurement
		   to high school completion between 1968 and 1992, and Ed_Grad_Hs which is direct confirmation of a high school credential (either diploma or GED) from 1993 to present. */
		Ed_Combined_Hs = .;
		if      1968 <= _year < 1992  then Ed_Combined_Hs = Ed_Compl_12Yrs;
		else if 1992 <= _year <= 2011 then Ed_Combined_Hs = Ed_Grad_Hs;
      
	***COMPLETED SOME COLLEGE BUT NO DEGREE***; ***DOES NOT SEEM APPROPRIATE TO CREATE THIS VAR FOR 1968-1991 DATA***; 
		if      1992 <= _year <= 2011 and grdatn ^ in(. -1 0) and grdatn >= 40 and 25 <= age <= 65 then Ed_SomeColl = 1;
		else if 1992 <= _year <= 2011 and grdatn ^ in(. -1 0) and grdatn <  40 and 25 <= age <= 65 then Ed_SomeColl = 0;
		else Ed_SomeColl = .;
      
	***COMPLETED ASSOCIATE DEGREE (2-YEAR DEGREE)***;
		if 1968<=_year<1992 then do;
			if      _educ ^ in(.,0) and _educ >= 14 and 25 <= age <= 65 then  Ed_Compl_14Yrs = 1;
			else if _educ ^ in(.,0) and _educ <  14 and 25 <= age <= 65 then  Ed_Compl_14Yrs = 0;
			else Ed_Compl_14Yrs = .;
		end;
		else if 1992 <= _year <= 2011 then do;
			if      grdatn ^ in(. -1 0) and grdatn >= 41 and 25 <= age <= 65 then Ed_Ge2YrColl = 1;    
			else if grdatn ^ in(. -1 0) and grdatn <  41 and 25 <= age <= 65 then Ed_Ge2YrColl = 0; 
			else Ed_Ge2YrColl = .;
		end;
      
	***COMPLETED BACHELORS DEGREE (4-YEAR DEGREE)***;
		if 1968 <= _year < 1992 then do;
			if      _educ ^ in(.,0) and _educ >= 16 and 25 <= age <= 65 then Ed_Compl_16Yrs = 1;
			else if _educ ^ in(.,0) and _educ <  16 and 25 <= age <= 65 then Ed_Compl_16Yrs = 0;
			else Ed_4YrColl = .;
		end;
		else if 1992 <= _year <= 2011 then do;
			if      grdatn ^ in(. -1 0) and grdatn >= 43 and 25 <= age <= 65 then Ed_Ge4YrColl = 1;
			else if grdatn ^ in(. -1 0) and grdatn <  43 and 25 <= age <= 65 then Ed_Ge4YrColl = 0;
			else Ed_4YrColl = .;
		end;
      
	***COMPLETED ASSOCIATES OR BACHELORS DEGREE***;     	
		if      Ed_Ge2YrColl = 1 or  Ed_Ge4YrColl = 1 then Ed_GeColl = 1;  
		else if Ed_Ge2YrColl = 0 and Ed_Ge4YrColl = 0 then Ed_GeColl = 0; 
		else Ed_GeColl = .; 
		
		Ed_Combined_GeColl = .;
		if      1968 <= _year < 1992  then Ed_Combined_GeColl = Ed_Compl_14Yrs;
		else if 1992 <= _year <= 2011 then Ed_Combined_GeColl = Ed_GeColl;

	***COMPLETED MASTERS DEGREE OR HIGHER)***;
		if 1968<=_year<1992 then do;
			if      _educ ^ in(.,0) and _educ >= 18 and 30 <= age <= 65 then Ed_GtColl = 1;
			else if _educ ^ in(.,0) and _educ <  18 and 30 <= age <= 65 then Ed_GtColl = 0;
			else Ed_GtColl = .;
		end;
		else if 1992<=_year<=2011 then do;
			if      grdatn ^ in(. -1 0) and grdatn >= 44 and 30 <= age <= 65 then Ed_GtColl = 1;
			else if grdatn ^ in(. -1 0) and grdatn <  44 and 30 <= age <= 65 then Ed_GtColl = 0;
			else Ed_GtColl = .;
		end;
 
   ****************************************************;
   ***CREATE BINARY HOUSEHOLD COMPOSITION INDICATORS***;
   ****************************************************;     
      ***BOTH PARENTS PRESENT IN HOUSEHOLD***;
	if      age<=16 and age ^=. and lnmom ^ in(. -1) and lndad ^ in(. -1) then bothpar = 1;
	else if age<=16 and age ^=. and (lnmom=-1 or lndad=-1)                then bothpar = 0; 
	else bothpar = .;	
	label bothpar = "Both Parents Present?";
run;  

/*---------------------------------------------------------*/
/***IDENTIFY THE EDUCATIONAL ATTAINMENT FOR ADULT FEMALES***/
/*---------------------------------------------------------*/
data cps_1968_2011_adltfemedu(rename=(Ed_LtHs            = FemEd_LtHs
									  Ed_Compl_12Yrs     = FemEd_Compl_12Yrs
									  Ed_Grad_Hs         = FemEd_Grad_Hs
									  Ed_Combined_Hs     = FemEd_Combined_Hs
									  Ed_Grad_Hs_Dip     = FemEd_Grad_Hs_Dip
									  Ed_Grad_Hs_Ged     = FemEd_Grad_Hs_Ged
									  Ed_SomeColl        = FemEd_SomeColl
									  Ed_Compl_14Yrs     = FemEd_Compl_14Yrs
									  Ed_Ge2YrColl       = FemEd_Ge2YrColl
									  Ed_Compl_16Yrs     = FemEd_Compl_16Yrs
									  Ed_Ge4YrColl       = FemEd_Ge4YrColl
									  Ed_GeColl          = FemEd_GeColl
									  Ed_Combined_GeColl = FemEd_Combined_GeColl
									  Ed_GtColl          = FemEd_GtColl));
	set cps_allvars_disc_1968_2011(where=(age>21 and sex^=1));
run;

/*---------------------------------------------------------------------------------*/
/***CALCULATE THE AVERAGE EDUC ATTAINMENT LEVELS FOR THE ADULT FEMALES IN EACH HH***/
/*---------------------------------------------------------------------------------*/
	proc sql;
		create table cps_1968_2011_adltfemeduc as
		select hhid, avg(FemEd_LtHs)            as FemEd_LtHs_avg,
					 avg(FemEd_Compl_12Yrs)     as FemEd_Compl_12Yrs_avg, 
					 avg(FemEd_Grad_Hs)         as FemEd_Grad_Hs_avg,
		             avg(FemEd_Combined_Hs)     as FemEd_Combined_Hs_avg,
					 avg(FemEd_Grad_Hs_Dip)     as FemEd_Grad_Hs_Dip_avg,
					 avg(FemEd_Grad_Hs_Ged)     as FemEd_Grad_Hs_Ged_avg,
					 avg(FemEd_SomeColl)        as FemEd_SomeColl_avg,
					 avg(FemEd_Compl_14Yrs)     as FemEd_Compl_14Yrs_avg, 
					 avg(FemEd_Ge2YrColl)       as FemEd_Ge2YrColl_avg,
					 avg(FemEd_Compl_16Yrs)     as FemEd_Compl_16Yrs_avg, 
					 avg(FemEd_Ge4YrColl)       as FemEd_Ge4YrColl_avg,
					 avg(FemEd_GeColl)          as FemEd_GeColl_avg,
					 avg(FemEd_Combined_GeColl) as FemEd_Combined_GeColl_avg,
					 avg(FemEd_GtColl)          as FemEd_GtColl_avg
		from cps_1968_2011_adltfemedu
		group by hhid
	;

	***JOIN THE EDUC ATTAINMENT OF ADULT FEMALES BACK TO THE BASE DATA***;
	proc sql;
		create table cps_1968_2011_adltfemedu as
		select a.*, b.*
		from cps_allvars_disc_1968_2011 as a left join cps_1968_2011_adltfemeduc as b
		on a.hhid=b.hhid
	;	

/*----------------------------------------------*/
/***CONSTRUCT MEASURES OF HOUSHOLD COMPOSITION***/
/*----------------------------------------------*/
	
	***CALCULATE THE NUMBER OF PERSONS WITHIN EACH HOUSEHOLD (USED IN DETERMINING POVERTY GUIDELNES)***;	
	proc sql;
		create table cps_1968_2011_hhnumpers as
		select hhid, count(*) as numpers
		from cps_1968_2011_adltfemedu
		where age ^=.
		group by hhid
	;

	***JOIN THE NUMBER OF PERSONS VALUE BACK TO THE BASE DATA***;
	proc sql;
		create table cps_1968_2011_adltfemedu as
		select a.*, b.numpers
		from cps_1968_2011_adltfemedu as a left join cps_1968_2011_hhnumpers as b
		on a.hhid=b.hhid
	;	

	***CALCULATE THE NUMBER OF ADULTS WITHIN EACH HOUSEHOLD***;	
	proc sql;
		create table cps_1968_2011_hhnumadults as
		select hhid, count(*) as numadults
		from cps_1968_2011_adltfemedu
		where age>=16
		group by hhid
	;

	***JOIN THE NUMBER OF ADULTS VALUE BACK TO THE BASE DATA***;
	proc sql;
		create table cps_1968_2011_withnumadlt as
		select a.*, b.numadults
		from cps_1968_2011_adltfemedu as a left join cps_1968_2011_hhnumadults as b
		on a.hhid=b.hhid
	;

************************************************************************************;	
***CREATE MACRO TO EVALUATE THE NUMBER OF KIDS OF VARIOUS AGES WITHIN A HOUSEHOLD***;
************************************************************************************;
%macro numkid(lowage=,hiage=,agerng=);
	%let count=1;
	%let m_lowage=%scan(&lowage,&count);
	%let m_hiage=%scan(&hiage,&count);
	%let m_agerng=%scan(&agerng,&count);
  %do %while(&m_lowage ne %str());
  	
proc sql;
	create table cps_1968_2011_hhnumkids&m_agerng as
	select hhid, count(lineno) as hhnumkids&m_agerng
	from (select distinct hhid, lineno
	from cps_1968_2011_withnumadlt
	where &m_lowage<=age<=&m_hiage)
	group by hhid
;

proc sql;
	create table cps_1968_2011_withnumadlt as
	select a.*, b.hhnumkids&m_agerng
	from cps_1968_2011_withnumadlt as a left join cps_1968_2011_hhnumkids&m_agerng as b
	on a.hhid=b.hhid
; 

data cps_1968_2011_withnumadlt;
	set cps_1968_2011_withnumadlt;

***ADJUST NUM OF KIDS IN HH BECAUSE WE DO NOT WANT TO COUNT FOCAL CHILD IN COUNT***;
  	                      if &m_lowage<=age<=&m_hiage then hhnumkids&m_agerng=hhnumkids&m_agerng-1;
  	                        else if 0<=age<=16 then hhnumkids&m_agerng=hhnumkids&m_agerng;
  	                           else if age>16 then hhnumkids&m_agerng=.;
run;


  %let count=%eval(&count+1);
  %let m_lowage=%scan(&lowage,&count);
	%let m_hiage=%scan(&hiage,&count);
	%let m_agerng=%scan(&agerng,&count);
  
  %end;
%mend;

%numkid(lowage=0 4 0 7 0,hiage=3 6 6 16 16,agerng=03 46 06 716 016);
run;

***SET MISSING NUMKIDS VALUES FOR CHILDREN TO ZERO***;
data cps_1968_2011_withnumadlt(rename=(hhnumkids03=NumKidsinHH_Age0to3 hhnumkids46=NumKidsinHH_Age4to6
	                                     hhnumkids06=NumKidsinHH_Age0to6 hhnumkids716=NumKidsinHH_Age7to16
	                                     hhnumkids016=NumKidsinHH_Age0to16));
	set cps_1968_2011_withnumadlt;
	if age<=16 then do;
		               array misszero {5} hhnumkids03 hhnumkids46 hhnumkids06 hhnumkids716 hhnumkids016;
                     do i=1 to 5;
                        if misszero{i}=. then misszero{i}=0;
                     end;
                  end;
/**FOR ALL RECORDS WHERE THE FOCAL PERSON IS AN ADULT (>16) WE SET ALL HOUSEHOLD INDICATORS TO MISSING
   SO THAT THE AGGREGATE RESULTS ARE ONLY REFERRING TO THE HOUSEHOLD CONDITIONS FOR KIDS**/                  
	if age>16 then do;
		               array missset {22} FemEd_LtHs_avg FemEd_Compl_12Yrs_avg FemEd_Compl_14Yrs_avg FemEd_Compl_16Yrs_avg FemEd_Grad_Hs_avg FemEd_Combined_Hs_avg
										FemEd_Grad_Hs_Dip_avg FemEd_SomeColl_avg FemEd_GeColl_avg FemEd_Combined_GeColl_avg FemEd_GtColl_avg numpers numadults 
										NumKidsinHH_Age0to3 NumKidsinHH_Age4to6 NumKidsinHH_Age0to6 NumKidsinHH_Age7to16 NumKidsinHH_Age0to16
										FamilyInc_Defl FamilyInc_Defl_Max FamilyInc_Defl_Avg PovLev_Defl;
                     do i=1 to 22;
                        missset{i}=.;
                     end;
                  end;
                                    
***DEFINE BINARY VERSIONS OF NUM KIDS CATEGORIES***;
  if hhnumkids03>0 then KidsinHH_Age0to3=1;  else if hhnumkids03^=. then KidsinHH_Age0to3=0; else KidsinHH_Age0to3=.;
  if hhnumkids46>0 then KidsinHH_Age4to6=1;  else if hhnumkids46^=. then KidsinHH_Age4to6=0; else KidsinHH_Age4to6=.;
  if hhnumkids06>0 then KidsinHH_Age0to6=1;  else if hhnumkids06^=. then KidsinHH_Age0to6=0; else KidsinHH_Age0to6=.;
  if hhnumkids716>0 then KidsinHH_Age7to16=1;  else if hhnumkids716^=. then KidsinHH_Age7to16=0; else KidsinHH_Age7to16=.;
  if hhnumkids016>0 then KidsinHH_Age0to16=1;  else if hhnumkids016^=. then KidsinHH_Age0to16=0; else KidsinHH_Age0to16=.;

***DEFINE BINARY VERSION OF RAISED BY 2 ADULTS INDICATOR***;  
  if age <=16 and age^=. and numadults>=2 then RaisedWith2Adults=1;  
     else if age <=16 and age^=. and numadults^=. then RaisedWith2Adults=0; 
        else RaisedWith2Adults=.;
  
***CREATE COLLAPSED AGE CATEGORIES***;
  if age^ in(-1,.) and 0<=age<=10 then agecat=1; else if 10<age<=20 then agecat=2; else if 20<age<=40 then agecat=3; else if 40<age<=60 then agecat=4;
  if 60<age<=80 then agecat=5; else if 80<age then agecat=6;
  
		  if age>16 then do; numadults=.; RaisedWith2Adults=.; KidsinHH_Age0to3=.; KidsinHH_Age4to6=.; KidsinHH_Age0to6=.; KidsinHH_Age7to16=.; KidsinHH_Age0to16=.;
		                 end;
		                                 
if age>18 then do; momtyp=.; dadtyp=.; end;
	if hsged ^ in(1 2) then hsged=-1;
	if numadults=. then numadults=0;
	if numpers=. then numpers=0;
	
***CREATE BINARY INDICATORS FOR FAMILY INCOME***;
***MAX FAMILY INCOME***;
  if 0<=FamilyInc_Defl_Max<=20000 then FamInc_Def_Max_0020k=1;  
     else if FamilyInc_Defl_Max^=. then FamInc_Def_Max_0020k=0; 
        else FamInc_Def_Max_0020k=.;
  if 20001<=FamilyInc_Defl_Max<=40000 then FamInc_Def_Max_2040k=1;  
     else if FamilyInc_Defl_Max^=. then FamInc_Def_Max_2040k=0; 
        else FamInc_Def_Max_2040k=.;
  if 40001<=FamilyInc_Defl_Max<=60000 then FamInc_Def_Max_4060k=1;  
     else if FamilyInc_Defl_Max^=. then FamInc_Def_Max_4060k=0; 
        else FamInc_Def_Max_4060k=.;
  if 60001<=FamilyInc_Defl_Max<=80000 then FamInc_Def_Max_6080k=1;  
     else if FamilyInc_Defl_Max^=. then FamInc_Def_Max_6080k=0; 
        else FamInc_Def_Max_6080k=.;
  if FamilyInc_Defl_Max>=80001 then FamInc_Def_Max_80kplus=1;  
     else if FamilyInc_Defl_Max^=. then FamInc_Def_Max_80kplus=0; 
        else FamInc_Def_Max_80kplus=.;
    
***AVG FAMILY INCOME***;
  if 0<=FamilyInc_Defl_Avg<=20000 then FamInc_Def_Avg_0020k=1;  
     else if FamilyInc_Defl_Avg^=. then FamInc_Def_Avg_0020k=0; 
        else FamInc_Def_Avg_0020k=.;
  if 20001<=FamilyInc_Defl_Avg<=40000 then FamInc_Def_Avg_2040k=1;  
     else if FamilyInc_Defl_Avg^=. then FamInc_Def_Avg_2040k=0; 
        else FamInc_Def_Avg_2040k=.;
  if 40001<=FamilyInc_Defl_Avg<=60000 then FamInc_Def_Avg_4060k=1;  
     else if FamilyInc_Defl_Avg^=. then FamInc_Def_Avg_4060k=0; 
        else FamInc_Def_Avg_4060k=.;
  if 60001<=FamilyInc_Defl_Avg<=80000 then FamInc_Def_Avg_6080k=1;  
     else if FamilyInc_Defl_Avg^=. then FamInc_Def_Avg_6080k=0; 
        else FamInc_Def_Avg_6080k=.;
  if FamilyInc_Defl_Avg>=80001 then FamInc_Def_Avg_80kplus=1;  
     else if FamilyInc_Defl_Avg^=. then FamInc_Def_Avg_80kplus=0; 
        else FamInc_Def_Avg_80kplus=.;
        
	format spneth spnethf. agecat agecatf.;
	%include varlab;
  
run;

proc print data=cps_1968_2011_withnumadlt(obs=100);
	var hhid lineno age NumKidsinHH:;
	title5 "LOOK AT RESULT OF STREAMLINED NUMKIDS BUILD";
run; title5; run;

proc print data=cps_1968_2011_withnumadlt(obs=100);
	var hhid lineno age FamInc_Def_:;
	title5 "LOOK AT RESULT OF STREAMLINED FAMILY INCOME BUILD";
run; title5; run;

proc sort data=cps_1968_2011_withnumadlt out=cps_1968_2011_allpers_numkids; by hhid lineno; run;
	
	
***TRANSPOSE POVERTY GUIDELINES IN PREP FOR INFLATION DEFLATION (FOR DEFINING BINARY POVERTY GUIDELINES INDICATORS)***;  
proc transpose data=here.pov_guides_65_12_for_transp out=poverty_guidelines_65_12 (drop=_label_) name=persnum prefix=povlev;
by issue_dt;
run;

data 	poverty_guidelines_65_12(rename=(persnumtmp=persnum));
	set poverty_guidelines_65_12;
  persnumtmp=input(substr(persnum,5,2),3.);
  drop persnum; 
run;

***APPLY CPI DEFLATOR TO POVERTY GUIDELINES TO STANDARDIZE INCOME OVER TIME***;
proc sql;
	create table cps_allvars_1968_2011_povlev as
	select a.*,a.povlev1*b.v2010deflator as PovLev_Defl format=8.0
	from poverty_guidelines_65_12 as a left join here.cpi_1913_2013_deflator as b
	on a.issue_dt=b.year;
	
***RE-JOIN POVERTY LEVELS (ADJUSTED FOR INFLATION) TO ALL RECORDS FOR A PARTICULAR SURVEY YEAR AND HH PERSONS COMBO***;
proc sql;
	create table cps_allvars_1968_2011 as
	select a.*, b.PovLev_Defl
	from cps_1968_2011_allpers_numkids(drop=PovLev_Defl) as a left join cps_allvars_1968_2011_povlev as b
	on a._year=b.issue_dt and a.numpers=b.persnum;
	
***DEFINE BINARY FAMILY INCOME RELATIVE TO POVERTY GUIDELINES INDICATORS***;
data cps_allvars_1968_2011;
	set cps_allvars_1968_2011;
	***MAX FAMILY INCOME BELOW 100 PERCENT OF THE FPL***;
	if FamilyInc_Defl_Max ^ =. and PovLev_Defl ^ =. and FamilyInc_Defl_Max<PovLev_Defl then FamilyIncMax_Below100FPL=1;
	   else if FamilyInc_Defl_Max ^ =. and PovLev_Defl ^ =. and FamilyInc_Defl_Max>=PovLev_Defl then FamilyIncMax_Below100FPL=0;
	      else FamilyIncMax_Below100FPL=.;
	***MEAN FAMILY INCOME BELOW 100 PERCENT OF THE FPL***;
	if FamilyInc_Defl_Avg ^ =. and PovLev_Defl ^ =. and FamilyInc_Defl_Avg<PovLev_Defl then FamilyIncAvg_Below100FPL=1;
	   else if FamilyInc_Defl_Avg ^ =. and PovLev_Defl ^ =. and FamilyInc_Defl_Avg>=PovLev_Defl then FamilyIncAvg_Below100FPL=0;
	      else FamilyIncAvg_Below100FPL=.;
	      
	***MAX FAMILY INCOME BELOW 50 PERCENT OF THE FPL***;
	if FamilyInc_Defl_Max ^ =. and PovLev_Defl ^ =. and FamilyInc_Defl_Max<(PovLev_Defl/2) then FamilyIncMax_Below50FPL=1;
	   else if FamilyInc_Defl_Max ^ =. and PovLev_Defl ^ =. and FamilyInc_Defl_Max>=(PovLev_Defl/2) then FamilyIncMax_Below50FPL=0;
	      else FamilyIncMax_Below50FPL=.;
	***MEAN FAMILY INCOME BELOW 50 PERCENT OF THE FPL***;
	if FamilyInc_Defl_Avg ^ =. and PovLev_Defl ^ =. and FamilyInc_Defl_Avg<(PovLev_Defl/2) then FamilyIncAvg_Below50FPL=1;
	   else if FamilyInc_Defl_Avg ^ =. and PovLev_Defl ^ =. and FamilyInc_Defl_Avg>=(PovLev_Defl/2) then FamilyIncAvg_Below50FPL=0;
	      else FamilyIncAvg_Below50FPL=.;	
	***MAX FAMILY INCOME BELOW 200 PERCENT OF THE FPL***;
	if FamilyInc_Defl_Max ^ =. and PovLev_Defl ^ =. and FamilyInc_Defl_Max<PovLev_Defl*2 then FamilyIncMax_Below200FPL=1;
	   else if FamilyInc_Defl_Max ^ =. and PovLev_Defl ^ =. and FamilyInc_Defl_Max>=PovLev_Defl*2 then FamilyIncMax_Below200FPL=0;
	      else FamilyIncMax_Below200FPL=.;
	***MEAN FAMILY INCOME BELOW 200 PERCENT OF THE FPL***;
	if FamilyInc_Defl_Avg ^ =. and PovLev_Defl ^ =. and FamilyInc_Defl_Avg<PovLev_Defl*2 then FamilyIncAvg_Below200FPL=1;
	   else if FamilyInc_Defl_Avg ^ =. and PovLev_Defl ^ =. and FamilyInc_Defl_Avg>=PovLev_Defl*2 then FamilyIncAvg_Below200FPL=0;
	      else FamilyIncAvg_Below200FPL=.;	
	      
	format spneth spnethf. agecat agecatf.;
	%include varlab;
  	      
run;   

/* Troubleshooting education construction */
%PUT First Check;
proc freq data = cps_allvars_1968_2011;
	tables _year * age * _educ * Ed_Grad_Hs / list ;
run;

proc freq data=cps_allvars_1968_2011;
tables _year age _year*dipged / list missing; run;

proc datasets lib=work nolist;
change cps_allvars_1968_2011 = cps_1968_2011_allpers_for_chrt;
quit;
run;

***CALL THE COHORT BUILDING PROGRAM***;
%include chrtbld;

endsas;


