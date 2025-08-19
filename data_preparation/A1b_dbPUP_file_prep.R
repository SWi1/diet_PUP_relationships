#### A1b_dbPUP_file_prep
#### Stephanie Wilson 
#### December 16, 2024

############################################
# SUMMARY 
# This script:
# 1) summarizes the spread of PUP genes in the FL100 cohort
# 2) Creates a file with total PUP gene abundance for each individual in FL100
#
# INPUT
# metadata_313.Rdata, FL100 metadata
# dbpup_overview_clean, formatted dbPUP database
# merge_gene_norm_tab.csv, FL100 normalized counts of PUP genes
#
# OUTPUT
# dbpup_meta_summary.RDS, FL100 summary statistics for each dbPUP 
# FL100_PUP_subject_total.csv, sum PUP abundance for each individual
#
############################################

#Load Library
library(tidyverse) 

# Load diet and dbPUP Data
load("RData/metadata_313.Rdata")
info = read.csv('dbPUP/dbpup_overview_clean.csv')
dbpup = read.csv("normalize_counts/merge_gene_norm_tab.csv", header =TRUE) %>%
  rename(id = Gene) %>%
  mutate(gene = str_extract(id, "(?<=\\|)[^|]+(?=\\|)"))

# Pull out pup names
dbpup_names = info %>%
  select(c(gene, Name))
  
########################
# Convert to long format
dbpup_long = dbpup %>%
  pivot_longer(
    cols = starts_with("X"),  # Specify the columns to pivot longer
    names_to = "UserName",    # The name of the column that will hold the former column names
    values_to = "value")  %>%     # The name of the column that will hold the values
  mutate(UserName = as.integer(gsub("X", "", UserName))) %>%
  select(c(UserName, gene, Name, value)) %>%
  left_join(info)

## MERGE DATA
dbpup_meta_merge = dbpup_long %>%
  # Filter those who have dietary data
  filter(UserName %in% cleaned_data$UserName) %>%
  left_join(cleaned_data, by = "UserName") %>%
  # Three genes were somehow assigned NA even though input files are complete
  mutate(
    class = case_when(
    gene %in% c("X2CNV1", "C4PG47", "Q9S3L0") ~ "hydrolysis",
    TRUE ~ class
  ))

############################################
## Create a quick summary for each gene
summary_stats = dbpup_meta_merge %>%
  group_by(gene) %>%
  summarise(
    mean_value = mean(value, na.rm = TRUE),
    median_value = median(value, na.rm = TRUE),
    sd_value = sd(value, na.rm = TRUE),
    min_value = min(value, na.rm = TRUE),
    max_value = max(value, na.rm = TRUE),
    count = n(),
    zero_count = sum(value == 0, na.rm = TRUE)) %>%
  mutate(percent_zero = (zero_count/count) *100) %>%
  # Add Gene information back in
  left_join(dbpup_names, by = c('gene')) %>%
  relocate(Name, .after = gene)

# Identify what PUPs were not detected
zero_abundance = summary_stats %>%
  filter(max_value ==0) %>%
  pull(gene)

############################################
# Filter out undetected PUPs
# VALUE BY SUBJECT, GENE
dbpup_meta_filtered = dbpup_meta_merge %>% 
  filter(!Name %in% zero_abundance)

save(dbpup_meta_filtered, summary_stats, file='RData/dbpup_meta_summary.RDS')

############################################
# Create sum PUP abundance for each individual
PUP_subject_sum = dbpup_meta_filtered %>%
  select(c(UserName, gene, class, value)) %>%
  group_by(UserName) %>%
  summarise(
    total_PUP = sum(value, na.rm = TRUE),
    ## Summary of unique non-zero genes per participant
    nonzero_PUP_count = n_distinct(gene[value > 0]),
    nonzero_class_count = n_distinct(class[value > 0]))

write.csv(PUP_subject_sum, 'data/FL100_PUP_subject_total.csv', row.names = FALSE)