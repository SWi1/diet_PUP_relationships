# Functions
Custom functions built for ease of diet-PUP analysis and visualization.

- **get_taxonomy.R**: Webscraping function obtain compound taxonomy information from FooDB.ca
- **annotate_lm_plot.R**: Utilizes the jtools package which converts effects plots to a ggplot object which enables annotation with model summary information.
- **find_RDS.R**: Scans working directory of interest for all RDS files and compiles path information. 
- **extract_performance_metrics.R**: Isolates RDS file pathways created by one run of dietML (from find_RDS), then extracts model performance data
