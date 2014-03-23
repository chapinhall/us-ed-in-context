
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
	       AttendedPreK Ed_LtHs completed_hs Ed_Grad_Hs Ed_Grad_Hs_Dip Ed_Grad_Hs_Ged Ed_SomeColl Ed_Coll Ed_GtColl
	       FemEd_LtHs_avg Femcompleted_hs_avg FemEd_Grad_Hs_avg FemEd_Grad_Hs_Dip_avg FemEd_Grad_Hs_Ged_avg FemEd_SomeColl_avg FemEd_Coll_avg FemEd_GtColl_avg
	       FamInc_Def_Max_0020k FamInc_Def_Max_2040k FamInc_Def_Max_4060k FamInc_Def_Max_6080k FamInc_Def_Max_80kplus
	       FamInc_Def_Avg_0020k FamInc_Def_Avg_2040k FamInc_Def_Avg_4060k FamInc_Def_Avg_6080k FamInc_Def_Avg_80kplus
	       FamilyIncMax_Below100FPL FamilyIncAvg_Below100FPL FamilyIncMax_Below50FPL FamilyIncAvg_Below50FPL 
	       FamilyIncMax_Below200FPL FamilyIncAvg_Below200FPL
	       KidsinHH_Age0to3 KidsinHH_Age4to6 KidsinHH_Age0to6 KidsinHH_Age7to16 KidsinHH_Age0to16
	       NumKidsinHH_Age0to3 NumKidsinHH_Age4to6 NumKidsinHH_Age0to6 NumKidsinHH_Age7to16 NumKidsinHH_Age0to16
       	       
	       / list missprint;
	       format 
	       RaisedWith2Adults
	       Gender_Male Gender_Female 
	       Race_WhiteNonH Race_BlackNonH Race_Hisp
	       AttendedPreK Ed_LtHs completed_hs Ed_Grad_Hs Ed_Grad_Hs_Dip Ed_Grad_Hs_Ged Ed_SomeColl Ed_Coll Ed_GtColl
	       FamInc_Def_Max_0020k FamInc_Def_Max_2040k FamInc_Def_Max_4060k FamInc_Def_Max_6080k FamInc_Def_Max_80kplus
	       FamInc_Def_Avg_0020k FamInc_Def_Avg_2040k FamInc_Def_Avg_4060k FamInc_Def_Avg_6080k FamInc_Def_Avg_80kplus
	       FamilyIncMax_Below100FPL FamilyIncAvg_Below100FPL FamilyIncMax_Below50FPL FamilyIncAvg_Below50FPL 
	       FamilyIncMax_Below200FPL FamilyIncAvg_Below200FPL
	       KidsinHH_Age0to3 KidsinHH_Age4to6 KidsinHH_Age0to6 KidsinHH_Age7to16 KidsinHH_Age0to16 yesnof.;
	title5 "VERIFY FINAL COHORT COUNTS AND FINAL BINARY INDICATORS";
run; title5; run; 

proc contents data=cps_cohorts_1920_2011; run; 
proc sort data=cps_cohorts_1920_2011; by hhid lineno; run;

proc print data=cps_cohorts_1920_2011;
	where hhid="9240521195081980";
	var cohort _year age race3 Gender_Female hhid lineno wgtfnl faminc NumKidsinHH_Age0to16 KidsinHH_Age0to16; 
	title5 "LOOK AT WGTFNL FIELD (HHID=9240521195081980)";
run; title5; run;

proc sort data=cps_cohorts_1920_2011 out=testundup nodupkey; by hhid lineno; run;
	
proc sql;
	create table grandtot as
	select sum(wgtfnl) as gtot
	from testundup
;

/* NSM: Because I've been having problems getting all of the SAS code to run all the way through my "by-cohort summaries" code below, 
	I've added this small bit of code to 
		(A) try to save a copy of the data to goodland so that I can put it up separately without having to run all of this code; and
		(B) by putting it before the "proc print" below, test if the code has been hanging before getting to my "by-cohort summaries" code,
			or if SAS is somehow skipping over code that I ask it to run. I'm getting very paranoid.
	... My current hypothesis is that I'm not totally crazy, and that the p2 code file was just referencing a version of p3 that I WASN'T
	working on, and which didn't have the code which I'd added. Am testing that now.  */
	
data here.cps_cohorts_1920_2011;
	set cps_cohorts_1920_2011;
run;

proc print data=grandtot; var gtot; run;
proc freq data=here.cps_cohorts_1920_2011; tables cohort / list missing; run;

%include chrtsum;

endsas;

