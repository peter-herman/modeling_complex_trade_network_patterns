# Description: This script pulls together the the ERGM, standard probit, and network probit goodness of fit models and constructs ISE measure
#   This version looks at HS45 in 1995.

#"C:\Program Files\Microsoft\R Open\R-4.0.2\bin\x64\R.exe"


rm(list=ls())

library(statnet)
library(btergm)

source("comparisons\\comparison_functions.R")

ergm_path = "ergm_analysis\\HS 50 countries\\hs45\\1995_ergm_hs45_top50_2021-06-15_20-04.txt_gof_obj.rda"
probit_path = "comparisons\\HS45\\1995_standard_probit_simulation_gof_obj.rda"
network_probit_subset_stats_path = "comparisons\\HS45\\1995_network_probit_simulation_gof_obj.rda"
save_path = "comparisons\\HS45"


#----
# Standard Probit
#----

load(ergm_path)   # Object called ergm_gof
load(probit_path) # Object called probit_gof 
ls()

attributes(ergm_gof)
#attributes(probit_gof)

comp_list = compile_gof_comps(probit_gof, ergm_gof)

write_gof_comparisons(comp_list, save_path, "1995_combined_gof_tables_standard_probit.csv")


#----
# Network Probit with Network Stats based on the subset data
#----

load(network_probit_subset_stats_path)
comp_list_3 = compile_gof_comps(probit_gof_nws, ergm_gof)
attributes(comp_list_3)
write_gof_comparisons(comp_list_3, save_path, "1995_combined_gof_tables_network_probit.csv")



