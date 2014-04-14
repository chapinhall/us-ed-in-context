
******************************************************************************;
*** PROGRAM:  VAR_FORMATS.SAS                                              ***;                       
***                                                                        ***;
*** LOCATION: GOODLAND Server:                                             ***;
***           /projects/Lumina_SocIndOfPostSec/Code/jrh_generation_4_progs ***;
*** PROGRAMMER:    Jeff Harrington                                         ***;
*** DESCRIPTION:   This program creates user-defined formats for fields.   ***;
***                                                                        ***;
*** CREATED:       09/03/13                                                ***;
*** UPDATES:       09/03/13 by Jeff Harrington                             ***;
***                  Initial creation to streamline base program size.     ***;
***                                                                        ***;        
******************************************************************************;
options mprint mlogic symbolgen linesize=132;
libname oraora oracle user=&orauser orapw=&orapass path=&oradb;
libname here '/projects/Lumina_SocIndOfPostSec/Data';

**************************;
***USER DEFINED FORMATS***;
**************************;
proc format;
	
	value    istatnew 1="Interview" 2="Noninterview-Elig But Unavail" 3="Noninterview-Temporary Inelig" 4="Noninterview-Permanent Inelig";
	value    yesnof   .="Missing/NA" 0="No" 1="Yes";
	value    compeduf .="Missing/<=25 Yearls Old" 0="No" 1="Yes"; 
	value    numpersf .="Missing" 1="0-1" 2="2-3" 3="4-5" 4="6 or More";
	value    rtyp_new 1="Interviewed Adult" 2="Type A Non-Interview" 3="Type B/C Non-Interview" 4="Armed Forces Record" 5="Child Record";
	value    rtyp_old 1="Interviewed Adult or Child Rec" 2="Type A Non-Interview" 3="Type B/C Non-Interview";
	value    istatnew 1="Interview" 2="Non-Interview Type A" 3="Non-Interview Type B" 4="Non-Interview Type C";
	value    istatold 1="Interview" 2="Non-Interview Type A" 3="Non-Interview Type B/C";	
	value    hhtypnew .="Missing" 0="Non-interview Household" 1="Hus/Wife Prim Fam (0 Armd Forc)" 2="Hus/Wife Prim Fam (1+ Armd Forc)" 3="Unmarr Civ Male-Prim Fam Hholder"
	                  4="Unmarr Civ Fem-Prim Fam Hholder" 5="Unmarr Prim Hholder-Armed Forces" 6="Civilian Male-Primary Individ" 7="Civilian Female-Primary Individ"
	                  8="Prim Ind HH-Ref Pers Armed Forc" 9="Group Qtrs W Family" 10="Group Qtrs w/o Family";
	value    famtypf  .,-1="Missing" 1="Primary Family" 2="Primary Individual" 3="Related Subfamily" 4="Unrelated Secondary Family" 5="Unrelated Secondary Individ";
	value    famrelf  .,-1="Missing" 0="Not Family Member" 1="Reference person" 2="Spouse" 3="Child" 4="Other Rel-Prim Fam/Unrel Subfam";
	value    rrpf     -1="Missing" 01="Ref Pers W Rel In HH" 02="Ref Person-No Rel In HH" 03="Spouse" 04="Own Child/Ref Child" 05="Grandchild" 06="Parent" 
	                  07="Brother/Sister" 08="Oth Rel Of Ref person" 09="Foster Child" 10="NonRel of Ref w Own Rel In HH" 12="NonRel of Ref w/o Own Rel In HH" 
	                  13="Unmarr Partner w Rel" 14="Unmarr Partner w/o Rel" 15="House/Room Mate w Rel" 16="House/Room Mate w/o Rel" 17="Roomer/Boarder w Rel" 18="Roomer/Boarder w/o Rel";
	value    lvqtrsf  00="Other Unit" 01="House/Apt/Flat" 02="HU Non-Transient Hotel" 03="HU Perm Transient Hotel/Motel" 04="HU Rooming House" 
	                  05="Mobile/Trailer w/o Perm Room Add" 06="Mobile/Trailer w Perm Room Add" 07="HU Other" 08="Non-HU Qrts Room/Board House" 09="Non-Perm Unit Trans Hotel/Motel"
	                  10="Tent/Trailer Site" 11="Student Qrts in College Dorm";
	value    raceelev -1="Non-Entry" -2="Do Not Know" -3="Refused" 1="White Only" 2="Black Only" 3="Amer Indian/Alaskan Native Only" 4="Asian Only" 
	                  5="Hawaiian/Pacific Islander Only" 6="White-Black" 7="White-AI" 8="White-Asian" 9="White-Hawaiian" 10="Black-AI" 11="Black-Asian" 
	                  12="Black-Hawaiian" 13="AI-Asian" 14="Asian-Hawaiian" 15="W-B-AI" 16="W-B-A" 17="W-AI-A" 18="W-A-HP" 19="W-B-AI-A" 20="2 or 3 Races" 21="4 or 5 Races";
	value    race3f    -3="Refused" -2="Don't Know" -1="Non-Entry" 1="White Only" 2="Black Only" 3="Other";
	value    racetwo  -1="Non-Entry" -2="Do Not Know" -3="Refused" 1="White Only" 2="Black Only" 3="Amer Indian/Alaskan Native Only" 4="Asian/Pacific Islander";
	value    racenfiv -1="Non-Entry" -2="Do Not Know" -3="Refused" 1="White Only" 2="Black Only" 3="Amer Indian/Alaskan Native Only" 4="Asian/Pacific Islander" 5="Other";
	value    racenthr 1="White Only" 2="Black Only" 3="Amer Indian/Alaskan Native Only" 4="Asian/Pacific Islander" 5="Other";
	value    raceeigh 1="White Only" 2="Black Only" 3="Other";
	value    race1103f -1="Non-Entry" -2="Do Not Know" -3="Refused" 1="White Only" 2="Black Only" 3="Amer Indian/Alaskan Native Only" 4="Asian Only"
	                   5="Hawaiian/Pacific Isl. Only" 6="White-Black" 7="White-AI" 8="White-Asian" 9="White-Hawaiian" 10="Black-AI" 11="Black-Asian"
	                   12="Black-Hawaiian" 13="AI-Asian" 14="Asian-Hawaiian" 15="W-B-AI" 16="W-B-A" 17="W-AI-A" 18="W-A-HP" 19="W-B-AI-A"
	                   20="2 or 3 Races" 21="4 or 5 Races";
	value    hispf    .,-1="Missing" 1="Hispanic" 2="Non-Hispanic";
	value    spnishf  0="Spanish Not The Only Language Spoken" 1="Spanish Only Language Spoken";
	value    spnethf  .,-1="Missing/NA/Dont Know" 1="Mexican" 2="Puerto Rican" 3="Cuban" 4="Central-South Amiercan" 5="Other Spanish";
	value    sexf     -1="Missing" 1="Male" 2="Female"; 
	value    popstatf 1="Child Household member (0-14)" 2="Adult Household member (15+)";
	value    age1104f -1="Missing";
	value    natvtyf  -1="Missing" 57="United States" 66="Guam" 73="Puerto Rico" 78="US Virgin Islands" 96="US Outlying Area" 
	                  100-554="Foreign Country or At Sea" 555="Abroad, Not Known";
	value    fmic1103f -3,-2,-1="Refused/Dont Know/Blank" 1="Under $5,000" 2="$5,000-7,499" 3="$7,500-9,999" 4="$10,000-12,499" 
	                   5="$12,500-14,999" 6="$15,000-19,999" 7="$20,000-24,999" 8="$25,000-29,999" 9="$30,000-34,999" 10="$35,000-39,999" 11="$40,000-49,999"
	                  12="$50,000-59,999" 13="$60,000-74,999" 14="$75,000-99,999" 15="$100,000-149,999" 16="$150,000 or more";
	value    edu1192f -1="Missing" 31="Less Than 1st grade" 32="1st, 2nd, 3rd, or 4th grade" 33="5th or 6th grade" 34="7th or 8th grade"
	                   35="9th grade" 36="10th grade" 37="11th grade" 38="12th grade-no diploma" 39="HS graduate (diploma/GED)"
	                   40="Some college, no degree" 41="Assoc. degree - occ/voc program" 42="Assoc. degree - academic program"
	                   43="Bachelor's degree (BA, BS, AB, etc)" 44="Master's degree (MA, MS, MBA, etc)" 45="Professional school degree (MD, DDS, DVM, etc)"
	                   46="Doctorate degree (PhD, EdD, etc)";
	value   dpgedf     .,-1="NIU, blank" 1="Graduation from high school" 2="GED or other equivalent";
	
	value   chattf     -1="NIU" 1="Attending school/yes" 2="Not attending school/no";
	value   schattf    .,-1,9,3="NIU, blank" 1="Attending school/yes" 2="Not attending school/no";
	value   grdattf -1="NIU" 1="Grade 1" 2="Grade 2" 3="Grade 3" 4="Grade 4" 5="Grade 5" 6="Grade 6" 7="Grade 7" 8="Grade 8"  
	                   9="High school 1" 10="High school 2" 11="High school 3" 12="High school 4" 13="College 1 (freshman)"
	                   14="College 2 (sophomore)" 15="College 3 (junior)" 16="College 4 (senior)" 17="College 5 (grad yr 1)"
	                   18="College 6 (grad yr 2+)" 19="Special school" 20="No response";
	value  educf       .="Post-1991" 0="Less Than Elementary/Child" 1="Grade 1" 2="Grade 2" 3="Grade 3" 4="Grade 4" 5="Grade 5" 6="Grade 6" 7="Grade 7" 8="Grade 8"  
	                   9="High school 1" 10="High school 2" 11="High school 3" 12="High school 4" 13="College 1 (freshman)"
	                   14="College 2 (sophomore)" 15="College 3 (junior)" 16="College 4 (senior)" 17="College 5 (grad yr 1)"
	                   18="College 6 (grad yr 2+)"; 
	value  colf        -1="Blank or NIU" 1="2 Year College" 2="4 Year College";
	value  colbf       -1="Blank or NIU" 0="2 Year College" 1="4 Year College";
	value  colcf       -1="Blank or NIU" 0="2 Year College=Yes" 1="2 Year College=No";
/**value  hsgedf     .="Missing" -9="N/A" -3="Refusal" -2="Don't Know" -1,9="NIU" 1="Yes (GED)" 2="No (not GED)"; **/
	value  hsgedf      .,-9,-3,-2,-1="NIU/NA/Refusal/Dont Know/Missing" 1="Yes (GED)" 2="No (not GED)";
	value  dipgedf    .,-1="NIU/Missing" 1="Grad from High School" 2="GED or Other Equiv";
	value  grdatnf    .,-1,0="Missing/No Educ/Not an Adult" 31="Less than 1st Grade" 32="1st, 2nd, 3rd, or 4th Grade" 33="5th or 6th Grade"
	                  34="7th or 8th Grade" 35="9th Grade" 36="10th Grade" 37="11th Grade" 38="12th Grade--No Diploma"
	                  39="HS Grad--Diploma, GED, etc" 40="Some College, no degree" 41="Associate's Degree-Occ/Voc Program"
	                  42="Associate's Degree-Academic Program" 43="Bachelor's Degree-BA, BS, AB, etc" 44="Master's Degree-MA, MS, MBA, etc"
	                  45="Professional School Degree (MD, DDS, etc)" 46="Doctorate Degree-PhD, EdD, etc";
	value  momtypf    .="Missing/Older than 18" -1="No Mother Present" 01="Biological" 02="Step" 03="Adopted";
	value  dadtypf    .="Missing/Older than 18" -1="No Father Present" 01="Biological" 02="Step" 03="Adopted";	
	value  schlvlf    .,-1="NIU" 1="High School" 2="College/University";
	value  schenrf    .,-1="NIU" 1="Yes" 2="No";
	value  colftptf   ., 9, -1 ="NIU" 1="Full Time" 2="Part Time" 3="N/A";
	value  agecatf    1="0-10 Years" 2="11-20 Years" 3="21-40 years" 4="41-60 Years" 5="61-80 Years" 6="80+ Years";                
	                  
	value hhrelf      1="Male head, living with relatives" 2="Male head, living without relatives" 3="Male relative of head" 4="Male nonrelative of head"
	                  5="Female head, living with relatives" 6="Female head, living without relatives" 7="Wife of head" 8="Female relative of head"
	                  9="Female nonrelative of head";
	                  
	value famnumf     0="Not a family member" 1="Primary family member only" 2-39="Member of subfamil #";

run;

