
******************************************************************************;
*** PROGRAM:  P4_GENERATE_COHORT_AVERAGES_V3_CONSOLIDATING_CODE.SAS        ***;                       
***                                                                        ***;
*** LOCATION: GOODLAND SERVER:                                             ***;
***           /projects/Lumina_SocIndOfPostSec/Code/generation_6_progs     ***;
*** PROGRAMMERs:    Jeff Harrington and Nick Mader                         ***;
*** DESCRIPTION:   This program generates descriptive statistics for each  ***;
***                cohort, both overall, and by each combination of gender ***;
***                and race.  The results aer output to CSV and SAS files. ***;
***                                                                        ***;
*** CREATED:       08/01/13                                                ***;
*** UPDATES:       02/26/14 by Jeff Harrington                             ***;
***                 Removed less efficient code and replaced it with more  ***;
***                 streamlined code provided by Nick Mader.               ***;
***                                                                        ***;        
******************************************************************************;

 /* options mprint mlogic symbolgen linesize=132; */

libname here '/projects/Lumina_SocIndOfPostSec/Data';
filename varlab '/projects/Lumina_SocIndOfPostSec/Code/var_labels.sas';
filename varform '/projects/Lumina_SocIndOfPostSec/Code/var_formats.sas';
*%include varlab;
%include varform;

options nomprint nomlogic nosymbolgen;

/* Read data and add a few variables that will be useful for the loops below */
data cps_cohorts_1920_2011;
	set here.cps_cohorts_1920_2011;
	Gender_All = 1;
	Race_All = 1;
	All = 1;
	year = _year;
run;

proc sort data = cps_cohorts_1920_2011; by cohort;
proc means data = cps_cohorts_1920_2011;
	var Ed_Grad_Hs;
	by cohort;
run;

/* Examine the data */

/*----------------------------------------*/
/* Collapse data into by-cohort summaries */
/*----------------------------------------*/
%let MyVars = All
              RaisedWith2Adults
              Gender_Male Gender_Female 
              Race_WhiteNonH Race_BlackNonH Race_Hisp
              AttendedPreK Ed_LtHs Ed_Compl_12Yrs Ed_Compl_14Yrs Ed_Compl_16Yrs Ed_Grad_Hs Ed_Combined_Hs Ed_Grad_Hs_Dip Ed_SomeColl Ed_GeColl Ed_Combined_GeColl Ed_GtColl
              FemEd_LtHs_avg FemEd_Compl_12Yrs_avg FemEd_Compl_14Yrs_avg FemEd_Compl_16Yrs_avg FemEd_Grad_Hs_avg FemEd_Combined_Hs_avg FemEd_Grad_Hs_Dip_avg FemEd_SomeColl_avg FemEd_GeColl_avg FemEd_Combined_GeColl_avg FemEd_GtColl_avg
			  FamilyInc_Defl FamilyInc_Defl_Avg FamilyInc_Defl_Max
              FamInc_Def_Max_0020k FamInc_Def_Max_2040k FamInc_Def_Max_4060k FamInc_Def_Max_6080k FamInc_Def_Max_80kplus
              FamInc_Def_Avg_0020k FamInc_Def_Avg_2040k FamInc_Def_Avg_4060k FamInc_Def_Avg_6080k FamInc_Def_Avg_80kplus
              FamilyIncMax_Below100FPL FamilyIncAvg_Below100FPL FamilyIncMax_Below50FPL FamilyIncAvg_Below50FPL FamilyIncMax_Below200FPL FamilyIncAvg_Below200FPL
              KidsinHH_Age0to3 KidsinHH_Age4to6 KidsinHH_Age0to6 KidsinHH_Age7to16 KidsinHH_Age0to16
              NumKidsinHH_Age0to3 NumKidsinHH_Age4to6 NumKidsinHH_Age0to6 NumKidsinHH_Age7to16 NumKidsinHH_Age0to16;

/*** Build variables lists to use in the PROC MEANS statement below */
			  
%let MyVars_StdDev = ;
%let MyVars_N = ;
%let MyVars_StdErr = ;
%macro CreateMoreNames;
	%let i = 1;
	%do %until (%scan(&MyVars., &i.) = );
		%let v = %scan(&MyVars., &i.);
		%let MyVars_StdDev = &MyVars_StdDev. &v._sd;
                %let MyVars_StdErr = &MyVars_StdErr. &v._se;
		%let MyVars_N      = &MyVars_N.      &v._N;
		%let i = %eval(&i. + 1);
	%end;
%mend;
%CreateMoreNames;

/*----------------------------------------------------------------------*/
/* RUN LOOP OF DESCRIPTIVE SUMMARY CALCULATIONS BY GENDER/RACE SUBGROUP */
/*----------------------------------------------------------------------*/

%macro countw(list=);
 %sysfunc(countw(&list))
%mend countw;

%let bList = cohort year;
%let gList = All Male Female;
%let rList = All WhiteNonH BlackNonH Hisp;

%let OutList;
%macro CreateSums;

	/* Run Loop Across "By" Variables of cohort and year */
		
	%do ib = 1 %to %countw(list=&bList.);
		%let b = %scan(&bList., &ib.);
	
		/* Run Loop Across Gender */		
		%do ig = 1 %to %countw(list=&gList.);
			%let g = %scan(&gList., &ig.);
			
			/* Run Loop Across Race */
			%do ir = 1 %to %countw(list=&rList.);
				%let r = %scan(&rList., &ir.);
				
				/* Run Loop Across Weighting */
				%do iw = 0 %to 1;
					%if &iw. = 0 %then %do;
						%let w = NoW;
						%let WgtCmd = ;
						%end;
					%if &iw. = 1 %then %do;
						%let w = Wgt;
						%let WgtCmd = weight wgtfnl;
					%end;
				
					%put Running analysis for b = &b., g = &g., r = &r., w = &w.;
					proc sort data = cps_cohorts_1920_2011; by &b.;
					proc means data = cps_cohorts_1920_2011 (where = (Gender_&g. = 1 & Race_&r. = 1)) noprint;
						var &MyVars.;
						by &b.;
						&WgtCmd.;
						output out = Sum_&g._&r._&b._&w. (drop = _TYPE_ _FREQ_) mean = &MyVars. std = &MyVars_StdDev. stderr = &MyVars_StdErr. n = &MyVars_N.;
					run;
					data Sum_&g._&r._&b._&w.;
						set Sum_&g._&r._&b._&w.;
						Gender = "&g.";
						Race = "&r.";
						By = "&b.";
						Weight = "&w.";
					run;
					
					%let OutList = &OutList. Sum_&g._&r._&b._&w.;
					%put OutList is currently &OutList.;
					
				%end; /* End of Loop across weights */
				
			%end; /* End of loop across race */
			
		%end; /* End of loop across gender */
		
	%end; /* End of loop across "by" conditions: year versus cohort */
	
%mend;
%CreateSums;

proc print data = Sum_All_All_cohort_NoW;
run;

/* Pull together all data summaries for each demographic combination. */

data cps_cohort_summary;
	length Race $9. Gender $6.;
	set &OutList.;
run;

data here.cps_cohort_summary;
	set cps_cohort_summary;
run;

proc export data = cps_cohort_summary outfile = "/projects/Lumina_SocIndOfPostSec/Data/cps_cohort_summary.csv" dbms = csv replace; run;


endsas;



