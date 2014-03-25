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
  
source("./var-groups-and-labels.r")

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
          
          png(file = paste(myOutDir, "CompareGender_for", y, r, "by", b, sep = "_") %&% ".png", res = 600, width = myWidth, height = myHeight)
          
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
  
