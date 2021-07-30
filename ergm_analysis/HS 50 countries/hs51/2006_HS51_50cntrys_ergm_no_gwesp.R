#C:\Program Files\Microsoft\R Open\R-4.0.2\bin\x64\R.exe"

# Description:  ERGM Estimation of HS51 in 2006. ERGM includes gwesp and MRT covariate. The MRT term is the product of the fixed effects divided by the max of the products.

library(statnet)
library(foreign)
require(stargazer)
library(tidyr)
library(dplyr)

#------------------------
# Specify Characteristics
#------------------------

# Version Characteristics
setwd("ergm_analysis\\HS 50 countries\\hs51")

total_countries = 50
year.used = 2006
version_name = "2006_ergm_hs51_top50"


dropcountries <- c("NULL","ARB", "ATF", "COD", "IOT", "SCG") # ("NULL","ARB", "ATF", "COD", "IOT", "SCG") are missing in gravity data.

# Paths for data
trade_data_path = "ergm_analysis\\HS 50 countries\\data\\hs51_baci_data_2006_top50_traders.csv"
mr_path = "ergm_analysis\\HS 50 countries\\hs51\\ppml_hs51_top50_standard_fe_estimates.csv"

cepii.grav.path <- "data\\grav_data_1995to2015.csv"



#---------------------
# Load and Prep Data
#---------------------

# Load functions
source("ergm_analysis\\BACI.functions.R")
source("ergm_analysis\\BACI_node_attributes.R")


trade_data <- read.csv(trade_data_path, header = TRUE, sep = ",")
# Modify data a bit so country core replacer will work
trade_data = select(trade_data, -'traded')
trade_data = rename(trade_data, 'hs6'='hs2')
trade_data$q = 0
net = countrycode.replacer(trade_data, "data\\country_name_correspondence.dta")
net$traded = 1
net <- net[,c('importer', 'exporter', 'traded')]



#----------------
# Create Networks
#-----------------

# Create Square panel of countries
tr_union <- union(unique(net$exporter), unique(net$importer))
countrypairs <- expand.grid(tr_union, tr_union)
colnames(countrypairs) <- c( "iso3_o","iso3_d")
# Get unique observations of trade (unnecessary unless there are multiple sectors)
trade = unique(data.frame(net$exporter, net$importer))
trade$value <- 1
# Combine trade observations with square panel
allflows <- merge(countrypairs, trade, by.x = c("iso3_o", "iso3_d"), by.y = c(1, 2), all.x = TRUE ) 
# Reshape wide to adjaceny matrix
allflows.adj <- spread(allflows,iso3_d, value)
rownames(allflows.adj) <- as.vector(allflows.adj$iso3_o)
allflows.adj <- as.matrix(subset(allflows.adj, select = -c(iso3_o)))
# Fill non-trading pairs with zero
allflows.adj[is.na(allflows.adj)] <- 0
# Convert trade data to a network
agg.network <- network::network(allflows.adj, loops = FALSE)
network.vertex.names(agg.network) <- as.character(rownames(allflows.adj))
# Print network Characteristics
agg.network

# -------
# Create Extra Data
# -------

# Create a data object with data and country list for use in subnetwork builders
data_obj = list("data"=net, "countries"=tr_union)

# Load Gravity data
cepii.grav <- read.csv(cepii.grav.path)

##
# Add MRT estimates
##
mr_data = read.csv(mr_path, header = TRUE, sep = ",")
# Check if countries are coded the same
mr_countries = c(unique(mr_data$exporter))
cepii_countries = c(unique(cepii.grav$iso3_o))
setdiff(mr_countries, cepii_countries)

cepii.grav = merge(cepii.grav, mr_data, by.x = c('iso3_o', 'iso3_d','year'), by.y = c('exporter','importer', 'year'), all = FALSE) 
summary(cepii.grav$imp_fe)
summary(cepii.grav$exp_fe)

cepii.grav$mr_prod = (cepii.grav$imp_fe) * (cepii.grav$exp_fe)
max_mr_prod = max(cepii.grav$mr_prod)
cepii.grav$mr_prod = cepii.grav$mr_prod/max_mr_prod
if (min(cepii.grav$mr_prod) < 0) {
    stop('There are negative fixed effect values!')
}

##
# Creat Subnetworks
##
lang.network <- subnetwork.unvalued(data_obj, cepii.grav, "comlang_ethno", year.used)
dist.network <- subnetwork.valued.edge.attribute(data_obj, "distw", year.used, cepii.grav )
contig.network <- subnetwork.unvalued(data_obj, cepii.grav, "contig", year.used); contig.network
rta.network <- subnetwork.unvalued(data_obj, cepii.grav, "rta", year.used); rta.network
mrt.network <- subnetwork.valued.edge.attribute(data_obj, "mr_prod", year.used, cepii.grav )


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

ergm.output <-  ergm( agg.network ~ edges + mutual + nodecov("gdp_o") + edgecov(dist.network, attrname = "distw") +
                             edgecov(lang.network) + edgecov(contig.network) + edgecov(rta.network) + edgecov(mrt.network, attrname = "mr_prod"),   
                           control=control.ergm(MCMC.burnin=1e+5, MCMC.interval=1000, MCMC.samplesize=100000,
                                                MCMLE.maxit = 250, seed=1))

# Save ERGM object

save(ergm.output, file = paste(version_name,"_output.rda", sep = ""))

# Print estimates
summary(ergm.output)
ergm.output$mle.lik

# Write results to files and pdfs
write_ergm_results(ergm.output, file_name = version_name)


