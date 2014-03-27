## This code takes cleaned Current Population Survey Data and produces 
## Exhibits of trends and indicators of post-secondary education across 
## years and birth cohorts of Americans

## Set up environment
  rm(list=ls())
  try(setwd("C:/Documents and Settings/nmader/My Documents/Google Drive/Lumina/Data and Documentation"))
  try(setwd("C:/Users/nmader/Google Drive/Lumina/Data and Documentation"))
  try(setwd("C:/Users/nmader/Documents/GitHub/us-ed-in-context/"))
  myOutDir <- "C:/Users/nmader/Google Drive/Lumina/Output/"
  
  "%&%" <- function(...){ paste(..., sep="") }
  comment <- function(...){}
  library("plyr")
  library("ggplot2")
  library("stats")
  library("reshape")
  
## Load data
  cps <- read.csv("./data/cps_cohort_summary.csv")  
  
  ### Generate conditional education categories.
  #     Note: se's are calculated using the Delta Method. See http://en.wikipedia.org/wiki/Delta_method for a general reference
    cps$Ed_SomeCollIf     <- cps$Ed_SomeColl / cps$Ed_Grad_Hs
    cps$Ed_SomeCollIf_se  <- sqrt( (cps$Ed_SomeColl^2 * cps$Ed_Grad_Hs_se^2) + (cps$Ed_Grad_Hs^2 * cps$Ed_SomeColl_se^2) )
    # Note: the same calculations could, of course, be made conditional on the Ed_Combined_Hs variable. We have chosen the Ed_Grad_Hs
    # variable here since it has a cleaner, more singular interpretation.
  
    # Check on the constructions 
    #x <- head(cps[, c("Ed_SomeColl", "Ed_Grad_Hs", "Ed_SomeCollIf_Grad_Hs", "Ed_SomeColl_se", "Ed_Grad_Hs_se", "Ed_SomeCollIf_Grad_Hs_se")])
    #write.csv(x, file="./data/check_delta_method.csv")
    #rm(x)
  
    #cps$Ed_2YrCollIf  <- cps$Ed_2YrColl / cps$Ed_SomeColl
    #cps$Ed_4YrCollIf  <- cps$Ed_4YrColl / cps$Ed_SomeColl
    cps$Ed_CollIf     <- cps$Ed_Coll    / cps$Ed_SomeColl
    cps$Ed_CollIf_se <- sqrt( (cps$Ed_Coll^2 * cps$Ed_SomeColl_se^2) + (cps$Ed_SomeColl^2 * cps$Ed_Coll_se^2) )
  
  ### Rescale household income
    cps$FamilyInc_Defl     <- cps$FamilyInc_Defl     / 10000
    cps$FamilyInc_Defl_Avg <- cps$FamilyInc_Defl_Avg / 10000
    cps$FamilyInc_Defl_Max <- cps$FamilyInc_Defl_Max / 10000

  
  ### Reorder the columns in data for easier browsing
    cpsColnames <- colnames(cps)
    idVars <- c("By", "cohort", "year", "Gender", "Race", "Weight")
    nonIdVars <- cpsColnames[which(!(cpsColnames %in% idVars))]
    cps <- cbind(cps[, idVars], cps[, nonIdVars[order(nonIdVars)]])
  
  #----------------------------------
  #----------------------------------
  ### Create Decade Cohort Aggregates
  #----------------------------------
  #----------------------------------
  
  ## Identify each cohort by decade
  
  for (d in seq(1930, 2010, by=10)) {
    cond <- d <= cps$cohort & cps$cohort <= d+9
    print( as.character(d) %&% "s")
    
    cps[, "cohort"%&% as.character(d) %&% "s"] <- 1*cond
    print(unique(cps$cohort[cond]))
    cps$cohort_d[cond] <- as.character(d) %&% "s"
  }
  
source("./code/data-analysis/var-groups-and-labels.r")
write.csv(cps, file = "./data/cps_cohort_summary_prepped.csv")
  
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
            png(file = paste("./output/CompareLvlEd_for", g, r, "by", b, sep="_") %&% ".png", res = 600, width = myWidth, height = myHeight)
          
              if (b=="cohort") {xRestr <- 1940 <= dd$myX & dd$myX <= 1990 } else {xRestr <- dd$myX == dd$myX }
              useData <- dd[(dd$variable %in% AllLvlEds) & xRestr,]
              myPlot <- ggplot(data=useData, aes(x = myX, y = value, group = variable, color = variable)) + 
                labs(title = "Education Levels:\nRace - " %&% r %&% ", Gender - " %&% g, x = By_l[b], y = myYEdLab) +
                scale_colour_discrete(name = "", breaks = names(AllEds_l), labels = AllEds_l) +
                theme(plot.title = element_text(size = rel(titleRelSize)), legend.position = "bottom", legend.text = element_text(size = rel(legendRelSize)),
                  axis.title.x = element_text(size = rel(axisRelSize)), axis.title.y = element_text(size = rel(axisRelSize))) + 
                geom_line(size = lineSize)
              print(myPlot)
        
            dev.off()
          
          #------------------------
          ## Education Conditionals
          #------------------------
            png(file = paste("./output/CompareCondEd_for", g, r, "by", b, sep="_") %&% ".png", res = 600, width = myWidth, height = myHeight)
            
              if (b=="cohort") {xRestr <- 1940 <= dd$myX & dd$myX <= 1990 } else { xRestr <- dd$myX == dd$myX }
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
              png(file = paste("./output/SampleNs_for", g, r, "by", b, sep="_") %&% ".png", res = 600, width = myWidth, height = myHeight)
              
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
                png(file = paste("./output/RaceComp_for", g, r, "by", b, sep = "_") %&% ".png", res = 600, width = myWidth, height = myHeight)
                
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
  
    genderRunVars <- c(AllLvlEds, AllCondEds, Dems, Inds)
    genderRunVars_l <- c(AllEds_l[c(AllLvlEds, AllCondEds)], Dems_l, Inds_l)
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
          
          if (y %in% AllEds & b=="cohort") {xRestr <- 1940 <= dd$myX & dd$myX <= 1990 } else { xRestr <- dd$myX == dd$myX }
          useData <- dd[xRestr, ]
          
          png(file = paste("./output/CompareGender_for", y, r, "by", b, sep = "_") %&% ".png", res = 600, width = myWidth, height = myHeight)
          
            myPlot <- ggplot(data=useData, aes(x = myX, y = myY, group = Gender, color = Gender)) + 
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
  
    raceRunVars <- c(AllLvlEds, AllCondEds, Dems, Inds)
    raceRunVars_l <- c(AllEds_l[c(AllLvlEds, AllCondEds)], Dems_l, Inds_l)
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
          
          if (y %in% AllEds & b=="cohort") {xRestr <- 1940 <= dd$myX & dd$myX <= 1990 } else { xRestr <- dd$myX == dd$myX }
          useData <- dd[xRestr, ]
          
          png(file = paste("./output/CompareRace_for", y, g, "by", b, sep="_") %&% ".png", res = 600, width = myWidth, height = myHeight)
          
            myPlot <- ggplot(data=useData, aes(x = myX, y = myY, group = Race, color = Race)) + 
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
  
