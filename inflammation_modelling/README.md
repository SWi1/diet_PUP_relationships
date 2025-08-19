 # Inflammation Modelling
 
 These scripts perform analyses related to lipopolysacharride binding protein (LBP). Linear models are first run to determine whether polyphenol intake alpha diversity predicts PUP gene alpha diversity and if PUP gene alpha diversity predicts LBP. Regarding machine learning models, hierarchical feature engineering is performed on PUP genes and PUP-containing microbes. Engineered features are combined with covariates and run in random forest machine learning models. Performance and SHAP plots are generated.
-  D0_PUP_diversity_ML_prep.Rmd
-  D1_LBP_PUP_Alpha_diversity.Rmd
-  D2_ML_HFE_PUP_run.sh
-  D2a_ML_HFE_convert_output.Rmd
-  D3_ML_dietML_multiseed_loop.sh
-  D4a_ML_PUP_Performance.Rmd
-  D4b_ML_PUP_SHAP.Rmd
-  D5a_ML_PUP_MB_Performance.Rmd
-  D5b_ML_PUP_MB_SHAP.Rmd
-  D6a_ML_Publication_SHAP_Plot.Rmd
-  D6b_ML_Publication_Correlation_Plot.Rmd
