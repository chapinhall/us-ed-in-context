
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
%LET OutPath = /projects/Lumina_SocIndOfPostSec/Data/;
	
data cps_allvars_disc_1968_2011;
		length bothpar 8;
	set cps_allvars_1968_2011;

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
			if      _educ ^ in(. 0) and _educ < 12 and age > 21 then Ed_LtHs = 1;
			else if _educ >= 12                    and age > 21 then Ed_LtHs = 0;
			else Ed_LtHs = .;
		end;
		if 1992<=_year<=2011 then do;
			if 31 <= grdatn <= 34 and age > 21 then Ed_LtHs = 1;
			else if grdatn > 34   and age > 21 then Ed_LtHs = 0;
			else Ed_LtHs = .;
		end;
	  	                        
	 	***CREATE HIGH SCHOOL COMPLETED VIA DIPLOMA VAR***; 	                        
	  if _year >= 1998 then do; 	                        
			if      dipged=1 and age > 21 then Ed_Grad_Hs_Dip = 1;
	  	    else if dipged=2 and age > 21 then Ed_Grad_Hs_Dip = 0;
	  	    else Ed_Grad_Hs_Dip = .;
	  	 end;

	  ***CREATE HIGH SCHOOL COMPLETED VIA GED/EQUIVALENT VAR***;	  	 
	  if _year >= 1998 then do; 	 	  	                                               
	        if      dipged = 2 and age > 21 then Ed_Grad_Hs_Ged = 1;
	  	    else if dipged = 1 and age > 21 then Ed_Grad_Hs_Ged = 0;
	  	    else Ed_Grad_Hs_Ged = .; 	  	  	                        
		end;
	
			***CREATE AN INDICATOR OF EITHER HS OR GED CREDENTIAL***;
			if      1968 <= _year < 1992 then Ed_Grad_Hs = .; 
			else if _year >= 1992 and grdatn>=39 and age>21 then Ed_Grad_Hs=1;
			 else if _year >= 1998 and dipged in(1 2) and age>21 then Ed_Grad_Hs=1;
			  else if _year >= 1992 and . < grdatn <39 and dipged ^ in(1 2) and age>21 then Ed_Grad_Hs=0;
	     	  else if _year>=1992 then Ed_Grad_Hs=.;
  
	***COMPLETED HIGH SCHOOL (UNRELATED TO THE METHOD OF HS COMPLETION)***;
		if 1968 <= _year < 1992 then do;
			if      _educ ^ in(.,0) and _educ >= 12 and age > 21 then completed_hs = 1; 
            else if _educ ^ in(.,0) and _educ <  12 and age > 21 then completed_hs = 0;
            else completed_hs = .;
		end;
		else if 1992 <= _year <= 2011 then do;
			if      grdatn ^ in(. -1 0) and grdatn >= 39 and age > 21 then completed_hs = 1;
			else if grdatn ^ in(. -1 0) and grdatn <  39 and age > 21 then completed_hs = 0;
			else completed_hs = .;
        end;
      
	***COMPLETED SOME COLLEGE BUT NO DEGREE***; ***DOES NOT SEEM APPROPRIATE TO CREATE THIS VAR FOR 1968-1991 DATA***; 
		if      1992 <= _year <= 2011 and grdatn ^ in(. -1 0) and grdatn >= 40 and age > 25 then Ed_SomeColl = 1;
		else if 1992 <= _year <= 2011 and grdatn ^ in(. -1 0) and grdatn <  40 and age > 25 then Ed_SomeColl = 0;
		else Ed_SomeColl = .;
      
	***COMPLETED ASSOCIATE DEGREE (2-YEAR DEGREE)***;
		if 1968<=_year<1992 then do;
			if      _educ ^ in(.,0) and _educ >= 14 and age > 25 then  Ed_2YrColl = 1;
			else if _educ ^ in(.,0) and _educ <  14 and age > 25 then  Ed_2YrColl = 0;
			else Ed_2YrColl = .;
		end;
		else if 1992 <= _year <= 2011 then do;
			if      grdatn ^ in(. -1 0) and grdatn >= 41 and age > 25 then Ed_2YrColl = 1;    
			else if grdatn ^ in(. -1 0) and grdatn <  41 and age > 25 then Ed_2YrColl = 0; 
			else Ed_2YrColl = .;
		end;  
      
	***COMPLETED BACHELORS DEGREE (4-YEAR DEGREE)***;
		if 1968 <= _year < 1992 then do;
			if      _educ ^ in(.,0) and _educ >= 16 and age > 25 then Ed_4YrColl = 1;
			else if _educ ^ in(.,0) and _educ <  16 and age > 25 then Ed_4YrColl = 0;
			else Ed_4YrColl = .;
		end;
		else if 1992 <= _year <= 2011 then do;
			if      grdatn ^ in(. -1 0) and grdatn >= 43 and age > 25 then Ed_4YrColl = 1;
			else if grdatn ^ in(. -1 0) and grdatn <  43 and age > 25 then Ed_4YrColl = 0;
			else Ed_4YrColl = .;
		end;
      
	***COMPLETED ASSOCIATES OR BACHELORS DEGREE***;     
		if      Ed_2YrColl = 1 or  Ed_4YrColl = 1 then Ed_Coll = 1;  
		else if Ed_2YrColl = 0 and Ed_4YrColl = 0 then Ed_Coll = 0; 
		else Ed_Coll = .;    

	***COMPLETED MASTERS DEGREE OR HIGHER)***;
		if 1968<=_year<1992 then do;
			if      _educ ^ in(.,0) and _educ >= 18 and age > 30 then Ed_GtColl = 1;
			else if _educ ^ in(.,0) and _educ <  18 and age > 30 then Ed_GtColl = 0;
			else Ed_GtColl = .;
		end;
		else if 1992<=_year<=2011 then do;
			if      grdatn ^ in(. -1 0) and grdatn >= 44 and age > 30 then Ed_GtColl = 1;
			else if grdatn ^ in(. -1 0) and grdatn <  44 and age > 30 then Ed_GtColl = 0;
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
data cps_1968_2011_adltfemedu(rename=(Ed_LtHs=FemEd_LtHs Ed_Grad_Hs=FemEd_Grad_Hs Ed_Grad_Hs_Dip=FemEd_Grad_Hs_Dip
	                                    Ed_Grad_Hs_Ged=FemEd_Grad_Hs_Ged completed_hs=Femcompleted_hs
	                                    Ed_SomeColl=FemEd_SomeColl Ed_2YrColl=FemEd_2YrColl Ed_4YrColl=FemEd_4YrColl
	                                    Ed_Coll=FemEd_Coll Ed_GtColl=FemEd_GtColl));
	set cps_allvars_disc_1968_2011(where=(age>21 and sex^=1));
run;

/*---------------------------------------------------------------------------------*/
/***CALCULATE THE AVERAGE EDUC ATTAINMENT LEVELS FOR THE ADULT FEMALES IN EACH HH***/
/*---------------------------------------------------------------------------------*/
	proc sql;
		create table cps_1968_2011_adltfemeduc as
		select hhid, avg(FemEd_LtHs) as FemEd_LtHs_avg, avg(FemEd_Grad_Hs) as FemEd_Grad_Hs_avg, avg(FemEd_Grad_Hs_Dip) as FemEd_Grad_Hs_Dip_avg,
					 avg(FemEd_Grad_Hs_Ged) as FemEd_Grad_Hs_Ged_avg, avg(Femcompleted_hs) as Femcompleted_hs_avg, avg(FemEd_SomeColl) as FemEd_SomeColl_avg,
					 avg(FemEd_2YrColl) as FemEd_2YrColl_avg, avg(FemEd_4YrColl) as FemEd_4YrColl_avg, avg(FemEd_Coll) as FemEd_Coll_avg, avg(FemEd_GtColl) as FemEd_GtColl_avg
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

	proc freq data=cps_1968_2011_adltfemedu; tables FemEd: / list missprint; run; 
	
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

	proc freq data=cps_1968_2011_adltfemedu; tables numpers / list missprint; run;  

		
	***CALCULATE THE NUMBER OF ADULTS WITHIN EACH HOUSEHOLD***;	
	proc sql;
		create table cps_1968_2011_hhnumadults as
		select hhid, count(*) as numadults
		from cps_1968_2011_adltfemedu
		where age>=16
		group by hhid
	;

	proc print data=cps_1968_2011_hhnumadults; 
		where hhid in("9999903985409131998"); 
		var hhid numadults; 
		title5 "AFTER CALC NUMADULTS BUT BEFORE REJOIN"; run; title5; run;  

	***JOIN THE NUMBER OF ADULTS VALUE BACK TO THE BASE DATA***;
	proc sql;
		create table cps_1968_2011_withnumadlt as
		select a.*, b.numadults
		from cps_1968_2011_adltfemedu as a left join cps_1968_2011_hhnumadults as b
		on a.hhid=b.hhid
	;

	proc print data=cps_1968_2011_withnumadlt; 
		where hhid in("9999903985409131998"); 
		var _year hhid lineno popstatnew age numadults; 
		title5 "AFTER CALC NUMADULTS AND AFTER NUMADULTS REJOIN"; run; title5; run;

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
	
proc freq data=cps_allvars_1968_2011_povlev; tables PovLev_Defl / list missprint; run; 

***RE-JOIN POVERTY LEVELS (ADJUSTED FOR INFLATION) TO ALL RECORDS FOR A PARTICULAR SURVEY YEAR AND HH PERSONS COMBO***;
proc sql;
	create table cps_allvars_1968_2011 as
	select a.*, b.PovLev_Defl
	from cps_1968_2011_allpers_numkids as a left join cps_allvars_1968_2011_povlev as b
	on a._year=b.issue_dt and a.numpers=b.persnum;

    
proc print data=cps_allvars_1968_2011; where _year=2011; var hhid lineno _year numpers PovLev_Defl; run; 
	
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

data test1;
	set cps_allvars_1968_2011;
run;

proc freq data=test1; where age>21; tables completed_hs / list missing; run;
proc freq data=test1; where age>21 and _year>=1992; tables Ed_Grad_Hs / list missing; run;
proc freq data=test1; where age>21 and _year>=1998 and dipged^in(. -1); tables Ed_Grad_Hs_Ged Ed_Grad_Hs_Dip / list missing; run;	

proc datasets lib=work nolist;
change cps_allvars_1968_2011 = cps_1968_2011_allpers_for_chrt;
quit;
run;

***CALL THE COHORT BUILDING PROGRAM***;
%include chrtbld;

endsas;


