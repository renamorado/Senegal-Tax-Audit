

library(haven)
library(data.table)
library(plyr)
library(dplyr)
library(ggplot2)
library(randomForest)
library(stringr)
library(xtable)
library(tibble)
library(tidyr)
library(kableExtra)
library(sf)
library(collapse)
library(tidyverse)
library(caret)

detach("package:plyr", unload = TRUE)

setwd("C:/Users/wb648862/Dropbox/Senegal tax audits/Analysis all data/replication_package") #Change working directory
#setwd("C:/Users/49354415/Dropbox/Trabalho/2017 WB/Senegal tax audits/Analysis all data/replication_package")

# Define paths
output_path <- "C:/Users/wb648862/OneDrive - WBG/Documents/GitHub/Senegal-Tax-Audit/Output/"
data_path <- "Working Data/"
r_code_path <- "Code Analyse data/Replication R/"

source(paste0(r_code_path, "01_Prediction_Quality_Test.R"))
source(paste0(r_code_path, "01_Tuning.R"))
source(paste0(r_code_path, "03_Run_RF.R"))
source(paste0(r_code_path, "04_Compare_Predicted_vs_Realized.R"))
source(paste0(r_code_path, "06_Compare_Algorithm_vs_Inspector.R"))
source(paste0(r_code_path, "06_Compare_Algorithm_vs_Inspector_Desk.R"))
source(paste0(r_code_path, "07_Optimization_Exercise.R"))

