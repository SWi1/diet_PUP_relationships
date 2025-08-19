# Part I: hierarchical feature engineering of microbial features to predict LO/HI polyphenol intake quartiles
# Stephanie Wilson, July 2025

# PULL CONTAINER for updated version if needed.
docker pull aoliver44/taxa_hfe:latest

# Navigate to Folder
cd /Users/stephanie.wilson/Desktop/SYNC/Scripts/FL100_Polyphenol_Microbiome/HFE

# Initiate DOCKER, DEVELOPMENT 2.0 
docker run --rm -it -v `pwd`:/home/docker aoliver44/taxa_hfe:latest bash

# Run taxaHFE
# LO/HI polyphenol intake
taxaHFE --subject_identifier subject_id --label pp_group  --feature_type factor --abundance 0 --prevalence 0 --lowest_level 3 --seed 35 --nperm 80 -n 4 -wWD metadata_157_noReadCount.txt /home/docker/merged_metaphlan_v4-0-6.txt /home/docker/taxaHFE_output.csv

# Run Taxa HFE on all 313 to collapase microbial features
taxaHFE --subject_identifier subject_id --label pp_quartile_label --feature_type factor --disable_super_filter --abundance 0 --prevalence 0 --lowest_level 3 --seed 35 --nperm 80 -n 4 -wWD /home/docker/metadata_313.csv /home/docker/merged_metaphlan_v4-0-6.txt /home/docker/taxaHFE_313_output.csv

exit