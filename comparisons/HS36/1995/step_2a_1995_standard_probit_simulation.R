#--------------------------------------------------------------------------------------------------------------------
# Description: This script simulates and computes GOF tests for a standard probit model of trade. It uses data produced 
#           by "\comparisons\1995\step1_1995_partial_gravity_analysis_for_comparisons.do"
#--------------------------------------------------------------------------------------------------------------------

#"C:\Program Files\Microsoft\R Open\R-4.0.2\bin\x64\R.exe"

require(network)
require(tidyr)
require(btergm)
rm(list=ls())

# -----
# Specification
# -----

version_name = '1995_standard_probit_simulation'
sample_size = 100 # Simulation sample size 
year_num = 1995 

save_path = "D:\\work\\Peter_Herman\\projects\trade_network_revisions_2020\\submission_files\\comparisons\\HS36\\1995\\1995_results"
data_location = "D:\\work\\Peter_Herman\\projects\\trade_network_revisions_2020\\submission_files\\comparisons\\1995\\1995_results\\1995_probit_predicted_probabilities_subset_network_stats.csv"

setwd(save_path)

#----- --------------
# Load and Prep Data
#---------------------
source("D:\\work\\Peter_Herman\\projects\\trade_network_revisions_2020\\submission_files\\ergm_analysis\\BACI.functions.R")

prob_data <- read.csv(data_location)
head(prob_data)

prob_data = subset(prob_data, year == year_num)

head(prob_data)
nobs = nrow(prob_data)

#----
# Create Real Network
#----
real_edges = prob_data[c('exporter','importer', 'traded')]
real_edges = subset(real_edges, traded == 1)
real_network = network(real_edges, matrix.type = "edgelist")

#------
# Create Simulated Networks
#------
sim_list = list()
for(i in 1:sample_size){
  var_name = paste('sim',i,sep='_')
  sim_list[i] = var_name
  set.seed(i)
  hold =  1*(prob_data['phat_standard'] > runif(nobs))
  prob_data[var_name] <- hold
}

net_list = list()
for (ntwk in 1:sample_size){
  sim_name = sim_list[[ntwk]]
  edge_list = prob_data[c('exporter', 'importer', sim_name)]
  edge_list = subset(edge_list, edge_list[sim_name] == 1)
  
  net_list[[ntwk]] <- network(edge_list, matrix.type = "edgelist")
}
ntwk_list = network.list(net_list)  

#---------------
# Test Goodness of Fit
#---------------

probit_gof = createGOF(ntwk_list, list(real_network), statistics = c(esp, ideg, odeg, geodesic, istar, ostar, nsp), roc = FALSE) # NSP just there to provide a place to store edges

# Rename the NSP term (position 7) to Edges
names(probit_gof)[7] = "Edges"

# Compute edge statistics
edge_list = c()
for(i in 1:sample_size){
    edge_list = append(edge_list, network.edgecount(net_list[[i]]))
}
edge_stat = data.frame("obs" = network.edgecount(real_network), "min" = min(edge_list), "mean" = mean(edge_list), "max" = max(edge_list))
# Overwrite the Edges attribute with the computed edge statistics.
probit_gof$Edges = edge_stat
probit_gof$Outdegree

pdf(paste(version_name,"gof_plots.pdf", sep = "_"))
plot(probit_gof, mfrow = FALSE, sim.col = 'r')
dev.off()

save(probit_gof, file = paste(version_name,"_gof_obj.rda", sep = ""))




