#--------------------------------------------------------------------------------------------------------------------
# Description: This is the first attempt to simulate networks from the gravity p[robit results. It is based on the results
#              from gravity_estimations_rr_v1_simulation.do
#--------------------------------------------------------------------------------------------------------------------

require(network)
require(tidyr)
require(btergm)


version_name = 'probit_simulation_v1'
sample_size = 100
year_num = 1995

repo_location = "D:\\work\\Peter_Herman\\projects\\trade_network_research"
save_path = paste(repo_location,"probit_ergm_gof\\v1_initial_try", sep = "\\")
data_location = paste("D:\\work\\Peter_Herman\\projects\\trade_network_research\\Gravity Modeling\\Stata Analysis\\v2 - 100 countries 75 percent\\probit_predicted_probabilities.csv", sep = "\\")

setwd(save_path)

#----- --------------
# Load and Prep Data
#---------------------
source("D:\\work\\Peter_Herman\\projects\\trade_network_research\\rr_ergm_analysis\\original_code\\BACI.functions.R")

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

probit_gof = createGOF(ntwk_list, list(real_network), statistics = c(esp, ideg, odeg, geodesic, istar, ostar), roc = FALSE)


pdf(paste(version_name,"gof_plots.pdf", sep = "_"))
plot(probit_gof, mfrow = FALSE, sim.col = 'r')
dev.off()

save(probit_gof, file = paste(version_name,"_gof_obj.rda", sep = ""))

statistics = list()
dists = attributes(g)$names
for(i in 1:length(g)){
  statistics[[dists[i]]] = g[[dists[i]]]$stats

}



typeof(statistics[1])

stats_df = g[[1]]$stats



