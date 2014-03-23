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

  
  #----------------------------------
  #----------------------------------
  ### Create Decade Cohort Aggregates
  #----------------------------------
  #----------------------------------
  
  ## Identify each cohort by decade
  
  for (d in seq(1930, 2010, by=10)) {
    cond <- d <= cps$cohort & cps$cohort <= d+9
    print( as.character(d) %&% "s")
    
    cps[,"cohort"%&% as.character(d) %&% "s"] <- 1*cond
    print(unique(cps$cohort[cond]))
    cps$cohort_d[cond] <- as.character(d) %&% "s"
  }
  
  # Creating weighted averages in R isn't fully intuitive. Some notes:
  comment("
      # see the method described here: http://r.789695.n4.nabble.com/Weighted-Average-on-More-than-One-Variable-in-Data-Frame-td3830922.html
      ... they suggest using this -- sapply(split(df, df$g), function(x) apply(x[, 1:2], 2, weighted.mean, x$w)) 
      ... Trying the following since apply() works, and since I need two dimensions of group definition ... aggregate(cps, list(cohort, Gender), function(x) apply(x[, descVars], 2, weighted.mean, x$wt)) ... but get an 'incorrect number of dimensions' error
      
      a <- sapply(split(cps, interaction(cohort, Gender)), function(x) apply(x[, descVars], 2, weighted.mean, x$wt))
      .... This works, but have to deal with the fact that it has a left-over 
      .... would be easier with aggregate() if possible
      
      Another potential, using ddply: http://stackoverflow.com/questions/3367190/aggregate-and-weighted-mean-in-r/3367306#3367306"
  )
  
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
  
  
  #---------------------------------------------------------
  ### Generate plots (of Ed, indicators, etc) by demographic
  #---------------------------------------------------------
  
    for (b in AllBys) {
      w <- ifelse(b == "year", "Wgt", "NoW")
      
      for (g in AllGenders) {
        for (r in AllRaces) {
          
          #--------------------------------------------
          ## Generate Plot Comparing Education Outcomes
          #--------------------------------------------
            d  <- cps[cps$By == b & cps$Weight == w & cps$Gender == g & cps$Race == r, c(b, AllEds, SomeSampleNs, "Race_" %&% Races)]
            dd <- melt(d, id=b)
            dd <- dd[!is.na(dd[,"value"]),]
            dd$myX <- dd[, b]
          
          #------------------
          ## Education Levels
          #------------------
            png(file = myOutDir %&% "CompareLvlEd_for_" %&% g %&% "_" %&% r %&% "_by_" %&% b %&% ".png", res = 600, width = myWidth, height = myHeight)
          
              if (b=="cohort") {xRestr <- dd$myX <= 1980 } else {xRestr <- dd$myX == dd$myX } # Avoid plotting cohorts after 1980, which do not have valid measures of HS or more. XXX Need to generalize this for when more years of data are available.
              useData <- dd[(dd$variable %in% AllLvlEds) & xRestr,]
              myPlot <- ggplot(data=useData, aes(x = myX, y = value, group = variable, color = variable)) + 
                labs(title = "Education Levels:\nRace - " %&% r %&% ", Gender - " %&% g, x = By_l[b], y = myYEdLab) +
                scale_colour_discrete(name = "", breaks = names(AllEds_l), labels = AllEds_l) +
                theme(plot.title = element_text(size = rel(titleRelSize)), legend.position = "bottom", legend.text = element_text(size = rel(legendRelSize)),
                  axis.title.x = element_text(size = rel(axisRelSize)), axis.title.y = element_text(size = rel(axisRelSize))) + 
                geom_line(size = lineSize)
              print(myPlot)
        
            dev.off()
          
          #----------------------
          ## Education Conditions
          #----------------------
            png(file = myOutDir %&% "CompareCondEd_for_" %&% g %&% "_" %&% r %&% "_by_" %&% b %&% ".png", res = 600, width = myWidth, height = myHeight)
            
              if (b=="cohort") {xRestr <- dd$myX <= 1980 } else { xRestr <- dd$myX == dd$myX }  # Avoid plotting cohorts after 1980, which do not have valid measures of HS or more. XXX Need to generalize this for when more years of data are available.
              useData <- dd[(dd$variable %in% AllCondEds) & xRestr,]
              myPlot <- ggplot(data=useData, aes(x = myX, y = value, group = variable, color = variable)) + 
                labs(title = "Conditional Educational Outcomes:\nRace - " %&% r %&% ", Gender - " %&% g, x = By_l[b], y = myYEdLab) +
                scale_colour_discrete(name = "", breaks = names(AllEds_l), labels = AllEds_l) +
                theme(plot.title = element_text(size = rel(titleRelSize)), legend.position = "bottom", legend.text = element_text(size = rel(legendRelSize)),
                      axis.title.x = element_text(size = rel(axisRelSize)), axis.title.y = element_text(size = rel(axisRelSize))) + 
                geom_line(size = lineSize)
              print(myPlot)
            
            dev.off()
          
            #----------------
            ## Some Sample Ns
            #----------------
            if (b == "cohort" & r == "All" & g == "All") {
              png(file = myOutDir %&% "SampleNs_for_" %&% g %&% "_" %&% r %&% "_by_" %&% b %&% ".png", res = 600, width = myWidth, height = myHeight)
              
                useData <- dd[dd$variable %in% SomeSampleNs,]
                myPlot <- ggplot(data=useData, aes(x = myX, y = value, group = variable, color = variable)) + 
                  labs(title = "Sample Ns for Selected Variables:\nRace - " %&% r %&% ", Gender - " %&% g, x = By_l[b], y = "Sample Ns") +
                  scale_colour_discrete(name = "", breaks = names(SomeSampleNs_l), labels = SomeSampleNs_l) +
                  theme(plot.title = element_text(size = rel(titleRelSize)), legend.position = "bottom",
                    legend.text = element_text(size = rel(legendRelSize)), 
                    axis.title.x = element_text(size = rel(axisRelSize)), axis.title.y = element_text(size = rel(axisRelSize))) + 
                  geom_line(size = lineSize) + guides(colour = guide_legend(nrow = 1))
              
                print(myPlot)
              
              dev.off()
            } # End of Sample Ns Graphs
              
              #------------------
              ## Race Composition
              #------------------
              if (r == "All" & g == "All") {
                png(file = myOutDir %&% "RaceComp_for_" %&% g %&% "_" %&% r %&% "_by_" %&% b %&% ".png", res = 600, width = myWidth, height = myHeight)
                
                  useData <- dd[dd$variable %in% c("Race_WhiteNonH", "Race_BlackNonH", "Race_Hisp"),]
                  myPlot <- ggplot(data=useData, aes(x = myX, y = value, group = variable, color = variable)) + 
                    labs(title = "Race/Ethnicity Composition by " %&% By_l[b], x = By_l[b], y = "% composition") +
                    scale_colour_discrete(name = "", breaks = "Race_" %&% Races, labels = Races) + # breaks = Races, 
                    theme(plot.title = element_text(size = rel(titleRelSize)), legend.position = "bottom",
                          legend.text = element_text(size = rel(legendRelSize)), 
                          axis.title.x = element_text(size = rel(axisRelSize)), axis.title.y = element_text(size = rel(axisRelSize))) + 
                    geom_line(size = lineSize) + guides(colour = guide_legend(nrow = 1))
                  print(myPlot)
                
                dev.off()
              } # End of Race Composition graphs
          
          
        } # End of loop across races
      } # End of loop sacross genders
    } # End of loop across "by"s
  
  #---------------------------------------------------------
  ### Compare genders on same plot (for Ed, indicators, etc)
  #---------------------------------------------------------
  
    genderRunVars <- c(AllLvlEds, AllCondEds, AllNewEds, Dems, Inds)
    genderRunVars_l <- c(AllEds_l[c(AllLvlEds, AllCondEds, AllNewEds)], Dems_l, Inds_l)
    names(genderRunVars_l) <- genderRunVars
    print("Running plots by Gender")
  
    for (b in AllBys) {
      w <- ifelse(b == "year", "Wgt", "NoW")
      
      for (r in AllRaces) {
        d  <- cps[cps$By == b & cps$Weight == w & cps$Race == r, c(b, "Gender", "Race", genderRunVars)]
        
        for (y in genderRunVars) {
          
          dd <- d[!is.na(d[, y]) & d[, "Gender"]!="All", ]
          dd$myX <- dd[, b]
          dd$myY <- dd[, y]
          # Avoid plotting cohorts after 1980, which do not have valid measures of HS or more. XXX Need to generalize this for when more years of data are available.
          if (y %in% AllEds & b == "cohort") { dd <- dd[dd$myX <= 1980, ] } 
          
          png(file = myOutDir %&% "CompareGender_for_" %&% y %&% "_" %&% r %&% "_by_" %&% b %&% ".png", res = 600, width = myWidth, height = myHeight)
          
            myPlot <- ggplot(data=dd, aes(x = myX, y = myY, group = Gender, color = Gender)) + 
              labs(title = "Comparing " %&% genderRunVars_l[y] %&% ":\nBy Gender, Race - " %&% r, x = By_l[b], y = genderRunVars_l[y]) +
              scale_colour_discrete(name = "") +
              theme(plot.title = element_text(size = rel(titleRelSize)), legend.position = "bottom", legend.text = element_text(size = rel(legendRelSize)),
                  axis.title.x = element_text(size = rel(axisRelSize)), axis.title.y = element_text(size = rel(axisRelSize))) + 
              geom_line(size = lineSize)
            
            print(myPlot)
          
          dev.off()
        } # End of loop across ed/indicator measures
      } # End of loop across genders
    } # End of loop across "by"s
  
  #---------------------------------------------------------
  ### Compare race/eth on one plot (for Ed, indicators, etc)
  #---------------------------------------------------------
  
    raceRunVars <- c(AllLvlEds, AllCondEds, AllNewEds, Dems, Inds)
    raceRunVars_l <- c(AllEds_l[c(AllLvlEds, AllCondEds, AllNewEds)], Dems_l, Inds_l)
    names(raceRunVars_l) <- raceRunVars
    print("Running plots by Race")
    
    for (b in AllBys) {
      w <- ifelse(b == "year", "Wgt", "NoW")
      
      for (g in AllGenders) {
        
        d  <- cps[cps$By == b & cps$Weight == w & cps$Gender == g, c(b, "Race", raceRunVars)]
        
        for (y in raceRunVars) {
          
          dd <- d[!is.na(d[, y]) & d[, "Race"]!="All", ]
          dd$myX <- dd[, b]
          dd$myY <- dd[, y]
          # Avoid plotting cohorts after 1980, which do not have valid measures of HS or more. XXX Need to generalize this for when more years of data are available.
          if (y %in% AllEds & b == "cohort") { dd <- dd[dd$myX <= 1980,] } 
          
          png(file = myOutDir %&% "CompareRace_for_" %&% y %&% "_" %&% g %&% "_by_" %&% b %&% ".png", res = 600, width = myWidth, height = myHeight)
          
            myPlot <- ggplot(data=dd, aes(x = myX, y = myY, group = Race, color = Race)) + 
              labs(title = "Comparing " %&% raceRunVars_l[y] %&% ":\nBy Race, Gender - " %&% g, x = By_l[b], y = raceRunVars_l[y]) +
              scale_colour_discrete(name = "", breaks = AllRaces) +
              theme(plot.title = element_text(size = rel(titleRelSize)), legend.position = "bottom", legend.text = element_text(size = rel(legendRelSize)),
                axis.title.x = element_text(size = rel(axisRelSize)), axis.title.y = element_text(size = rel(axisRelSize))) + 
              geom_line(size = lineSize)
          
          print(myPlot)
          
          dev.off()
        } # End of loop across races
      } # End of loop sacross genders
    } # End of loop across "by"s
  

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

  
#---------------------------------------
#---------------------------------------  
### (3) Generate counterfactual analysis
#---------------------------------------
#---------------------------------------
  
  #-----------------------------------------------------------------------------
  ### Project value estimates, using both observed and counterfactual predictors
  #-----------------------------------------------------------------------------
  
    # Talking it through --
      # Goal is table with cohorts in rows, new column with rates of college attainment.
      # Calculation is A*B*C where each of {A,B,C} is calculated as inner product of:
        # (1) own x with own b (which gets projections) ... this is its own column
        # (2) own x with another's b
        # (3) other's x with own b
  
  i <- 1
  for (s in SpecRuns) {
    preds <- c(standardX, s)
    for (g in AllGenders) {
      for (r in AllRaces) {
        
        cpsSub <- cps[cps$Gender == g & cps$Race == r & cps$Weight == "NoW" & !is.na(cps$cohort),]
        myX <- as.matrix(cpsSub[, preds])
        malesX  <- as.matrix(cps[cps$Gender == "Male" & cps$Race == r           & cps$Weight == "NoW" & !is.na(cps$cohort), preds])
        whitesX <- as.matrix(cps[cps$Gender == g      & cps$Race == "WhiteNonH" & cps$Weight == "NoW" & !is.na(cps$cohort), preds])
        
        PredOut <- data.frame(cpsSub[, c("cohort", "Ed_Coll")]); rownames(PredOut) <- NULL; colnames(PredOut) <- c("cohort", "Ed_Coll")
        PredOut$Race <- r; PredOut$Gender <- g; PredOut$Spec <- s
        
        for (e in AllCondEds) {
          
          PredOut[, e] <- cpsSub[, e]
          
          myB     <- myOut[myOut$Spec == s & myOut$Gender == g      & myOut$Race == r           & myOut$Ed == e, c("x", "b", "se")] 
          malesB  <- myOut[myOut$Spec == s & myOut$Gender == "Male" & myOut$Race == r           & myOut$Ed == e, c("x", "b", "se")]
          whitesB <- myOut[myOut$Spec == s & myOut$Gender == g      & myOut$Race == "WhiteNonH" & myOut$Ed == e, c("x", "b", "se")]
          
          rownames(myB)     <- myB$x
          rownames(malesB)  <- malesB$x
          rownames(whitesB) <- whitesB$x
  
          # Project estimated values
          hat <- cbind(myX %*% as.matrix(myB[preds, "b"]))
          PredOut[, e %&% "_MyX_MyB"] <- hat
          
          hat <- cbind(malesX %*% as.matrix(myB[preds, "b"]))
          PredOut[, e %&% "_MalesX_MyB"] <- hat
          hat <- cbind(myX %*% as.matrix(malesB[preds, "b"]))
          PredOut[, e %&% "_MyX_MalesB"] <- hat
          
          hat <- cbind(whitesX %*% as.matrix(myB[preds, "b"]))
          PredOut[, e %&% "_WhitesX_MyB"] <- hat
          hat <- cbind(myX %*% as.matrix(whitesB[preds, "b"]))
          PredOut[, e %&% "_MyX_WhitesB"] <- hat
          
          # XXX Need to project estimates of standard errors using the bootstrap
          
          
        } # End of loop across (e)ducation
    
        for (cf in c("MyX_MyB", "MalesX_MyB", "MyX_MalesB", "WhitesX_MyB", "MyX_WhitesB")) {
          PredOut[, "Ed_Coll_" %&% cf] <- PredOut[, "Ed_Hs_Ged_" %&% cf] * PredOut[, "Ed_SomeCollIf_" %&% cf] * PredOut[, "Ed_CollIf_" %&% cf]
        }
        
        # Save output
        if (i==1) {
          myPredOut <- PredOut
        } else {
          myPredOut <- rbind(myPredOut, PredOut)
        }
        
        i <- i + 1
        
      } # End of loop across (r)aces
    } # End of loop across (g)enders
  } # End of loop across (s)pecifications

  
  #----------------------------------------------------------------
  ### Graph projections with observed and counterfactual predictors
  #----------------------------------------------------------------
  
  for (s in SpecRuns) {
    
    #--------------------------#
    ### Graphs across gender ###
    #--------------------------#
    
      p <- myPredOut[myPredOut$Race == "All" & myPredOut$Gender != "All" & myPredOut$Spec == s, 
                     c("cohort", "Gender", "Ed_Coll", "Ed_Coll_MyX_MyB", "Ed_Coll_MalesX_MyB", "Ed_Coll_MyX_MalesB")]
      mp <- melt(p, id=c("cohort", "Gender"))
      mp$Gender <- factor(p$Gender)
      xLab <- factor(xLab, levels=xLab)
      
      ### MyX, MyB ###
      useData <- mp[mp$variable %in% c("Ed_Coll", "Ed_Coll_MyX_MyB"), ]
      png(file = myOutDir %&% "ProjColl_by_Gender_" %&% s %&% "_MyX_MyB.png", res = 600, width = 2400, height = 2100)
      
        myPlot <- ggplot(data = useData, aes(x = cohort, y = value)) +
          labs(title = "College Projection by Gender", x = "Cohort", y = "Rate of College Attainment") +
          geom_line(aes(linetype = variable, color = Gender), size = 0.6) +
          scale_linetype_discrete(name = "", labels = c("Obs Rate", "Pred Rate")) + scale_colour_discrete(name = "") +
          theme(plot.title = element_text(size = rel(titleRelSize)), legend.position = "bottom",
              legend.text = element_text(size = rel(legendRelSize)), 
              axis.title.x = element_text(size = rel(axisRelSize)), axis.title.y = element_text(size = rel(axisRelSize)))
        print(myPlot)
      
      dev.off()
      
      # MalesX, MyB
      useData <- mp[mp$variable %in% c("Ed_Coll", "Ed_Coll_MalesX_MyB"), ]
      png(file = myOutDir %&% "ProjColl_by_Gender_" %&% s %&% "_MalesX_MyB.png", res = 600, width = 2400, height = 2100)
      
        myPlot <- ggplot(data = useData, aes(x = cohort, y = value)) +  #, group = Gender, color = variable
          labs(title = "College Counterfactual by Gender:\nUsing Males' x's", x = "Cohort", y = "Rate of College Attainment") +
          geom_line(aes(linetype = variable, color = Gender), size = 0.6) + 
          scale_linetype_discrete(name = "", labels = c("Obs Rate", "Pred w/Male x's")) + scale_colour_discrete(name = "") +
          theme(plot.title = element_text(size = rel(titleRelSize)), legend.position = "bottom",
                legend.text = element_text(size = rel(legendRelSize)), 
                axis.title.x = element_text(size = rel(axisRelSize)), axis.title.y = element_text(size = rel(axisRelSize)))
        print(myPlot)
      
      dev.off()
      
      # MyX, MalesB
      useData <- mp[mp$variable %in% c("Ed_Coll", "Ed_Coll_MyX_MalesB"), ]
      png(file = myOutDir %&% "ProjColl_by_Gender_" %&% s %&% "_MyX_MalesB.png", res = 600, width = 2400, height = 2100)
      
        myPlot <- ggplot(data = useData, aes(x = cohort, y = value)) +  #, group = Gender, color = variable
          labs(title = "College Counterfactual by Gender:\nUsing Males' betas's", x = "Cohort", y = "Rate of College Attainment") +
          geom_line(aes(linetype = variable, color = Gender), size = 0.6) + 
          scale_linetype_discrete(name = "", labels = c("Obs Rate", "Pred w/Male betas's")) + scale_colour_discrete(name = "") +
          theme(plot.title = element_text(size = rel(titleRelSize)), legend.position = "bottom",
                legend.text = element_text(size = rel(legendRelSize)), 
                axis.title.x = element_text(size = rel(axisRelSize)), axis.title.y = element_text(size = rel(axisRelSize)))
        print(myPlot)
      
      dev.off()
      
    #------------------------#
    ### Graphs across race ###
    #------------------------#
      
      for (g in AllGenders) {
        
        p <- myPredOut[myPredOut$Race != "All" & myPredOut$Gender == g & myPredOut$Spec == s, 
                       c("cohort", "Gender", "Race", "Ed_Coll", "Ed_Coll_MyX_MyB", "Ed_Coll_WhitesX_MyB", "Ed_Coll_MyX_WhitesB")]
        mp <- melt(p, id=c("cohort", "Gender", "Race"))
      
        ### MyX, MyB ###
        useData <- mp[mp$variable %in% c("Ed_Coll", "Ed_Coll_MyX_MyB"), ]
        png(file = myOutDir %&% "ProjColl_by_Race" %&% "_" %&% g %&% "_" %&% s %&% "_MyX_MyB.png", res = 600, width = 2400, height = 2100)
        
          myPlot <- ggplot(data = useData, aes(x = cohort, y = value)) +
            labs(title = "College Projection by Race:\nGender - " %&% g, x = "Cohort", y = "Rate of College Attainment") +
            geom_line(aes(linetype = variable, color = Race), size = 0.6) +
            scale_linetype_discrete(name = "", labels = c("Obs Rate", "Pred Rate")) + scale_colour_discrete(name = "") +
            theme(plot.title = element_text(size = rel(titleRelSize)), legend.position = "bottom",
                  legend.text = element_text(size = rel(legendRelSize)), 
                  axis.title.x = element_text(size = rel(axisRelSize)), axis.title.y = element_text(size = rel(axisRelSize)))
          print(myPlot)
        
        dev.off()
        
        ### WhitesX, MyB ###
        useData <- mp[mp$variable %in% c("Ed_Coll", "Ed_Coll_WhitesX_MyB"), ]
        png(file = myOutDir %&% "ProjColl_by_Race" %&% "_" %&% g %&% "_" %&% s %&% "_WhitesX_MyB.png", res = 600, width = 2400, height = 2100)
        
          myPlot <- ggplot(data = useData, aes(x = cohort, y = value)) +
            labs(title = "College Counterfactual by Race:\nGender - " %&% g, x = "Cohort", y = "Rate of College Attainment") +
            geom_line(aes(linetype = variable, color = Race), size = 0.6) +
            scale_linetype_discrete(name = "", labels = c("Obs Rate", "Whites' x's")) + scale_colour_discrete(name = "") +
            theme(plot.title = element_text(size = rel(titleRelSize)), legend.position = "bottom",
                  legend.text = element_text(size = rel(legendRelSize)), 
                  axis.title.x = element_text(size = rel(axisRelSize)), axis.title.y = element_text(size = rel(axisRelSize)))
          print(myPlot)
        
        dev.off()
        
        ### MyX, WhitesB ###
        useData <- mp[mp$variable %in% c("Ed_Coll", "Ed_Coll_MyX_WhitesB"), ]
        png(file = myOutDir %&% "ProjColl_by_Race" %&% "_" %&% g %&% "_" %&% s %&% "_MyX_WhitesB.png", res = 600, width = 2400, height = 2100)
        
          myPlot <- ggplot(data = useData, aes(x = cohort, y = value)) +
            labs(title = "College Counterfactual by Race:\nGender - " %&% g, x = "Cohort", y = "Rate of College Attainment") +
            geom_line(aes(linetype = variable, color = Race), size = 0.6) +
            scale_linetype_discrete(name = "", labels = c("Obs Rate", "Whites' beta's")) + scale_colour_discrete(name = "") +
            theme(plot.title = element_text(size = rel(titleRelSize)), legend.position = "bottom",
                  legend.text = element_text(size = rel(legendRelSize)), 
                  axis.title.x = element_text(size = rel(axisRelSize)), axis.title.y = element_text(size = rel(axisRelSize)))
          print(myPlot)
          
        dev.off()
        
      } # End of loop across (g)enders
  } # End of loop across (s)pecifications
  
  
  # d. Vary total outcome based on changing weights of each group
    # Can do this by presuming 2011 composition holds
    # "group" graphs by linetype for whether it is observed or constructed
    
  # f. Calculate the value of given social indicator that is predicted to obtain 60%
  
  
