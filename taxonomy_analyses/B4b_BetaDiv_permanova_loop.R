####################
# PERMANOVA LOOP 
# Adapted Code from Andrew Oliver
# Stephanie Wilson
####################


### SUMMARY
# This script runs PERMANOVA on each taxonomic level to assess whether 
# microbial composition differs between low and high quartiles of polyphenol intake. 

### INPUT
# metadata_313.csv - meta data for subjects with diet and metagenome data
# taxaHFE output files

### OUTPUT
# PERMANOVA DF - R2, p-value, # features for each taxonomic level
# Plot - supplemental figure showing R2 for each taxonomic level

###################################################
## load libraries
library(dplyr); library(vegan); library(ggplot2); library(ggsci)

# Load participant data
load("RData/metadata_313.Rdata")

# Remove middle quartiles
metadata = cleaned_data %>%
  filter(!pp_quartile_label == "Mid") 

###################################################
## make empty dataframe to store results
results_df = data.frame(filename=character(), 
                         r_sq=numeric(),
                         p_value=numeric(),
                         n_features=numeric())

## loop over datasets made by taxaHFE and PERMANOVA
list_of_files = c(paste0("taxaHFE_output_level_", seq(1:8), ".csv"),
                   "taxaHFE_output.csv",
                   "taxaHFE_output_no_sf.csv")

for (file in list_of_files) {
  
  ## read in file
  df = read.csv(paste0("HFE/taxaHFE_output/", file)) %>%
    tibble::column_to_rownames(., var = "subject_id")
  
  ## do the permanova
  permanova_results <- vegan::adonis2(formula = df[2:NCOL(df)] ~ 
                                        as.numeric(metadata$Age) + 
                                        as.numeric(metadata$BMI) +
                                        as.factor(metadata$Sex) +
                                        as.numeric(metadata$hei_asa24_totalscore) + 
                                        as.numeric(metadata$fiber_g1000kcal) +
                                        as.factor(feature_of_interest),
                                      method = "bray", 
                                      permutations = 999, 
                                      data = df, by = "terms")
  
  ## append the results to the results df
  results_df <- results_df %>% dplyr::add_row(
    filename = file,
    r_sq = permanova_results$R2[6],
    p_value = permanova_results$`Pr(>F)`[6],
    n_features = (NCOL(df) - 1)
  )
}

###################################################
## plot results!
plot_data = results_df %>%
  # Clean up filename values
  mutate(
    filename = gsub(pattern = "taxaHFE_output_level", replacement = "level", x = filename),
    filename = gsub(pattern = "_output", replacement = "", x = filename),
    filename = gsub(pattern = ".csv", replacement = "", x = filename)) %>%
  # Remove taxaHFE case with the superfilter
  filter(!filename %in% c("taxaHFE", "taxaHFE_no_sf")) %>%
  # Replace level names with taxonomic ranks
  mutate(filename = case_when(
      filename == "level_1" ~ "Kingdom",
      filename == "level_2" ~ "Phylum",
      filename == "level_3" ~ "Class",
      filename == "level_4" ~ "Order",
      filename == "level_5" ~ "Family",
      filename == "level_6" ~ "Genus",
      filename == "level_7" ~ "Species",
      filename == "level_8" ~ "Strain",
      TRUE ~ filename),
    filename = factor(filename, levels = order)) 

write.csv(plot_data, 'output/PERMANOVA_results.csv', row.names = FALSE)

#################################################################
## PLOT
permanova_overview = ggplot(plot_data, aes(x = filename, weight = r_sq)) + 
  geom_bar(aes(fill = filename)) + 
  geom_text(
    aes(label = ifelse(p_value < 0.01, "p<0.01", paste0("p=", sprintf("%.2f", p_value))),
        y = r_sq * 1.02), vjust = 0) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none") +
  labs(x = "", y = "PERMANOVA R2") +
  ggsci::scale_fill_futurama()

ggsave(permanova_overview, filename = 'images/PERMANOVA_barplot_overview.png', width = 6.5, height = 5, units = "in", dpi =300)
