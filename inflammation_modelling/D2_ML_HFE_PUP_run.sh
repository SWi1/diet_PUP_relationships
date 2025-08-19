# Hierarchical feature engineering of microbial features to predict LBP 
# 2 runs, PUP gene counts and PUP-containing microbial abundance
# Stephanie Wilson, July 2025

# PULL CONTAINER for updated version if needed.
docker pull aoliver44/taxa_hfe:latest

# Navigate to Folder
cd /Users/stephanie.wilson/Desktop/Scripts/FL100_Polyphenol_Microbiome

####################################
# Run taxaHFE, PUP genes
# Initiate DOCKER, DEVELOPMENT 2.0 
docker run --rm -it -v `pwd`:/home/docker -w /home/docker/taxaHFE_PUP aoliver44/taxa_hfe:2.2 bash

# Run taxaHFE, PUPs
taxaHFE-ML --subject_identifier Sample --label plasma_lbp_bd1 --feature_type numeric --lowest_level 3 --seed 42 --train_split 0.7 --model rf --metric mae /home/docker/taxaHFE_PUP/PUP_meta_LBP.csv /home/docker/taxaHFE_PUP/PUP_matrix.csv /home/docker/taxaHFE_PUP/taxaHFE_PUP_output.csv

exit

####################################
# Run taxaHFE, PUP-containing microbes
# Initiate DOCKER, DEVELOPMENT 2.0 
docker run --rm -it -v `pwd`:/home/docker -w /home/docker/taxaHFE_PUP_MB aoliver44/taxa_hfe:2.2 bash

# Run taxaHFE
taxaHFE-ML --subject_identifier Sample --label plasma_lbp_bd1 --feature_type numeric --lowest_level 3 --seed 42 --train_split 0.7 --model rf --metric mae /home/docker/taxaHFE_PUP_MB/PUP_meta_LBP.csv /home/docker/taxaHFE_PUP_MB/PUP_MB_matrix.csv /home/docker/taxaHFE_PUP_MB/taxaHFE_PUP_MB_output.csv

exit