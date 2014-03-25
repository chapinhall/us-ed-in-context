## This code takes cleaned Current Population Survey Data and produces 
## Exhibits of trends and indicators of post-secondary education across 
## years and birth cohorts of Americans

## Set up environment
rm(list=ls())
try(setwd("C:/Documents and Settings/nmader/My Documents/Google Drive/Lumina/Data and Documentation"))
try(setwd("C:/Users/nmader/Google Drive/Lumina/Data and Documentation"))
myOutDir <- "C:/Users/nmader/Google Drive/Lumina/Output/"

"%&%" <- function(...){ paste(..., sep="") }
comment <- function(...){}
library("shiny")
library("plyr")
library("ggplot2")
library("stats")
library("reshape")

## Load data
cps <- read.csv("cps_cohort_summary.csv")
descVars <- c("RaisedWith2Adults", "Gender_Male", "Gender_Female",
              "Race_WhiteNonH", "Race_BlackNonH", "Race_Hisp",
              "AttendedPreK", "Ed_LtHs", "Completed_Hs", "Ed_Hs_Ged", "Ed_Hs", "Ed_Ged", "Ed_SomeColl", "Ed_2YrColl", "Ed_4YrColl", "Ed_Coll", "Ed_GtColl", 
              "FemEd_LtHs_avg", "Femcompleted_hs_avg", "FemEd_Hs_Ged_avg", "FemEd_Hs_avg", "FemEd_Ged_avg", "FemEd_SomeColl_avg", "FemEd_2YrColl_avg", "FemEd_4YrColl_avg", "FemEd_Coll_avg", "FemEd_GtColl_avg", 
              "FamilyInc_Defl", "FamilyInc_Defl_Avg", "FamilyInc_Defl_Max",
              "FamInc_Def_Max_0020k", "FamInc_Def_Max_2040k", "FamInc_Def_Max_4060k", "FamInc_Def_Max_6080k", "FamInc_Def_Max_80kplus", 
              "FamInc_Def_Avg_0020k", "FamInc_Def_Avg_2040k", "FamInc_Def_Avg_4060k", "FamInc_Def_Avg_6080k", "FamInc_Def_Avg_80kplus", 
              "FamilyIncMax_Below100FPL", "FamilyIncAvg_Below100FPL", "FamilyIncMax_Below50FPL", "FamilyIncAvg_Below50FPL", "FamilyIncMax_Below200FPL", "FamilyIncAvg_Below200FPL",
              "KidsinHH_Age0to3", "KidsinHH_Age4to6", "KidsinHH_Age0to6", "KidsinHH_Age7to16", "KidsinHH_Age0to16",
              "NumKidsinHH_Age0to3", "NumKidsinHH_Age4to6", "NumKidsinHH_Age0to6", "NumKidsinHH_Age7to16", "NumKidsinHH_Age0to16")


### Generate conditional education categories
cps$Ed_SomeCollIf     <- cps$Ed_SomeColl / cps$Ed_Hs_Ged
cps$Ed_SomeCollIf_Hs  <- cps$Ed_SomeColl / cps$Ed_Hs
cps$Ed_SomeCollIf_Ged <- cps$Ed_SomeColl / cps$Ed_Ged

cps$Ed_2YrCollIf  <- cps$Ed_2YrColl / cps$Ed_SomeColl
cps$Ed_4YrCollIf  <- cps$Ed_4YrColl / cps$Ed_SomeColl
cps$Ed_CollIf     <- cps$Ed_Coll    / cps$Ed_SomeColl

### Rescale household income
cps$FamilyInc_Defl     <- cps$FamilyInc_Defl     / 10000
cps$FamilyInc_Defl_Avg <- cps$FamilyInc_Defl_Avg / 10000
cps$FamilyInc_Defl_Max <- cps$FamilyInc_Defl_Max / 10000


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


#-----------------------------
#-----------------------------
## (1) Generate trend analysis
#-----------------------------
#-----------------------------
# x: birth cohort, y: based on outcome, graphs: absolute and conditional education, and social indicators
# series comparisons: males vs. females, by race, (by region?)

# See ggplot examples: http://www.cookbook-r.com/Graphs/Bar_and_line_graphs_(ggplot2)/

myYEdLab <- "Rate of Ed Attain"
lineSize = 1.1
titleRelSize = 1.0
axisRelSize = 0.6
legendRelSize = 0.6
pd <- position_dodge(.1)
myWidth  <- 2400
myHeight <- 1800

# Test values
b <- "cohort"; r <- "All"; g <- "All"; w <- "NoW";

#-----------------------------------
#-----------------------------------
### (2) Generate life cycle analysis
#-----------------------------------
#-----------------------------------

#--------------------------
### Run Regression Analysis
#--------------------------

SpecRuns <- list(Adults=c("RaisedWith2Adults"), MomEd=c("FemEd_Coll_avg"))
cps$one <- 1
cps$cohort2 <- cps$cohort^2
standardX <- c("one", "cohort", "cohort2")

# Initialize the output 
myOut <- data.frame(Spec = "init", x = "init", Ed = "init", Gender = "init", Race = "init", b = 0, se = 0, ll = 0, ul = 0)

# a. Run regressions of each education outcome on indicators, both overall and for each subdemographic
for (s in SpecRuns) { #XXX Could eventually transition this to "for (s in names(SpecRuns))" for naming simplicity
  for (e in AllCondEds) {
    
    ### Subset data
    # Avoid rows where education is invalid, equal to 0, or equal to 1
    validE <- !(is.na(cps[, e])) & (cps[, e] != 1) & (cps[, e] != 0) & cps$cohort <= 1985
    d <- cps[cps$Weight == "NoW" & !(is.na(cps$cohort)) & validE,
             c(e,  s, standardX, "Gender", "Race", "cohort")] # e %&% "_N", e %&% "_se"  ... XXX Added "n" values for conditional education outcomes doesn't work since it is undefined. Nice thought, but ultimately I need the delta method to actually deliver standard errors to do WLS.
    x <- "-1 + " %&% paste(c(standardX, s), collapse=" + ")
    
    for (g in AllGenders) {
      for (r in AllRaces) {
        
        tag <- paste(c(e, g, r), collapse="_")
        dd <- d[d$Gender == g & d$Race == r, ]
        
        # Run regression
        reg <- summary(lm(as.formula(e %&% "~" %&% x), data=dd)) #, weights = dd[, e %&% "_n"]))
        
        # Lightly process output
        out <- data.frame(s, rownames(reg$coeff), e, g, r, reg$coeff[, c("Estimate", "Std. Error")])
        colnames(out) <- c("Spec", "x", "Ed", "Gender", "Race", "b", "se")
        out$ll <- out$b - 1.96*out$se
        out$ul <- out$b + 1.96*out$se
        
        # Output results
        myOut <- rbind(myOut, out)
        assign(paste("reg", e, s, g, r, sep="_"), out)
        
      } # End of loop across (r)ace
    } # End of loop across (g)ender
  } # End of loop across (e)ducation
} # End of loop across (spec)ifications

rownames(myOut) <- NULL


#------------------------------------------------------------------------------------
### Generate compound marginal effect of given predictor on Ed, through full pathways
#------------------------------------------------------------------------------------
# Initialize output
myTotEff <- data.frame(Spec = "init", x = "init", Gender = "init", Race = "init", cohort = 0, b = 0, se = 0, ll = 0, ul = 0)

# Run loops -- XXX Can this wholly or largely be vectorized?
for (s in SpecRuns) {
  for (g in AllGenders) {
    for (r in AllRaces) {
      
      # XXX Will need to also loop across multiple predictors once they start getting used 
      outSub <- myOut[myOut$Spec == s & myOut$x == s & myOut$Gender == g & myOut$Race == r, c("b", "Ed")]
      dA <- outSub[outSub$Ed == "Ed_Hs_Ged",     "b"]
      dB <- outSub[outSub$Ed == "Ed_SomeCollIf", "b"]
      dC <- outSub[outSub$Ed == "Ed_CollIf",     "b"]
      
      cpsSub <- cps[cps$Gender == g & cps$Race == r & cps$Weight == "NoW" & !is.na(cps$cohort), c("cohort", AllCondEds)]
      A <- cpsSub[, "Ed_Hs_Ged"]
      B <- cpsSub[, "Ed_SomeCollIf"]
      C <- cpsSub[, "Ed_CollIf"]
      
      totEff <- (dA *  B *  C) + ( A * dB *  C) + ( A *  B * dC) +
        (dA * dB *  C) + (dA *  B * dC) + ( A * dB * dC) +
        (dA * dB * dC)
      
      #totEff_1985 <- totEff[cpsSub$cohort == 1985]
      out <- data.frame(Spec = s, x = s, Gender = g, Race = r, cohort = cpsSub$cohort, b = totEff, se = 0, ll = 0, ul = 0)
      
      myTotEff <- rbind(myTotEff, out)
      
      #----------------------
      ### Graph total effects
      #----------------------
      png(file = myOutDir %&% "TotFx_of_" %&% s %&% "_for_" %&% g %&% "_" %&% r %&% ".png", res = 600, width = myWidth, height = 1600)
      
      useData <- out
      myPlot <- ggplot(data=useData, aes(x = cohort, y = b)) + 
        labs(title = "Total Effect of " %&% Inds_l[s] %&% " on Coll. Compl.:\nGender - " %&% g %&% ", Race - " %&% r, x = By_l["cohort"], y = "Effect") +
        theme(plot.title = element_text(size = rel(titleRelSize)), 
              axis.title.x = element_text(size = rel(axisRelSize)), axis.title.y = element_text(size = rel(axisRelSize))) + 
        geom_line(size = lineSize, color = "purple")
      print(myPlot)
      
      dev.off()
      
    } # End of loop across (r)ace
  } # End of loop across (g)ender
} # End of loop across (s)pecifications


#--------------------------------------------------
### Coefficient graphs for each educational outcome
#--------------------------------------------------

for (s in SpecRuns) {
  
  #-----------------------------------------------
  # Compare effects across demographics by outcome
  #-----------------------------------------------
  
  for (e in AllCondEds) {
    # XXX Will need to loop across multiple predictors of interest once we have them in each specification
    p <- myOut[myOut$Spec == s & myOut$x == s & myOut$Ed == e & myOut$Race != "All" & myOut$Gender != "All",]
    xLab <- factor(p$Gender %&% "\n" %&% p$Race)
    xLab <- factor(xLab, levels=xLab)
    
    png(file = myOutDir %&% "EdFx_by_Demo_for_" %&% e %&% "_" %&% s %&% ".png", res = 600, width = myWidth, height = myHeight)
    fxPlot <- ggplot(data = p, aes(x=xLab, y=b), fill=xLab) +
      geom_bar(stat="identity", position="dodge", colour="blue", fill="blue") +
      geom_errorbar(aes(ymin=ll, ymax=ul), width=.1, position=pd) +
      ggtitle("Effect of " %&% Inds_l[s] %&% " on\n" %&% AllEds_l[e]) +
      theme(axis.text.x = element_text(size = rel(0.75)), axis.title.x=element_blank(), axis.title.y=element_blank())
    
    print(fxPlot)
    dev.off()
    
  } # End of loop across (e)ducation outcomes
  
  
  #-----------------------------------------------
  # Compare effects across outcomes by demographic
  #-----------------------------------------------
  
  for (g in AllGenders) {
    for (r in AllRaces) {
      p <- myOut[myOut$Spec == s & myOut$x == s & myOut$Gender == g & myOut$Race == r,]
      xLab <- factor(AllEds_l[as.character(p$Ed)])
      xLab <- factor(xLab, levels=xLab)
      
      png(file = myOutDir %&% "EdFx_by_Ed_for_" %&% g %&% "_" %&% r %&% "_" %&% s %&% ".png", res = 600, width = myWidth, height = myHeight)
      fxPlot <- ggplot(data = p, aes(x=xLab, y=b), fill=xLab) +
        geom_bar(stat="identity", position="dodge", colour="blue", fill="blue") +
        geom_errorbar(aes(ymin=ll, ymax=ul), width=.1, position=pd) +
        ggtitle("Effect of " %&% Inds_l[s] %&% " on Ed Rates\n" %&% "Gender - " %&% g %&% ", Race - " %&% r) +
        theme(axis.text.x = element_text(size = rel(0.9)), axis.title.x=element_blank(), axis.title.y=element_blank())
      
      print(fxPlot)
      dev.off()
      
    } # End of loop across (r)aces
    
  } # End of loop across (g)enders
  
} # End of loop across (s)pecifications


# XXX Other to-do: table constructions for marginal & total effect, R^2 (for given outcome, across groups) ... 

