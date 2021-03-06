rm(list=ls())
library(statnet)
library(btergm)

source("D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\comparisons\\comparison_functions.R")

ergm_path = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\ergm_analysis\\Partial Sample\\1995_ergm_partial_sample_gof_obj.rda"
probit_path = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\comparisons\\1995\\1995_standard_probit_situation_gof_obj.rda"
network_probit_subset_stats_path = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\comparisons\\1995\\1995_network_probit_simulation_gof_obj.rda"
save_path = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\comparisons\\1995"


#----
# Standard Probit
#----

load(ergm_path)   # Object called ergm_gof
load(probit_path) # Object called probit_gof 
load(network_probit_subset_stats_path)

ls()

attributes(ergm_gof)
attributes(probit_gof)

comp_list = compile_gof_comps(probit_gof, ergm_gof)

write_gof_comparisons(comp_list, save_path, "1995_combined_gof_tables_standard_probit.csv")



#----
# Network Probit with Network Stats based on the subset data
#----

comp_list_3 = compile_gof_comps(probit_gof_nws, ergm_gof)
attributes(comp_list_3)
write_gof_comparisons(comp_list_3, save_path, "1995_combined_gof_tables_network_probit.csv")

