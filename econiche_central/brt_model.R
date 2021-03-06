jobnum <- commandArgs()[3]
repo <-  commandArgs()[4]
outpath <- commandArgs()[5]
data_loc <- commandArgs()[6]
run_date <-  commandArgs()[7]
package_lib <- commandArgs()[8]

## Load libraries
setwd(repo)

# Library for packages. Ensures that none of this code is dependent on the machine where the user runs the code.
.libPaths(package_lib)# Ensures packages look for dependencies here when called with library().

# Load packages
package_list <- c('car', 'MASS', 'stringr', 'reshape2', 'ggplot2', 'plyr', 'dplyr', 'rgeos', 'data.table','raster','rgdal', 'seegSDM','sp')
for(package in package_list) {
  library(package, lib.loc = package_lib, character.only=TRUE)
}

# Load functions files
source(paste0(repo, '/econiche_central/functions.R'))                   

#########################################################################################
covs <- brick(paste0(data_loc, "/covariates/schisto_covs.grd"))

# create a list with random permutations of dat_all, 
# This is like k-folds stuff in mbg; subsample custom function
dat_all <- read.csv((paste0(data_loc, "/dat_all.csv"))) 

# Set the RNG seed
set.seed(jobnum) #change/omit

data_sample <- subsample(dat_all,
                          n = 500, #random choice
                          minimum = c(30, 30)) #half of actual data points; changed from 30,30
                          #simplify = FALSE)

model <- runBRT(data_sample,
          gbm.x = 4:ncol(data_sample),
          gbm.y = 1,
          pred.raster = covs, #brick
          gbm.coords = 2:3,
          wt = function(PA) ifelse(PA == 1, 1, sum(PA) / sum(1 - PA)))

stats <- getStats(model)

# Output model results
write.csv(model, file = paste0(outpath, "/model_", run_date, jobnum,".csv"))
write.csv(model, file = paste0(outpath, "/stats_", run_date, jobnum,".csv"))



