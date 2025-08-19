#### PERMANOVA on single taxaHFE output
#### Stephanie Wilson 


## SUMMARY
# This script runs PERMANOVA on each taxonomic level to assess whether 
# microbial composition differs between low and high quartiles of polyphenol intake. 

## INPUT
# metadata_313.csv - meta data for subjects with diet and metagenome data
# FL100_metagenome_taxa_key.csv -  taxonomy for FL100 fecal metagenomes
# taxaHFE_output_no_sf.csv - one of the taxaHFE output files

### OUTPUT
# PERMANOVA_taxaHFEfeatures.Rdata - results from single PERMANOVA at noSF level

##########################
## Load packages and Data
##########################
#Load Library
library(vegan);  library(tidyverse); library(effects); library(ggpubr)

# Load participant data
load("RData/metadata_313.Rdata")

  metadata = cleaned_data %>%
    filter(!pp_quartile_label == "Mid") %>%
    rename("pp_group" = "pp_quartile_label",
           "subject_id" = "UserName")

# Load taxonomic key
tax = read.csv("data/FL100_metagenome_taxa_key.csv")

otu = read.csv("HFE/taxaHFE_output/taxaHFE_output_no_sf.csv")%>%
  tibble::column_to_rownames(., var = "subject_id") %>%
  select(-feature_of_interest)

# Brief list of polyphenol/taxa relationships found in the literature
# Alves-Santos et al, Brune et al, Wilson et al, Lacombe et al
associations = c("bacteroides", "lactobacillus", "bifidobacterium", "faecalibacterium", 
                 "roseburia", "eggerthella", "akkermansia", "enterococcus", "parabacteroides",
                 "lactococcus", "flavinofractor", "eisenbegiella", "coriobacteriaceae")
##########################
## PERMANOVA
##########################
permanova = adonis(formula = otu ~ as.numeric(Age) +  
                     as.numeric(BMI) +
                     as.factor(Sex) + 
                     as.numeric(fiber_g1000kcal) +
                     as.numeric(hei_asa24_totalscore) +
                     as.factor(pp_group),
                                 method = "bray", 
                                 permutations = 999, 
                                 data = metadata, by = "terms")

# Extract Coefficients
transposed_coef = as.data.frame(coef(permanova)) %>%
  slice(6) %>% # Isolate the polyphenol coefficients
  t() %>%
  as_tibble(rownames = "Taxa") %>%
  rename("Coefficient" = 2) %>%
  mutate(pp_association = ifelse(str_detect(Taxa, 
                                                paste(associations, collapse = "|")), "yes", "no"))


# Beta dispersion
anova(betadisper(vegdist(otu), metadata$pp_group))

# Save table for plotting
save(transposed_coef, file = "RData/PERMANOVA_taxaHFEfeatures.Rdata")
