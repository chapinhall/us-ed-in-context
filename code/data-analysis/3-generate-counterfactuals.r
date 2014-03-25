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

