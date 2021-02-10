
library(foreign)

#------------------------
# Specify Characteristics
#------------------------

# Version Characteristics
setwd("D:\\work\\Peter_Herman\\projects\\rade_network_research\\files_used_in_submission\\ergm_analysis\\Partial Sample") #USITC Laptop

total_countries = 60
percentile_included = 0.5 # Include values grater than this percentile (E.G. 0.75 -> the largest 75% percent of values are included)
year.used = 1995
version_name = "1995_ergm_partial_sample" 


dropcountries <- c("NULL","ARB", "ATF", "COD", "IOT", "SCG") # ("NULL","ARB", "ATF", "COD", "IOT", "SCG") are missing in gravity data.

# Paths for other data
# countrylist.path = "P:\\Documents\\Working Papers\\ERGM Trade Networks\\Data Work\\BACISectors_v1\\207countrylist.csv"
# cepii.geo.path = "P:\\Documents\\Working Papers\\Data Various\\geo_cepii.dta"
# cepii.grav.path = "P:\\Documents\\Working Papers\\Data Various\\grav_data_1948to2015.csv"
# EEA.entry.path = "P:\\Documents\\Working Papers\\Data Various\\EEA Entry Dates.csv"
# 

#Paths for Chris' directory

countrylist.path <- "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\207countrylist.csv"
cepii.geo.path <- "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\geo_cepii.dta"
cepii.grav.path <- "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\grav_data_1995to2015.csv"


#---------------------
# Load and Prep Data
#---------------------

# Load functions
# source("D:\\work\\Peter_Herman\\projects\\trade_network_research\\rr_ergm_analysis\\original_code\\BACI.functions.R")
# source("D:\\work\\Peter_Herman\\projects\\trade_network_research\\rr_ergm_analysis\\original_code\\BACI_node_attributes.R")

source("D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\ergm_analysis\\BACI.functions.R")
source("D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\ergm_analysis\\BACI_node_attributes.R")

df <- read.csv("D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\partial_dataset_60-ctrys_50-pct_95-06_full_sample_network_vars.csv")
net <- df <- df[df$year == year.used,]
net <- net[,c('importer', 'exporter', 'traded')]
net <- net[net$traded == 1,]

#----------------
# Create Networks
#-----------------
library(statnet)
library(tidyr)

tr_union <- union(unique(net$exporter), unique(net$importer))
countrypairs <- expand.grid(tr_union, tr_union)
colnames(countrypairs) <- c( "iso3_o","iso3_d")
trade = unique(data.frame(net$exporter, net$importer))
trade$value <- 1
allflows <- merge(countrypairs, trade, by.x = c("iso3_o", "iso3_d"), by.y = c(1, 2), all.x = TRUE ) 
allflows.adj <- spread(allflows,iso3_d, value)
rownames(allflows.adj) <- as.vector(allflows.adj$iso3_o)
allflows.adj <- as.matrix(subset(allflows.adj, select = -c(iso3_o)))
allflows.adj[is.na(allflows.adj)] <- 0
agg.network <- network::network(allflows.adj, loops = FALSE)
network.vertex.names(agg.network) <- as.character(rownames(allflows.adj))

# Conver trade data to a network
agg.network

# Load Gravity data
cepii.grav <- read.csv(cepii.grav.path)

lang.network <- subnetwork.unvalued(net, cepii.grav, "comlang_ethno", year.used)
dist.network <- subnetwork.valued.edge.attribute(data, "distw", year.used, cepii.grav )
summary(dist.network)
contig.network <- subnetwork.unvalued(data, cepii.grav, "contig", year.used); contig.network
rta.network <- subnetwork.unvalued(data, cepii.grav, "rta", year.used); rta.network

countrylist <- data.frame(unique(net$importer))
keepers <- c("iso_o", "year", 'gdp_o')
cepii.unilateral <- subset(cepii.grav, select = c("iso3_o" , "year"  , 'gdp_o'))
cepii.unilateral <- unique(subset(cepii.unilateral, year == year.used))
node.att.mat <- merge(allflows, cepii.unilateral, by.x = c(1), by.y = c("iso3_o"), all.x = TRUE)
node.att.mat <- unique(node.att.mat[,c('iso3_o', 'gdp_o')])
node.att.mat[is.na(node.att.mat)] <- quantile(cepii.unilateral$gdp_o, .1, na.rm = TRUE)
node.att.mat <- dplyr :: arrange(node.att.mat, iso3_o)
agg.network %v% 'gdp_o' <- node.att.mat[,2]                           

version_number <- 1

ergm.output.1995 <-  ergm( agg.network ~ edges + mutual  + gwesp(decay=1) + nodecov('gdp_o') + edgecov(dist.network, attrname = "distw") +
                             edgecov(lang.network) + edgecov(contig.network) + edgecov(rta.network) ,   
                           control=control.ergm(MCMC.burnin=1e+5, MCMC.interval=1000, MCMC.samplesize=100000,
                                                MCMLE.maxit = 250, seed=1))

# Save ERGM object

save(ergm.output.1995, file = paste(version_name,"_output.rda", sep = ""))

# Print estimates
summary(ergm.output.1995)
ergm.output.1995$mle.lik

# Write results to files and pdfs
write_ergm_results(ergm.output.1995, file_name = version_name)


