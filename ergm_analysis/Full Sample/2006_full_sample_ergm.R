#rm(list = ls())
library(statnet)
library(foreign)





setwd("D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\ergm_analysis\\Full Sample") #USITC Laptop



source("D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\ergm_analysis\\BACI.functions.R")
source("D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\ergm_analysis\\BACI_node_attributes.R")


## Load data sources
#To change year, alter both the "data <- read.csv" line and the "year.used" line 
year.used <- 2006
data <- read.csv("file:///P:\\Documents\\Working Papers\\Data Various\\BACI (HS92)\\baci92_2004.csv", header = TRUE, sep = ",")


data <- countrycode.replacer(data, "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\country_name_correspondence.dta")


countrylist.path = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\207countrylist.csv"
cepii.geo.path = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\geo_cepii.dta"
cepii.grav.path = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\grav_data_1995to2015.csv"
#EEA.entry.path = "P:\\Documents\\Working Papers\\Data Various\\EEA Entry Dates.csv"

dropcountries <- c("NULL","ARB", "ATF", "COD", "IOT", "SCG") #missing grav data at least.

#Prepwork

data <- BACI.data.prep(data, dropcountries) #Preps the data a bit more.  Also adds in a second list item containing a list of countries.
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
save(ergm.output, file = "2006_model_fit.rda")

#summary(ergm.output.2004)
#ergm.output.2004$mle.lik
#pdf("diagnostic_plots_2004.pdf")
#mcmc.diagnostics(ergm.output.2004)
#dev.off()
#goffit <- gof(ergm.output.2004, GOF=~model)
#par(mfrow = c(1,1))
#goffit2 <-gof(ergm.output.2004)
#pdf("gof_plots_2004.pdf")
#plot(goffit)
#plot(goffit2)
#dev.off()

write_ergm_results(ergm.output, "2006_full_sample_results")
#require(stargazer)
#hold <- summary(ergm.output.2004)
#stargazer(hold$coefs, summary = FALSE)

#stargazer(summary(ergm.output.20041995)$coefs, summary(ergm.output.20042006)$coefs,summary = FALSE)
