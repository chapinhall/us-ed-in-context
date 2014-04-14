## Introduction

This repository is an online archive of electronic materials related to the "Social Indicators for Post-Secondary Attainment" report prepared by Chapin Hall at the University of Chicago, with funding support by the Lumina Foundation. This project undertook development of Current Population Survey (CPS) data (harmonized, documented distributed by the Unicon Research Corporation) to calculate trends in early-life social exposures and later-life educational attainment for each of a wide range of birth cohorts in the United States.

This repository has been created for the sake of transparency and replicability of this work, as well as to enable potential collaborators to make use of and expand on this code base for updated or new projects.

While the methods, programming files, and spreadsheet files are made openly available by the authors of the report, the source data and documentation from the Unicon Research Corporation are not licensed for open distribution. See the license below for attribution of this source, and follow [this link](https://www.unicon.com/cps.html) to purchase data from Unicon which would allow for full replication of this project. Also see the issue tracker for this repository which lists development of the [Integrated Public Use Microdata Series (IPUMS)](https://cps.ipums.org/cps/) distribution of October supplement CPS data to make all materials for this project fully freely available. 

## Contents

This repository represents files used to:

1. Merge, clean, and construct measures within the CPS data, written in SAS and found [here](https://github.com/chapinhall/us-ed-in-context/tree/master/code/data-prep)
2. Generate reports and statistical analyses of CPS data summarized by birth cohorts, written in R and found [here](https://github.com/chapinhall/us-ed-in-context/tree/master/code/data-analysis)
3. Generate dynamic tables displaying the range of analyses performed, in Excel using form inputs and Visual Basic scripts, found in the "master-tables.xlsm" file in the root directory above, which can be downloaded by clicking on the filename, then right-clicking on the "Raw" button, and selecting "Save link as..."
4. Create a web application to allow users to find specific results on demand, written in R using the [Shiny package](http://www.rstudio.com/shiny/) found [here](https://github.com/chapinhall/us-ed-in-context/tree/master/code/shiny-app)

The web application for this project, which is currently in beta, can be found [here](http://nsmader.shinyapps.io/Historical-US-Ed).

## Downloading

Perhaps the easiest way to download these files and join the project as a contributor is to download Git for your computer, and to clone the full repository. Many helpful links--including [this one](http://readwrite.com/2013/09/30/understanding-github-a-journey-for-beginners-part-1#awesm=~oBnDzXszeUWsJO)--turn up on Google searches for how to get started with Git. 

E-mail Nick Mader at nmader@chapinhall.org for instructions, question, help with this process, or simply to arrange a more familiar way to share files.

## Attribution for Data Source

CURRENT POPULATION SURVEYS, OCTOBER 1968-2011: SCHOOL ENROLLMENT [machine-readable data files]/conducted by the Bureau of the Census for the Bureau of Labor Statistics. Washington: Bureau of the Census [producer and distributor], 1968-2011. Los Angeles, CA: Unicon Research Corporation [producer and distributor of CPS Utilities], 2012.
