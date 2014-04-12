
******************************************************************************;
*** PROGRAM:  P3_BUILD_COHORTS_V5_STREAMLINE_COHORT_BUILD.SAS              ***;                       
***                                                                        ***;
*** LOCATION: GOODLAND SERVER:                                             ***;
***           /projects/Lumina_SocIndOfPostSec/Code/generation_6_progs     ***;
*** PROGRAMMERS:    Jeff Harrington and Nick Mader.                        ***;
*** DESCRIPTION:   This program builds a birth cohort for each year.       ***;
***                                                                        ***;
***                For example, for the 1978 birth cohort, the program     ***;
***                selects records where 0<=age<1 and age is not missing   ***;
***                from the 1978 data pull, records where 1<=age<2 and age ***;
***                not missing from the 1979 data pull, and so on through  ***;
***                the latest data year of 2011.  For the 1979 cohort, it  ***;
***                selects records where 0<=age<1 and age is not missing   ***;
***                from the 1979 data pull, records where 1<=age<2 and age ***;
***                not missing from the 1980 data pull, and so on.         ***;
***                                                                        ***;
***                Then, all yearly birth cohorts are set together with a  ***;
***                variable called cohort identifying the cohort for which ***;
***                each record is a member.                                ***;
***                                                                        ***;
***                                                                        ***;
*** CREATED:       08/01/13                                                ***;
*** UPDATES:       02/26/14 by Jeff Harrington                             ***;
***                 Removed less efficient code and replaced it with more  ***;
***                 streamlined code provided by Nick Mader.               ***;
***                08/01/13 by Jeff Harrington                             ***;
***                 Re-named file for better organization.                 ***;
***                 Incorporated new, streamlined cohort build method.     ***;
***                                                                        ***;        
******************************************************************************;
options mprint mlogic symbolgen linesize=132;
libname oraora oracle user=&orauser orapw=&orapass path=&oradb;
libname here '/projects/Lumina_SocIndOfPostSec/Data';
filename chrtsum '/projects/Lumina_SocIndOfPostSec/Code/generation_6_progs/p4_generate_cohort_averages_v3_consolidating_code.sas';


	data cps_cohorts_1920_2011 (rename = (cohort_yr = cohort));
		set cps_1968_2011_allpers_for_chrt (where = (1920 <= cohort_yr & cohort_yr < 2012));
	proc sort data = cps_cohorts_1920_2011; by cohort hhid lineno;
	run;


proc freq data=cps_cohorts_1920_2011;
	weight wgtfnl;
	tables cohort cohort*_year
	       RaisedWith2Adults*numadults 
	       sex*Gender_Male*Gender_Female 
	       race3*spneth race3*Race_WhiteNonH*Race_BlackNonH*Race_Hisp
	       AttendedPreK Ed_LtHs Ed_Compl_12Yrs Ed_Compl_14Yrs Ed_Compl_16Yrs Ed_Grad_Hs Ed_Combined_Hs Ed_Grad_Hs_Dip Ed_SomeColl Ed_GeColl Ed_Combined_GeColl Ed_GtColl
	       FemEd_LtHs_avg FemEd_Compl_12Yrs_avg FemEd_Grad_Hs_avg FemEd_Combined_Hs_avg FemEd_Grad_Hs_Dip_avg FemEd_SomeColl_avg FemEd_GeColl_avg FemEd_GtColl_avg
	       FamilyIncMax_Below100FPL FamilyIncAvg_Below100FPL FamilyIncMax_Below50FPL FamilyIncAvg_Below50FPL 
	       FamilyIncMax_Below200FPL FamilyIncAvg_Below200FPL
	       KidsinHH_Age0to3 KidsinHH_Age4to6 KidsinHH_Age0to6 KidsinHH_Age7to16 KidsinHH_Age0to16
	       NumKidsinHH_Age0to3 NumKidsinHH_Age4to6 NumKidsinHH_Age0to6 NumKidsinHH_Age7to16 NumKidsinHH_Age0to16
       	       
	       / list missprint;
	       format 
	       RaisedWith2Adults
	       Gender_Male Gender_Female 
	       Race_WhiteNonH Race_BlackNonH Race_Hisp
	       AttendedPreK Ed_LtHs Ed_Compl_12Yrs Ed_Grad_Hs Ed_Combined_Hs Ed_Grad_Hs_Dip Ed_SomeColl Ed_Coll Ed_GtColl
	       FamilyIncMax_Below100FPL FamilyIncAvg_Below100FPL FamilyIncMax_Below50FPL FamilyIncAvg_Below50FPL 
	       FamilyIncMax_Below200FPL FamilyIncAvg_Below200FPL
	       KidsinHH_Age0to3 KidsinHH_Age4to6 KidsinHH_Age0to6 KidsinHH_Age7to16 KidsinHH_Age0to16 yesnof.;
	title5 "VERIFY FINAL COHORT COUNTS AND FINAL BINARY INDICATORS";
run; title5; run; 

/* 
FamInc_Def_Max_0020k FamInc_Def_Max_2040k FamInc_Def_Max_4060k FamInc_Def_Max_6080k FamInc_Def_Max_80kplus
FamInc_Def_Avg_0020k FamInc_Def_Avg_2040k FamInc_Def_Avg_4060k FamInc_Def_Avg_6080k FamInc_Def_Avg_80kplus
FamInc_Def_Max_0020k FamInc_Def_Max_2040k FamInc_Def_Max_4060k FamInc_Def_Max_6080k FamInc_Def_Max_80kplus
FamInc_Def_Avg_0020k FamInc_Def_Avg_2040k FamInc_Def_Avg_4060k FamInc_Def_Avg_6080k FamInc_Def_Avg_80kplus */

proc contents data=cps_cohorts_1920_2011; run; 
proc sort data=cps_cohorts_1920_2011; by hhid lineno; run;

proc sort data=cps_cohorts_1920_2011 out=testundup nodupkey; by hhid lineno; run;
	
proc sql;
	create table grandtot as
	select sum(wgtfnl) as gtot
	from testundup
;

/**CREATE A PERM COPY OF THE MULTI-YEAR DATASET TO STREAMLINE PROGRAM TESTING
   (ALLOW US TO BYPASS RUNNING THE P1 AND P2 PROGRAMS FOR EACH TEST PASS**/	
data here.cps_cohorts_1920_2011;
	set cps_cohorts_1920_2011;
run;

%include chrtsum;

endsas;

