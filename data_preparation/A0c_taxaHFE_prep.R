# Formatting and cleaning of metadata for taxaHFE
# Stephanie Wilson
# January 2024

## SUMMARY
## This script formats metadata for use in taxaHFE.

## INPUTS
# cleaned_data, from phyloseq_313.Rdata - phyloseq object for n = 313

## OUTPUT
# metadata_157.txt - metadata for low and high polyphenol intake quartile participants, includes ReadCount
# metadata_157_noReadCount.txt - metadata for low and high polyphenol intake quartile participants, does not include ReadCount

####################################
# Load data and packages
# packages
library(tidyverse)
# data
load("RData/metadata_313.Rdata")

####################################
# Quartiles
HFE_metadata_157 = cleaned_data %>%
  # Filter in relevant metadata. 
  select(c(UserName, pp_quartile_label, Age, BMI, Sex, 
           fiber_g1000kcal, hei_asa24_totalscore, ReadCount)) %>%
  filter(!pp_quartile_label == "Mid") %>%
  rename("subject_id" = "UserName",
         "pp_group" = "pp_quartile_label")

## Create ready to go version without read count
HFE_metadata_157_noReadCount = HFE_metadata_157 %>%
  select(-ReadCount)

# Write versions out
write.table(HFE_metadata_157, 'HFE/metadata_157.txt', sep = "\t", 
            quote = FALSE, row.names = FALSE)
write.table(HFE_metadata_157_noReadCount, 'HFE/metadata_157_noReadCount.txt', sep = "\t", 
            quote = FALSE, row.names = FALSE)

