## This code takes cleaned Current Population Survey Data and produces 
## Exhibits of trends and indicators of post-secondary education across 
## years and birth cohorts of Americans

## Set up environment
  rm(list=ls()) # Removes all objects from the environment
  #setwd("/home/nsmader/Historical-US-Ed")
  
  "%&%" <- function(...){ paste(..., sep="") }
  comment <- function(...){}
  library("shiny")
  library("plyr")
  library("ggplot2")
  library("stats")
  library("reshape")
  
## Load data
  cps <- read.csv("./cps_cohort_summary_prepped.csv")
  #myPredOut <- read.csv("./Counterfactual_Analyses.csv")
  
  #---------------------------------------------
  #---------------------------------------------
  ## (0) Generate labels and groups of variables
  #---------------------------------------------
  #---------------------------------------------

  # XXX Can all of this be replaced with ui-side code?
  
  Genders <- c("Male", "Female")
  Races <- c("WhiteNonH", "BlackNonH", "Hisp")
  AllBys         <- c("cohort", "year") # 
  AllGenders     <- c("All", Genders)
  AllRaces       <- c("All", Races)
  
  AllEds         <- c("Completed_Hs", "Ed_Grad_Hs",   "Ed_Grad_Hs_Dip", "Ed_Grad_Hs_Ged",   "Ed_SomeColl",  "Ed_SomeCollIf",    "Ed_Coll", "Ed_CollIf",      "Ed_2YrColl", "Ed_2YrCollIf", "Ed_4YrColl", "Ed_4YrCollIf")
  AllHsEds       <- c("Completed_Hs", "Ed_Grad_Hs_Dip", "Ed_Grad_Hs_Ged")
  AllLvlEds      <- c("Completed_Hs", "Ed_SomeColl",   "Ed_Coll")
  AllCondEds     <- c("Completed_Hs", "Ed_SomeCollIf", "Ed_CollIf")
  AllNewEds      <- c("Ed_Grad_Hs_Dip", "Ed_Grad_Hs_Ged")
  AllYrColl      <- c("Ed_2YrColl",   "Ed_4YrColl",   "Ed_Coll")
  AllCondYrColl  <- c("Ed_2YrCollIf", "Ed_4YrCollIf", "Ed_CollIf")
  
  AllEds_l        <- c("HS/GED or 12 Years Sch",  "HS/GED",  "HS Only", "GED Only", "Some College", "Some Coll If HS",  "College", "Compl. Coll. If Attend", "2Yr Coll",   "2Yr Compl. Coll. If Attend", "4Yr Coll",   "4Yr Compl. Coll. If Attend")
  names(AllEds_l) <- AllEds
  By_l        <- c("Cohort of Birth", "Year of Survey")
  names(By_l) <- c("cohort",          "year")
  
  Dems <- c("Gender_Male", "Gender_Female", "Race_WhiteNonH", "Race_BlackNonH", "Race_Hisp")
  Dems_l <- c("Males", "Females", "White Non-Hisp", "Black Non-Hisp", "Hispanic")
  names(Dems_l) <- Dems
  
  Inds <- c("RaisedWith2Adults", "FemEd_LtHs_avg", "FemEd_Hs_Ged_avg", "FemEd_Coll_avg", "FamilyInc_Defl", "FamilyInc_Defl_Avg")
  Inds_l <- c("Raised w/2 Adults", "Mom's Ed < HS", "Mom's Ed >= \nHS or GED", "Mom's Ed >= Coll", "Family Inc, $10ks", "Family Avg Inc, $10ks")
  names(Inds_l) <- Inds
  
  SomeSampleNs <- c("RaisedWith2Adults_N", "Completed_Hs_N", "Ed_Grad_Hs") # "Ed_Coll_N"
  SomeSampleNs_l <- c("Raised w/2 Adults", "Ed = HS/GED or 12 Years Sch", "Ed = HS/GED") #"Ed = Coll"
  names(SomeSampleNs_l) <- SomeSampleNs
  
  
  #-----------------------------
  #-----------------------------
  ## (1) Generate trend analysis
  #-----------------------------
  #-----------------------------
  
    # Want to build: compare gender, or compare race, for given variable ... could be education, or many other things
  
    # Another possibility: allow users to check boxes for variables that they want to view
  
    # DemoComparison \in {CompareGender, CompareRace}
      # Conditional on "CompareRace"   -- g as an option selected from labels to "AllGenders"
      # Conditional on "CompareGender" -- r as an option selected from labels to "AllRaces"

  # Separate tab--Sample N's for a list of variables
  
  # Option to generate comparisons of given outcome--educational or social--data series by gender
  # Option to generate comparisons of given outcome--educational or social--data series by race
  # Perhaps a left/right set of views so that users can compare different views of the data

#------------------------------#
#------------------------------#
# GENERATE SHINY SERVER SCRIPT #
#------------------------------#
#------------------------------#
  
# For troubleshooting, outside of deploying app, can run the following in lieu of getting input from the app: 
#    input <- list(b="cohort", e = AllCondEds, g = "All", r = "All", stringsAsFactors = F); w <- "NoW"
  #  
  
shinyServer(function(input, output){
  
  w <- reactive({
    ifelse(input$b == "year", "Wgt", "NoW")
  })  
  
  ## XXX May make more sense to do this transformation ahead of time
  useData <- reactive({
    d <- cps[cps$By == input$b & cps$Gender == input$g & cps$Race == input$r & cps$Weight == w(), c(input$b, get(input$e), SomeSampleNs, "Race_" %&% Races)]
    dd <- melt(d, id=input$b)
    dd <- dd[!is.na(dd[,"value"]),]
    
    dd$myX <- dd[, input$b]
    if (input$b == "cohort") { xRestr <- dd$myX <= 1980 } else { xRestr <- (dd$myX == dd$myX) }  
      # Avoid plotting cohorts after 1980, which do not have valid measures of HS or more. XXX Need to generalize this for 
      # when more years of data are available.
    dd[dd$variable %in% get(input$e) & xRestr, ]
  })
  
  #-------------------##
  ##    SET OUTPUTS   ##
  #-------------------##
  
  output$view <- renderTable({
    cbind(head(useData(), n = 10))
  })
  
  output$edPlot <- renderPlot({
    myData <- useData()
     myPlot <- ggplot(data=myData, aes(x = myX, y = value, group = variable, color = variable)) + 
      labs(title = "Education Levels:\nRace - " %&% input$r %&% ", Gender - " %&% input$g, x = By_l[input$b], y = "Rate of Ed Attainment") +
      scale_colour_discrete(name = "", breaks = names(AllEds_l), labels = AllEds_l) +
      theme(plot.title = element_text(size = rel(2.0)), legend.position = "bottom", legend.text = element_text(size = rel(1.5)),
            axis.title.x = element_text(size = rel(1.5)), axis.title.y = element_text(size = rel(1.5)),
            axis.text.x  = element_text(size = rel(2.0)), axis.text.y  = element_text(size = rel(2.0))) + 
      geom_line(size = 1.5)
    print(myPlot) 
  })
  
  output$plotNote <- renderText("NOTE: All figures represent draft calculations, including some known errors. Do not cite.")
  
})
  
  
  