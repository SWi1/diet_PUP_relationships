# Formatting and cleaning of metagenomic composition data
# Stephanie Wilson
# January 2024

# SUMMARY

# INPUTS
# merged_metaphlan_v4-0-6.txt - community profiling output from metaphlan, n = 330
# cleaned_data.csv - from metadata_313.Rdata, meta data for subjects with diet and metagenome data

# Output
# FL100_metagenome_taxa_key.csv - taxonomy for FL100 fecal metagenomes
# metaphlan_cleaned_objects.Rdata - abundance, taxonomy for n = 330
# genus_level_abundance.Rdata - abundance, taxonomy at genus level for n = 331
# species_313.Rdata - abundance + taxonomy data for n = 313
# phyloseq_313.Rdata - phyloseq object for n = 313
# phyloseq_157.Rdata - phyloseq object for n = 157 (low and high polyphenol intake quartiles)

##########################################
# Load packages and metadata
##########################################
# packages
library(tidyverse); library(phyloseq)

metaphlan = readr::read_delim("data/merged_metaphlan_v4-0-6.txt") 
# Metadata has been cleaned to include the 313 subjects with metagenomic and diet
load("RData/metadata_313.Rdata")

##########################################
# Species Cleaning
# Based on code from Andrew Oliver
##########################################

species_full = metaphlan %>%
  dplyr::filter(str_detect(clade_name, '\\|s__[^|]*$')) %>%

  tidyr::separate(., col = clade_name, into = c("L1", "L2", "L3", "L4", "L5", "L6", "L7"), 
                  extra = "merge", remove = T, sep = "\\|") 

species_otu = species_full %>%
  dplyr::select(., L7, where(is.numeric)) %>%
  tibble::column_to_rownames(., var = "L7") %>%
  t() %>% as.data.frame() %>% 
  tibble::rownames_to_column(var = "subject_id") %>%
  janitor::clean_names()

# Likes species_full but with id column and taxonomic levels renamed.
# Species-Level with full taxonomy
species_tax = species_full %>%
  dplyr::select(L1:L7, where(is.numeric)) %>%
  rowid_to_column(var = "id") %>%
  rename(Kingdom = L1,
         Phylum = L2,
         Class = L3, 
         Order = L4,
         Family = L5,
         Genus = L6,
         Species = L7)

tax = species_tax %>%
  select(id:Species)

abundance = species_tax %>%
  select(id, where(is.numeric))

# Save objects
write.csv(tax, "data/FL100_metagenome_taxa_key.csv", row.names = FALSE)
write.csv(species_tax, 'data/FL100_metagenome_species_full_names.csv', row.names = FALSE)
save(species_full, tax, abundance, file = 'RData/metaphlan_cleaned_objects.RData')

##############
# GENUS LEVEL
genus_input = species_tax %>%
  select(c(Genus, where(is.numeric))) %>%
  select(-id) %>%
  group_by(Genus) %>%
  summarise_all(.funs = sum, na.rm = TRUE)

save(genus_input, file = "RData/genus_level_abundance.RData")

##########################################
# n = 313
# Create Phyloseq Object
##########################################

# Move column to row for downstream conversion to matrix
cleaned_data2 = cleaned_data %>%
  column_to_rownames(var = "UserName")

# Identify UserNames to Keep
subjects_keep = intersect(rownames(cleaned_data2), colnames(abundance))

# Filter in individuals with metagenomic and dietary data
abundance_313 = abundance %>%
  select(all_of(subjects_keep))

save(abundance_313, tax, file = "RData/species_313.RData")

# Create phyloseq object, species level
abundance_313_ob = otu_table(as.matrix(abundance_313), taxa_are_rows = TRUE)
meta_ob = sample_data(cleaned_data2)
tax_ob = tax_table(as.matrix(tax))

phyloseq_313 = phyloseq(abundance_313_ob, meta_ob, tax_ob)

save(phyloseq_313, file = 'RData/phyloseq_313.RData')

##########################################
# n = 157, Low and High PP Quartile Individuals Only
# Create Phyloseq Object
##########################################

# Move column to row for downstream conversion to matrix
metadata157 = cleaned_data %>%
  filter(pp_quartile_label %in% c("Low", "High")) %>%
  column_to_rownames(var = "UserName")

# Identify UserNames to Keep
subjects_keep157 = intersect(rownames(metadata157), colnames(abundance))

# Filter in individuals with metagenomic and dietary data
abundance_157 = abundance %>%
  select(all_of(subjects_keep157))

# Create phyloseq object, species level
abundance_157_ob = otu_table(as.matrix(abundance_157), taxa_are_rows = TRUE)
meta_157_ob = sample_data(metadata157)
# tax is same as n313 phyloseq object

phyloseq_157 = phyloseq(abundance_157_ob, meta_157_ob, tax_ob)

save(phyloseq_157, file = 'RData/phyloseq_157.RData')
