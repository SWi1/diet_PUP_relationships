# Extract Metric Data from dietML RDS Files

## This script pools performance metric output from multiple RDS files, 
## which are a key output file from the dietML program built by Dr. Andrew Oliver. 
## Each RDS file is a packaged R environment which contains numerous dataframes. 
  
## This script
### 1) Isolates the pathways for each of the RDS files created by one run of dietML and 
### 2) Iteratively extracts model performance metrics values and other essential data from each of the RDS files

## Inputs 
### list of RDS file paths from dietML output housed within a dataframe

## Outputs
### Large List where each list contains data from one model including
### Dataframe on models performance metrics including a model label


extract_performance = function(path, rds_info) {
  # Load the file (should define final_res and full_results)
  load(path)
  
  # Get seed from rds_info
  seed = rds_info[rds_info$path == path, "seed", drop = TRUE]
  
  # Prepare null model
  model_results = full_results %>%
    rename(metric = 1, 
           estimator = 2,
           estimate = 3,
           config = 4, 
           estimate_null = 5) %>%
    mutate(seed = seed)

  # Combine and return
  model_results
}
