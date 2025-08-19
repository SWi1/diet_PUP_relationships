# Find RDS Files from a directory
# Stephanie Wilson

## This script scans a working directory for all RDS file and compiles their path information. 
#\ts model performance metrics values and other essential data from each of the RDS files

## Inputs 
### Directory

## Outputs
### Vector of character strings containing path names

# Function to find all 'feature_summary.csv' files 
# in a directory (including subdirectories)

find_rds_files = function(directory) {
  files = list.files(path = directory, pattern = "ML_r_workspace\\.rds$", 
                     full.names = TRUE, recursive = FALSE)
  subdirs = list.dirs(path = directory, full.names = TRUE, recursive = FALSE)
  for (subdir in subdirs) {
    files = c(files, find_rds_files(subdir))}
  
  return(files)}
