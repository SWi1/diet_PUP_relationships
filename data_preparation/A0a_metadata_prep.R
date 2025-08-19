# FL100 Metadata prep for phyloseq object
# Stephanie Wilson
# January 2024

# SUMMARY
# Cleaning of dietary polyphenol intake data, biological data for metadata prep.

# INPUT
# FL100_coffee_tea_consumers.csv
# FL100_merged_variables.csv, many metadata files combined from FL100
# FL100_FooDB_Polyphenol_Intakes.RDS, intake, All < BY Recall < By Subject
# FooDB_phenol_content_DailyClassAvg_mg1000kcal, Avg Polyphenol Class Intake by Participant
# Enterobacteriaceae.csv, metagenomics-based enterobacteriaceae abundance
# CTSC24532USDAWHNRCNu-WaistHipCircumferenc_DATA_2025-01-22_1253.csv, FL100 Waist/Hip
# FL100_extFrags_readcounts.txt - Read Counts from FL100 extFrags files
# FL100_alpha_div_summary.txt

# OUTPUT
# metadata_350.Rdata - meta data for subjects with diet data
# metadata_343.Rdata - meta data for subjects with diet and 16S data
# metadata_313.csv - meta data for subjects with diet and metagenome data
# metadata_313.Rdata - meta data for subjects with diet and metagenome data

############################################################
# LOAD DIETARY, ANTHROPOMETRIC, LPS DATA
############################################################
library(tidyverse)

# Coffee and Tea Consumers
coffee_tea = read.csv('data/FL100_coffee_tea_consumers.csv') %>%
  mutate(coffee_consumer = if_else(is.na(coffee_consumer), "no", coffee_consumer),
         tea_consumer = if_else(is.na(tea_consumer), "no", tea_consumer))

# total kcal intake from dietary data
totalkcal = read.csv('data/FL100_merged_variables.csv') %>%
  select(c(UserName, avg_total_kcal)) %>%
  filter(!is.na(avg_total_kcal))

# Polyphenol Intake, Total
#Various levels of polyphenol intake
load('FL100_diet_prep/output/FL100_FooDB_Polyphenol_Intakes.RDS')
totalpp = ASA_by_subject %>%
  left_join(totalkcal) %>% 
  mutate(ppintake_mg1000kcal = pp_average_mg/avg_total_kcal*1000) %>%
  select(c(UserName, ppintake_mg1000kcal))

# Polyphenol Intake, Class Level
class = read.csv('FL100_diet_prep/output/FooDB_phenol_content_DailyClassAvg_mg1000kcal.csv')
classes_of_interest = class %>%
  select(c(UserName, Phenylpropanoic.acids, Prenol.lipids)) 

# Relative abundance of two LPS containing bacteria 
LPS = read.csv("data/Enterobacteriaceae.csv", header =TRUE) %>%
  rename("UserName" = 1)

# For additional obesity classification
waist_hip = read.csv('data/CTSC24532USDAWHNRCNu-WaistHipCircumferenc_DATA_2025-01-22_1253.csv') %>%
  rename(UserName = subject_id)

# Metagenomic Read Count, Recommended for Maaslin3
read_count = read.delim('data/FL100_extFrags_readcounts.txt', header = TRUE, 
                        sep = " ", col.names = c("UserName", "ReadCount"))

# Participant Metadata
merged = read.csv('data/FL100_merged_variables.csv') %>%
  filter(!is.na(avg_total_kcal)) %>%
  left_join(coffee_tea) %>%
  left_join(waist_hip) %>%
  left_join(read_count) %>%
  mutate(fiber_g1000kcal = avg_total_fiber/avg_total_kcal*1000) %>%
  select(c(UserName, Age, Sex, BMI, waistavg_cm, coffee_consumer, fiber_g1000kcal, hei_asa24_totalscore,
           CRP_BD1, plasma_lbp_bd1, fecal_calprotectin, fecal_mpo, fecal_neopterin, ReadCount)) 

############################################################
# Identify who has 16S rRNA and dietary data
############################################################

diet350 = merged %>%
  left_join(totalpp) %>%
  left_join(classes_of_interest) 

alpha = read.delim('data/FL100_alpha_div_summary.txt', header = TRUE, 
                   sep = "\t", dec = ".") %>%
  rename('UserName' = 'SubjectID')

no_16S = anti_join(diet350, alpha, by = 'UserName') %>%
  select(UserName) %>%
  pull()

no_diet_has16S = anti_join(alpha, diet350, by = 'UserName') %>%
  select(UserName) %>%
  pull()

diet343 = diet350 %>%
  filter(!UserName %in% c(no_16S, no_diet_has16S))

save(diet350, file = "RData/metadata_350.RData")
save(diet343, file = "RData/metadata_343.RData")

############################################################
# Identify who has metagenomic and dietary data
############################################################

# all UserNames with dietary data without a metagenome
no_metag = anti_join(class, LPS, by = 'UserName') %>%
  select(UserName) %>%
  pull()

# all UserNames with metagenome without dietary data
no_diet = anti_join(LPS, class, by = 'UserName') %>%
  select(UserName) %>%
  pull()

# Cleaned Dataframes
filtered = class %>%
  filter(!UserName %in% c(no_metag, no_diet))

message("Participants with diet and metagenomic data: ", nrow(filtered))

# Merge Dataframes for n = 313
cleaned_data = filtered %>%
  left_join(totalpp) %>%
  left_join(LPS) %>%
  left_join(merged) %>%
  relocate(Age, BMI, Sex, fiber_g1000kcal, hei_asa24_totalscore, coffee_consumer, ReadCount,
           .after = UserName) %>%
  #Create Quartiles based on polyphenol intake
  mutate(pp_quartile = ntile(ppintake_mg1000kcal, 4),
         pp_quartile_label = case_when(pp_quartile ==1 ~ "Low",
                                       pp_quartile ==2 ~ "Mid",
                                       pp_quartile ==3 ~ "Mid",
                                       pp_quartile ==4 ~ "High"))

save(cleaned_data, file = "RData/metadata_313.Rdata")

############################################################
# For Taxa HFE, n = 313
cleaned_data_HFE = cleaned_data %>%
  select(c(UserName:hei_asa24_totalscore, ppintake_mg1000kcal, pp_quartile_label)) %>%
  rename(subject_id = UserName)

write.csv(cleaned_data_HFE, 'HFE/metadata_313.csv', row.names = FALSE)
