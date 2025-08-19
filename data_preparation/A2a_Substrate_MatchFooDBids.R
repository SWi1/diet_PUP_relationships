### Linking dbPUP substrates to FooDB
### Stephanie Wilson
### September 2024

### SUMMARY
### For each polyphenol substrate linked to a PUP, this code provides a user
### prompt asking whether the compound was detected in FooDB, and if so, what
### it's compound id is. 

### This process utilized a manual search of 47 compounds as synonyms 
### make easy text matching difficult. Generally, the search strategy was:

### 1. FooDB was checked first with the compound name.  
### 2. Candidates without a direct match went through a synonym search.
### 3. If still not found, compound was searched in PubChem for InChI keys 
###   and synonyms, these were searched through FooDB for a match.
### 4. If still not found, the compound was declared NA.

### INPUT
### polyphenol_substrates_long.csv

### OUTPUT
### dbPUP_substrates_FooDB_IDs.csv - polyphenol substrates in FooDB

###########################################################
# Load data
# Load dbPUP substrate list
substrates = read.csv('dbPUP/polyphenol_substrates_long.csv')

# Get distinct polyphenol substrates
polyphenols = substrates %>% distinct(polyphenol)

### PROMPT NEEDS RUN ONCE
###########################################################
# Initialize columns for the responses and websites
polyphenols$decision <- NA  # Placeholder for "yes" or "no"
polyphenols$compound_code <- NA   # Placeholder for website input

# Loop through each polyphenol and prompt for input
for (i in 1:nrow(polyphenols)) {
  # Print the polyphenol name
  print(polyphenols$polyphenol[i])
  
  # Ask the user for a "yes" or "no" input
  response = readline(prompt = "Is this polyphenol in FooDB? Enter 'yes' or 'no': ")
  
  # Store the response in the dataframe
  polyphenols$decision[i] = response
  
  # If the response is "yes", prompt for the associated website
  if (response == "yes") {
    compound_code <- readline(prompt = "Enter the FooDB compound code: ")
    polyphenols$compound_code[i] <- compound_code  # Store the website in the dataframe
  }
}

# Separate the double entries
# no's shouldn't be pulling compound codes
polyphenols_cleaned = polyphenols %>%
  separate_rows(compound_code, sep = ",") %>%
  mutate(compound_code = ifelse(decision == 'no', NA, compound_code))

# BLOCKED OUT TO PREVENT OVERWRITING
###### ## write.csv(polyphenols_cleaned, 'data/dbPUP_substrates_FooDB_IDs.csv', row.names = FALSE)

