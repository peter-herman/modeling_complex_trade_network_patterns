#--------------------------------------------------------------------------------------------------------------------
# Description: This is the first attempt to simulate networks from the gravity p[robit results. It is based on the results
#              from gravity_estimations_rr_v1_simulation.do
#--------------------------------------------------------------------------------------------------------------------

require(network)
require(tidyr)
require(btergm)
rm(list=ls())

version_name = '2006_standard_probit_simulation'
sample_size = 100
year_num = 2006

repo_location = "D:\\work\\Peter_Herman\\projects\\trade_network_research"
save_path = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\comparisons\\2006"
data_location = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\gravity_analysis\\comparrison_specifications\\2006\\2006_probit_predicted_probabilities_subset_network_stats.csv"

setwd(save_path)

#----- --------------
# Load and Prep Data
#---------------------
source("D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\ergm_analysis\\BACI.functions.R")

prob_data <- read.csv(data_location)
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
  hold =  1*(prob_data['phat_1'] < runif(nobs))
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



