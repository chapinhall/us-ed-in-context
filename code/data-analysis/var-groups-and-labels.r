#---------------------------------------------
#---------------------------------------------
## (0) Generate labels and groups of variables
#---------------------------------------------
#---------------------------------------------

Genders <- c("Male", "Female")
Races <- c("WhiteNonH", "BlackNonH", "Hisp")
AllBys         <- c("cohort", "year") # 
AllGenders     <- c("All", Genders)
AllRaces       <- c("All", Races)

AllEds         <- c("Ed_LtHs", "Ed_Compl_12Yrs", "Ed_Grad_Hs", "Ed_Combined_Hs", "Ed_SomeColl",  "Ed_SomeCollIf",    "Ed_GeColl", "Ed_GeCollIf") #,      "Ed_2YrColl", "Ed_2YrCollIf", "Ed_4YrColl", "Ed_4YrCollIf"
AllHsEds       <- c("Ed_Compl_12Yr", "Ed_Grad_Hs", "Ed_Combined_Hs")
AllLvlEds      <- c("Ed_Grad_Hs", "Ed_SomeColl",   "Ed_GeColl")
AllCondEds     <- c("Ed_Grad_Hs", "Ed_SomeCollIf", "Ed_GeCollIf")
#AllNewEds      <- c("Ed_Hs", "Ed_Ged")
#AllYrColl      <- c("Ed_2YrColl",   "Ed_4YrColl",   "Ed_GeColl")
#AllCondYrColl  <- c("Ed_2YrCollIf", "Ed_4YrCollIf", "Ed_GeCollIf")

AllEds_l        <- c("Less than HS",  "Completed 12\nYrs Sch", "HS/GED", "12Yrs Sch\nor HS/GED", "Some College", "Some Coll If HS/GED",  "College", "Compl. Coll. If Attend") #, "2Yr Coll",   "2Yr Compl. Coll. If Attend", "4Yr Coll",   "4Yr Compl. Coll. If Attend"
names(AllEds_l) <- AllEds
By_l        <- c("Cohort of Birth", "Year of Survey")
names(By_l) <- c("cohort",          "year")

Dems <- c("Gender_All", "Gender_Male", "Gender_Female", "Race_All", "Race_WhiteNonH", "Race_BlackNonH", "Race_Hisp")
Dems_l <- c("All", "Males", "Females", "All", "White Non-Hisp", "Black Non-Hisp", "Hispanic")
names(Dems_l) <- Dems

Inds <- c("AttendedPreK", "RaisedWith2Adults", "FemEd_Compl_12Yrs_avg", "FemEd_Compl_16Yrs_avg", "FamilyInc_Defl_Avg", "FamilyIncAvg_Above100FPL") # "FemEd_Grad_Hs_avg", "FemEd_GeColl_avg", 
Inds_l <- c("Attended Pre-K", "Raised w/2 Adults", "Mom's Ed >= 12 Yrs", "Mom's Ed >= 16 Yrs", "Family Avg Inc, $10ks", "Family Income\nAbove Poverty Line")
names(Inds_l) <- Inds

SomeSampleNs <- c("RaisedWith2Adults_N", "Ed_Grad_Hs_N", "Ed_GeColl_N") # "Ed_GeColl_N"
SomeSampleNs_l <- c("Raised w/2 Adults", "Ed >= HS/GED", "Ed >= Coll") #"Ed = Coll"
names(SomeSampleNs_l) <- SomeSampleNs

# This list was originally put together to reflect all variables that might be summarized in some fashion, e.g. by decade of
# birth cohort, although all of the tables and figures we have wound up generating make explicit mentions of subsets of variables,
# making this list quasi-deprecated.
descVars <- c("RaisedWith2Adults", "Gender_Male", "Gender_Female", "Race_WhiteNonH", "Race_BlackNonH", "Race_Hisp",
              "AttendedPreK", "Ed_LtHs", "Ed_Compl_12Yrs", "Ed_Grad_Hs", "Ed_Combined_Hs", "Ed_Grad_Hs_Dip", "Ed_SomeColl", "Ed_2YrColl", "Ed_4YrColl", "Ed_GeColl", "Ed_GtColl", 
              "FemEd_LtHs_avg", "FemEd_Compl_12Yrs", "FemEd_Grad_Hs", "FemEd_Combined_Hs", "FemEd_Grad_Hs_Dip", "FemEd_SomeColl_avg", "FemEd_2YrColl_avg", "FemEd_4YrColl_avg", "FemEd_GeColl_avg", "FemEd_GtColl_avg", 
              "FamilyInc_Defl", "FamilyInc_Defl_Avg", "FamilyInc_Defl_Max",
              "FamilyIncMax_Below100FPL", "FamilyIncAvg_Below100FPL", "FamilyIncMax_Below50FPL", "FamilyIncAvg_Below50FPL", "FamilyIncMax_Below200FPL", "FamilyIncAvg_Below200FPL",
              "KidsinHH_Age0to3", "KidsinHH_Age4to6", "KidsinHH_Age0to6", "KidsinHH_Age7to16", "KidsinHH_Age0to16",
              "NumKidsinHH_Age0to3", "NumKidsinHH_Age4to6", "NumKidsinHH_Age0to6", "NumKidsinHH_Age7to16", "NumKidsinHH_Age0to16")
#"FamInc_Def_Max_0020k", "FamInc_Def_Max_2040k", "FamInc_Def_Max_4060k", "FamInc_Def_Max_6080k", "FamInc_Def_Max_80kplus", 
#"FamInc_Def_Avg_0020k", "FamInc_Def_Avg_2040k", "FamInc_Def_Avg_4060k", "FamInc_Def_Avg_6080k", "FamInc_Def_Avg_80kplus", 