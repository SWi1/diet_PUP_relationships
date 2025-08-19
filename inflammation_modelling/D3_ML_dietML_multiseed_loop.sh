#!/bin/bash

# ----------------------------------------
# PUP Analysis
# Random Forest Regression of taxaHFE-selected PUP features and study covariates
# Stephanie Wilson, July 2025
#
# Script to run dietML across 10 random seeds
# For PUP counts and PUP
# Each seed run is isolated in its own output folder.
#
# Make sure latest dietML is pulled down
# INTEL
# docker pull aoliver44/nutrition_tools:latest
# SILICON
# docker run --platform linux/amd64 --rm -itd \
#  -v "$(pwd)":/home/docker \
#  -w /home/docker \
#  aoliver44/nutrition_tools:latest bash
#
# ----------------------------------------

# ----------------------------------------

# 10 random seeds
SEEDS=(372 9481 527 10483 7623 191 6532 847 2930 7669)

run_docker_pipeline() {
    # Set your working directory
    WORK_DIR="$1"

    cd "$WORK_DIR" || exit 1

    # Start Docker container
    docker run --rm -itd -v "$(pwd)":/home/docker/ -w /home/docker aoliver44/nutrition_tools:latest bash
    CONTAINER_ID=$(docker ps -lq)

    # Run generic_read_in
    docker exec -it "$CONTAINER_ID" bash -c "
        generic_read_in --subject_identifier subject_id /home/docker/dietML /home/docker/output"

    # Run generic_combine
    docker exec -it "$CONTAINER_ID" bash -c "
        generic_combine --subject_identifier subject_id --label feature_of_interest --cor_level 0.99 --cor_choose TRUE --preserve_samples FALSE /home/docker/output merged_data.csv"

    # Run dietML for each seed
    for SEED in "${SEEDS[@]}"; do
        docker exec -it "$CONTAINER_ID" bash -c "
            dietML --subject_identifier subject_id --train_split 0.8 --label feature_of_interest --model rf --type regression --metric mae --shap TRUE --seed ${SEED} --ncores 8 /home/docker/output/merged_data.csv /home/docker/output_seed_${SEED}/"
    done

    # Stop container
    docker stop "$CONTAINER_ID"
}

# For PUP-containing microbial abundance
run_docker_pipeline "/Users/stephanie.wilson/Desktop/Scripts/FL100_Polyphenol_Microbiome/taxaHFE_PUP_MB/"

# For PUP gene counts
run_docker_pipeline "/Users/stephanie.wilson/Desktop/Scripts/FL100_Polyphenol_Microbiome/taxaHFE_PUP/"
