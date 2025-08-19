#### Prepare and clean dbPUP polyphenol database files
#### Stephanie Wilson 
#### September 2024

# SUMMARY
# This script prepares, cleans, and formats dbPUP database files for downstream usage.

#INPUT
# merge_gene_norm_tab.csv - FL100 diamond output RPKG 
# dbPUP_Pfams.xlsx - list of Pfams attributed to each PUP
# 'Polyphenol - dbPUP.csv' - polyphenol substrates for each PUP 

# OUTPUT
# polyphenol_substrates_long.csv - list of polyphenols that can be utilized by each PUP
# dbpup_overview_clean.csv - wide format of all information related to PUP genes

#Load Library
library(tidyverse); library(stringr); library(readxl)

#######################################################
# Extract Names
names = read.csv("normalize_counts/merge_gene_norm_tab.csv", header =TRUE) %>%
  rename(id = Gene) %>%
  mutate(gene = str_extract(id, "(?<=\\|)[^|]+(?=\\|)"),
         Name = case_when(
           gene %in% c("X2CNV1", "C4PG47", "Q9S3L0") ~ "Alpha-L-rhamnosidase",  # Update conditionally
           TRUE ~ Name  # Leave other values as they are
         )) %>%
  select(c(gene, Name))

#######################################################
# Extract PFAM
OR = read_xlsx('dbPUP/dbPUP_Pfams.xlsx', sheet = 1) %>%
  mutate(class = 'oxidation_reduction')
FR = read_xlsx('dbPUP/dbPUP_Pfams.xlsx', sheet = 2) %>%
  mutate(class = 'functional_group_transfer')
HR = read_xlsx('dbPUP/dbPUP_Pfams.xlsx', sheet = 3) %>%
  mutate(class = 'hydrolysis')
NCR = read_xlsx('dbPUP/dbPUP_Pfams.xlsx', sheet = 4) %>%
  mutate(class = 'nonhydrolytic_cleaving')
IR = read_xlsx('dbPUP/dbPUP_Pfams.xlsx', sheet = 5) %>%
  mutate(class = 'isomerization')
UC = read_xlsx('dbPUP/dbPUP_Pfams.xlsx', sheet = 6) %>%
  mutate(class = 'unclassified')

pfam = rbind(OR, FR, HR, NCR, IR, UC) %>%
  relocate(class, 1) %>%
  separate_rows(Characterized, sep = ";\\s*") %>%
  mutate(Characterized = str_trim(Characterized)) 

#######################################################
# Clean and Expand Polyphenol Substrates
substrate = read.csv('dbPUP/Polyphenol - dbPUP.csv', strip.white = TRUE) %>%
  mutate(UniProt = str_replace(UniProt, ";$", ""))%>%
  separate_rows(UniProt, sep = ";\\s*") %>%
  mutate(gene = str_trim(UniProt)) %>%
  relocate(polyphenol = Name,
           class = Polyphenol.class,
           subclass = Polyphenol.sub.class) %>%
  select(-c(PUP.family, UniProt)) %>%
  relocate(gene, .before = polyphenol) %>%
  mutate(class = ifelse(gene == 'Q51723', "Flavonoids", class))

# Group polyphenols by gene
substrate_collapsed = substrate %>%
  group_by(gene) %>%
  summarise(substrate_list = paste(polyphenol, collapse = ", "))

write.csv(substrate, 'dbPUP/polyphenol_substrates_long.csv', row.names = FALSE)

#######################################################
# MERGE
merge = names %>%
  left_join(pfam, by = c('gene' = 'Characterized')) %>%
  left_join(substrate_collapsed) %>%
  mutate(across(everything(), ~str_replace_all(., "\u00A0", " ")))

write.csv(merge, 'dbPUP/dbpup_overview_clean.csv', row.names = FALSE)
