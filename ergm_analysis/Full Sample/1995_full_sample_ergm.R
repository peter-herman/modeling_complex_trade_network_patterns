#rm(list = ls())
library(statnet)
library(foreign)




# Set working directory
setwd("D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\ergm_analysis\\Full Sample") #USITC Laptop

# Set paths
countrylist.path = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\207countrylist.csv"
cepii.geo.path = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\geo_cepii.dta"
cepii.grav.path = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\grav_data_1995to2015.csv"
#EEA.entry.path = "P:\\Documents\\Working Papers\\Data Various\\EEA Entry Dates.csv"

# load functions from other files
source("D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\ergm_analysis\\BACI.functions.R")
source("D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\ergm_analysis\\BACI_node_attributes.R")


## Load data sources
#To change year, alter both the "data <- read.csv" line and the "year.used" line 
year.used <- 1995
data <- read.csv("D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\baci92_1995.csv", header = TRUE, sep = ",")

# Replace Country codes with iso3-alphas
data <- countrycode.replacer(data, "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\country_name_correspondence.dta")

# Drop some countries 
dropcountries <- c("NULL","ARB", "ATF", "COD", "IOT", "SCG") #missing grav data at least.

# Prepwork
data <- BACI.data.prep(data, dropcountries) #Preps the data a bit more.  Also adds in a second list item (attribute) containing a list of countries.
#identify.missingdata.countries(data, cepii.grav.path, year.used, c("distw","comlang_ethno", "contig", "rta", "colony"))


cepii.grav <- read.csv(cepii.grav.path)
#agg.network <- agg.network.isolates(data)
agg.network <- agg.network.fast(data)

#   Edge Attribute Generation:
#     subnetwork.valued.edge.attribute(data, edge.attribute, year, cepii.grav) is to be used for valued edge attributes. call in ergm using "edgecov(attribute.network, attrname = "edge.attribute")"
#     subnetwork.unvalued(data, cepii.grav, "comlang_ethno", year.used) may be used for unvalued edge attributes (the valued version can be used as well and returns the same estimates but is takes up more memory). Call in ergm using "edgecov(attribute.network)"
lang.network <- subnetwork.unvalued(data, cepii.grav, "comlang_ethno", year.used)
dist.network <- subnetwork.valued.edge.attribute(data, "distw", year.used, cepii.grav )
contig.network <- subnetwork.unvalued(data, cepii.grav, "contig", year.used)
rta.network <- subnetwork.unvalued(data, cepii.grav, "rta", year.used)

#Node Attribute Generators:
agg.network <- node.attribute.adder(agg.network, data, cepii.grav, year.used, "gdp_o")

#
Sys.time()

ergm.output <-  ergm( agg.network ~ edges + mutual   +   nodecov("gdp_o") + edgecov(dist.network, attrname = "distw") + edgecov(lang.network) + edgecov(contig.network) + edgecov(rta.network) ,   control=control.ergm(MCMC.burnin=1e+5, MCMC.interval=1000, MCMC.samplesize=100000, MCMLE.maxit = 100, seed=1))


Sys.time()
save(ergm.output, file = "1995_model_fit.rda")

summary(ergm.output)
ergm.output$mle.lik
mcmc.diagnostics(ergm.output)
goffit <- gof(ergm.output, GOF=~model)
par(mfrow = c(1,1))
plot(goffit)
goffit2 <-gof(ergm.output)
plot(goffit2)

require(stargazer)
hold <- summary(ergm.output)
stargazer(hold$coefs, summary = FALSE)


sink("v4_1995_results.txt")
summary(ergm.output)

cat("\n\n===========")
cat("\nDiagnostics\n")
cat("=========== \n")

mcmc.diagnostics(ergm.output)
stargazer(hold$coefs, summary = FALSE)
sink()

write_ergm_results(ergm.output, "1995_full_sample_results")


#stargazer(summary(ergm.output1995)$coefs, summary(ergm.output2006)$coefs,summary = FALSE)
