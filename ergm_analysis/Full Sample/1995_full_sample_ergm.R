# Description: ERGM estimation of the full sample in 2006. 



#"C:\Program Files\Microsoft\R Open\R-4.0.2\bin\x64\R.exe"
#rm(list = ls())
library(statnet)
library(foreign)
require(stargazer)
library(tidyr)


# Set working directory
setwd("ergm_analysis\\Full Sample\\ERGM_full_sample_results")

save_name = "1995_full_sample_ergm_results.txt"
model_fit_save = "1995_full_sample_ergm_model_fit.rda"
ergm_results_name = "1995_full_sample_ergm_results_ext"

# Set paths
countrylist.path = "data\\207countrylist.csv"
cepii.geo.path = "data\\geo_cepii.dta"
cepii.grav.path = "data\\grav_data_1995to2015.csv"
mr_path = "gravity\\main_analysis\\PPML\\results\\standard_fe_estimates.csv"


# load functions from other files
source("ergm_analysis\\BACI.functions.R")
source("ergm_analysis\\BACI_node_attributes.R")


## Load data sources
#To change year, alter both the "data <- read.csv" line and the "year.used" line 
year.used <- 1995
data <- read.csv("data\\baci92_1995.csv", header = TRUE, sep = ",")

# Replace Country codes with iso3-alphas
data <- countrycode.replacer(data, "data\\country_name_correspondence.dta")

# Drop some countries 
dropcountries <- c("NULL","ARB", "ATF", "COD", "IOT", "SCG") #missing grav data at least.

# Prepwork
data <- BACI.data.prep(data, dropcountries) #Preps the data a bit more.  Also adds in a second list item (attribute) containing a list of countries.
#identify.missingdata.countries(data, cepii.grav.path, year.used, c("distw","comlang_ethno", "contig", "rta", "colony"))


cepii.grav <- read.csv(cepii.grav.path)

# ---
# Add estimates of MRTs
# ---
mr_data = read.csv(mr_path, header = TRUE, sep = ",")
# Check if countries are coded the same
mr_countries = c(unique(mr_data$exporter))
cepii_countries = c(unique(cepii.grav$iso3_o))
setdiff(mr_countries, cepii_countries)

cepii.grav = merge(cepii.grav, mr_data, by.x = c('iso3_o', 'iso3_d','year'), by.y = c('exporter','importer', 'year'), all = FALSE) 
summary(cepii.grav$imp_fe)
summary(cepii.grav$exp_fe)

cepii.grav$mr_prod = cepii.grav$imp_fe * cepii.grav$exp_fe
max_mr_prod = max(cepii.grav$mr_prod)
cepii.grav$mr_prod = cepii.grav$mr_prod/max_mr_prod
if (min(cepii.grav$mr_prod) < 0) {
    stop('There are negative fixed effect values!')
}


# ---
# Create Aggregate Network
# ---
# Create all combinations of countries
countrypairs <- expand.grid(data$countries, data$countries)
# Rename columns
colnames(countrypairs) <- c( "iso3_o","iso3_d")
# Create dataframe containing all unique pairs in the trade data that exhibit possitive trade
trade = unique(data.frame(data$data$exporter, data$data$importer))
# Add indicator for positive trade
trade$value <- 1
# Merge all pairs with trading pairs
allflows <- merge(countrypairs, trade, by.x = c("iso3_o", "iso3_d"), by.y = c("data.data.exporter", "data.data.importer"), all.x = TRUE ) 
# reshape wide (row = importer/destination, column = exporter/origin )
allflows.adj <- tidyr::spread(allflows,iso3_d, value)
# add importer ID as row name
rownames(allflows.adj) <- as.vector(allflows.adj$iso3_o)
# converts DataFrame to matrix and drops the "iso3_o" column, which is now stored as a row name
allflows.adj <- as.matrix(subset(allflows.adj, select = -c(iso3_o)))
# Convert missing values to 0
allflows.adj[is.na(allflows.adj)] <- 0
# Convert to a network object
agg.network <- network(allflows.adj, loops = FALSE)
# Set node names
network.vertex.names(agg.network) <- as.character(data$countries)





#   Edge Attribute Generation:
#     subnetwork.valued.edge.attribute(data, edge.attribute, year, cepii.grav) is to be used for valued edge attributes. call in ergm using "edgecov(attribute.network, attrname = "edge.attribute")"
#     subnetwork.unvalued(data, cepii.grav, "comlang_ethno", year.used) may be used for unvalued edge attributes (the valued version can be used as well and returns the same estimates but is takes up more memory). Call in ergm using "edgecov(attribute.network)"
lang.network <- subnetwork.unvalued(data, cepii.grav, "comlang_ethno", year.used)
dist.network <- subnetwork.valued.edge.attribute(data, "distw", year.used, cepii.grav )
contig.network <- subnetwork.unvalued(data, cepii.grav, "contig", year.used)
rta.network <- subnetwork.unvalued(data, cepii.grav, "rta", year.used)
mrt.network <- subnetwork.valued.edge.attribute(data, "mr_prod", year.used, cepii.grav )


# Node Attribute Generators:
agg.network <- node.attribute.adder(agg.network, data, cepii.grav, year.used, "gdp_o")

#
Sys.time()

ergm.output <-  ergm( agg.network ~ edges + mutual   +   nodecov("gdp_o") + edgecov(dist.network, attrname = "distw") + edgecov(lang.network) + edgecov(contig.network) + edgecov(rta.network) + edgecov(mrt.network, attrname = "mr_prod"),   control=control.ergm(MCMC.burnin=1e+5, MCMC.interval=1000, MCMC.samplesize=100000, MCMLE.maxit = 100, seed=1))


Sys.time()
save(ergm.output, file = model_fit_save)

summary(ergm.output)
ergm.output$mle.lik
mcmc.diagnostics(ergm.output)
goffit <- gof(ergm.output, GOF=~model)
par(mfrow = c(1,1))
plot(goffit)
goffit2 <-gof(ergm.output)
plot(goffit2)

hold <- summary(ergm.output)
stargazer(hold$coefs, summary = FALSE)


sink(save_name)
summary(ergm.output)

cat("\n\n===========")
cat("\nDiagnostics\n")
cat("=========== \n")

mcmc.diagnostics(ergm.output)
stargazer(hold$coefs, summary = FALSE)
sink()

write_ergm_results(ergm.output, ergm_results_name)


#stargazer(summary(ergm.output1995)$coefs, summary(ergm.output2006)$coefs,summary = FALSE)
