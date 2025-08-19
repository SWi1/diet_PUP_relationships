# annotate_lm_plot
# Annotation of linear model effects plots 
# Stephanie Wilson
# January 23 2024

# Overview
# Utilizes the jtools package which converts effects plots to a ggobject
# Once effects plot is a ggplot object, further annotation with model summaries are possible.

# Required Inputs
#    - model: lm model object
#    - predictor_of_interest: the model predictor you would like plotted.
#.   - y_adj = number which adjusts the position of the beta coefficient line,
#.             can be 0 - 1. Ex. 0.95 indicates second line position will be 95% of the max mpg value
# Currently works for continuous predictors only
###############################################################################

library(jtools)

annotate_lm_plot = function(model, predictor_of_interest, y_adj) {
  
  # Extract label information
  #r_squared = summary(model)$r.squared
  beta_coefficient = coef(model)[grep(paste0("^", predictor_of_interest), names(coef(model)))]
  
  # Extract p-value
  pvalue = as.data.frame(summary(model)$coefficients)%>%
    rownames_to_column() %>%
    rename(pvalue = 'Pr(>|t|)') %>%
    filter(rowname == predictor_of_interest) %>%
    select(pvalue) %>%
    mutate(pvalue_round = ifelse(pvalue > 0.01, signif(pvalue, digits = 2), round(pvalue, 4))) %>%
    pull()
  
  # Extract label positioning information
  x_pos = as.numeric(max(model$model[[predictor_of_interest]]))*0.65
  y_pos = max(model$model[[1]])
  
  # Generate effects plot
  plot = effect_plot(model, data = model$model, pred = !!predictor_of_interest, 
                     interval = TRUE, int.type = "confidence", partial.residuals = TRUE)
  
  # Add annotations
  final_plot = plot +
    # annotate("text", x = x_pos, y = y_pos, label = paste("R-squared =", round(r_squared, 2)), hjust = 0, vjust = 1) +
    annotate("text", x = x_pos, y = y_pos * y_adj, 
             label = bquote(atop(beta == .(signif(beta_coefficient, digits = 2)),
                                 p == .(pvalue))),
             hjust = 0, vjust = 1) +
    theme_bw()
  
  return(final_plot)
  print(final_plot)
}
