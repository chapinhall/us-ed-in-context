## This code runs regression analysis associating social indicators with various educational outcomes,
## generates post-estimation aggregates calculations of those values, and generates exhibits
## of these values

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
cps <- read.csv("./data/cps_cohort_summary_prepped.csv")

source("./code/data-analysis/var-groups-and-labels.r")

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
  
  SpecRuns <- list(Adults=c("RaisedWith2Adults"), MomEd=c("FemEd_Coll_avg"), FamInc=c("FamilyInc_Defl_Avg"), PreK=c("AttendedPreK"))
  cps$one <- 1
  cps$cohort2 <- cps$cohort^2
  standardX <- c("one", "cohort", "cohort2")
  
  # Initialize the output 
  myOut <- data.frame(Spec = "init", x = "init", Ed = "init", Gender = "init", Race = "init", b = 0, se = 0, r2 = 0, ll = 0, ul = 0)
  
  # a. Run regressions of each education outcome on indicators, both overall and for each subdemographic
  for (s in SpecRuns) {
    for (e in AllCondEds) {
      
      ### Subset data
      # Avoid rows where education is invalid, equal to 0, or equal to 1
      validE <- !(is.na(cps[, e])) & (cps[, e] != 1) & (cps[, e] != 0)
      d <- cps[cps$Weight == "NoW" & !(is.na(cps$cohort)) & validE,
               c(e, s, standardX, "Gender", "Race", "cohort")]
      x <- "-1 + " %&% paste(c(standardX, s), collapse=" + ")
      
      # Set up loops across gender and race
      for (g in AllGenders) {
        for (r in AllRaces) {
          
          tag <- paste(c(e, g, r), collapse="_")
          dd <- d[d$Gender == g & d$Race == r, ]
          
          # Run regression
          reg <- summary(lm(as.formula(e %&% "~" %&% x), data=dd))
            # XXX when implementing WLS in the future, add: weights = dd[, e %&% "_n"]))
            # Would be interesting to compare OLS and WLS. Consider building a loop to compare
          
          # Compile output
          out <- data.frame(s, rownames(reg$coeff), e, g, r, reg$coeff[, c("Estimate", "Std. Error")], reg$adj.r.squared)
          colnames(out) <- c("Spec", "x", "Ed", "Gender", "Race", "b", "se", "r2")
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
  myOut <- within(myOut, id <- paste(Spec, x, Ed, Gender, Race, sep = "_"))
  write.csv(myOut, "./data/regression-output.csv")


#------------------------------------------------------------------------------------
### Generate compound marginal effect of given predictor on Ed, through full pathways
#------------------------------------------------------------------------------------
# Initialize output
myTotEff <- data.frame(Spec = "init", x = "init", Gender = "init", Race = "init", cohort = 0, b = 0, se = 0, ll = 0, ul = 0)

# Run loops -- XXX Can this wholly or largely be vectorized?
for (s in SpecRuns) {
  for (g in AllGenders) {
    for (r in AllRaces) {
      
      # XXX Will need to also loop across multiple predictors once (or if) they start getting used 
      outSub <- myOut[myOut$Spec == s & myOut$x == s & myOut$Gender == g & myOut$Race == r, c("b", "Ed")]
      dA <- outSub[outSub$Ed == "Ed_Grad_Hs",    "b"]
      dB <- outSub[outSub$Ed == "Ed_SomeCollIf", "b"]
      dC <- outSub[outSub$Ed == "Ed_CollIf",     "b"]
      
      cpsSub <- cps[cps$Gender == g & cps$Race == r & cps$Weight == "NoW" & !is.na(cps$cohort), c("cohort", AllCondEds)]
      A <- cpsSub[, "Ed_Grad_Hs"]
      B <- cpsSub[, "Ed_SomeCollIf"]
      C <- cpsSub[, "Ed_CollIf"]
      
      totEff <- (dA *  B *  C) + ( A * dB *  C) + ( A *  B * dC) +
                (dA * dB *  C) + (dA *  B * dC) + ( A * dB * dC) +
                (dA * dB * dC)
      
      out <- data.frame(Spec = s, x = s, Gender = g, Race = r, cohort = cpsSub$cohort, b = totEff, se = 0, ll = 0, ul = 0)
      
      myTotEff <- rbind(myTotEff, out)
      
      #----------------------
      ### Graph total effects
      #----------------------
      png(file = paste("./output/TotFx_of", s, "for", g, r, sep="_") %&% ".png", res = 600, width = myWidth, height = 1600)
      
      useData <- out
      myPlot <- ggplot(data=useData, aes(x = cohort, y = b)) + 
        labs(title = paste0("Total Effect of ", Inds_l[s], " on Coll. Compl.:\nGender - ", g, ", Race - ", r), x = By_l["cohort"], y = "Effect") +
        theme(plot.title = element_text(size = rel(titleRelSize)), 
              axis.title.x = element_text(size = rel(axisRelSize)), axis.title.y = element_text(size = rel(axisRelSize))) + 
        geom_line(size = lineSize, color = "purple")
      print(myPlot)
      
      dev.off()
      
    } # End of loop across (r)ace
  } # End of loop across (g)ender
} # End of loop across (s)pecifications

myTotEff <- within(myTotEff, id <- paste(Spec, x, Gender, Race, sep="_"))
write.csv(myTotEff, "./data/estimated-total-effects.csv")

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
    
    png(file = paste("./output/EdFx_by_Demo_for", e, s, sep="_") %&% ".png", res = 600, width = myWidth, height = myHeight)
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
      
      png(file = paste("./output/EdFx_by_Ed_for", g, r, s, sep="_") %&% ".png", res = 600, width = myWidth, height = myHeight)
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


# XXX Other to-do: table constructions for marginal & total effect

