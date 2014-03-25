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

AllEds         <- c("Ed_Hs_Ged", "Ed_Hs",   "Ed_Ged",   "Ed_SomeColl",  "Ed_SomeCollIf",    "Ed_Coll", "Ed_CollIf",      "Ed_2YrColl", "Ed_2YrCollIf", "Ed_4YrColl", "Ed_4YrCollIf")
AllHsEds       <- c("Ed_Hs_Ged", "Ed_Hs", "Ed_Ged")
AllLvlEds      <- c("Ed_Hs_Ged", "Ed_SomeColl",   "Ed_Coll")
AllCondEds     <- c("Ed_Hs_Ged", "Ed_SomeCollIf", "Ed_CollIf")
AllNewEds      <- c("Ed_Hs", "Ed_Ged")
AllYrColl      <- c("Ed_2YrColl",   "Ed_4YrColl",   "Ed_Coll")
AllCondYrColl  <- c("Ed_2YrCollIf", "Ed_4YrCollIf", "Ed_CollIf")

AllEds_l        <- c("HS/GED",    "HS Only", "GED Only", "Some College", "Some Coll If HS",  "College", "Compl. Coll. If Attend", "2Yr Coll",   "2Yr Compl. Coll. If Attend", "4Yr Coll",   "4Yr Compl. Coll. If Attend")
names(AllEds_l) <- AllEds
By_l        <- c("Cohort of Birth", "Year of Survey")
names(By_l) <- c("cohort",          "year")

Dems <- c("Gender_Male", "Gender_Female", "Race_WhiteNonH", "Race_BlackNonH", "Race_Hisp")
Dems_l <- c("Males", "Females", "White NonH", "Black NonH", "Hispanic")
names(Dems_l) <- Dems

Inds <- c("RaisedWith2Adults", "FemEd_LtHs_avg", "FemEd_Hs_Ged_avg", "FemEd_Coll_avg", "FamilyInc_Defl", "FamilyInc_Defl_Avg")
Inds_l <- c("Raised w/2 Adults", "Mom's Ed < HS", "Mom's Ed >= \nHS or GED", "Mom's Ed >= Coll", "Family Inc, $10ks", "Family Avg Inc, $10ks")
names(Inds_l) <- Inds

SomeSampleNs <- c("RaisedWith2Adults_N", "Ed_Hs_Ged_N", "Ed_Hs_N") # "Ed_Coll_N"
SomeSampleNs_l <- c("Raised w/2 Adults", "Ed = HS/GED", "Ed = HS") #"Ed = Coll"
names(SomeSampleNs_l) <- SomeSampleNs