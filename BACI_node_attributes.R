

BACI.node.attribute.builder <- function(data, cepii.geo.path, cepii.grav.path, EEA.entry, year.used){ 
# INPUTS: "data" is what is returned from BACI.Data.Prep.
#         "cepii.geo.path" is the file name and/or path for the geo.cepii data
#         "cepii.grav.path" is the file name and/or path for the geo.gravity data

library(foreign)
require(tidyr)
countrylist <- as.data.frame(data$countries)
countrylist <- rename(countrylist, c("data$countries"="iso3"))
cepii.geo <- read.dta(cepii.geo.path)
cepii.grav <- read.dta(cepii.grav.path)
EEA.entry <- read.csv(EEA.entry.path, header = TRUE, sep = ',')

geo.keep <- c("iso3", "continent", "lang20_1", "lang20_2", "lang20_3","lang20_4", "colonizer1", "colonizer2", "colonizer3", "colonizer4") #list of variables to keep
cepii.geo <- unique(cepii.geo[geo.keep]) #DRops duplicates (some countries have multiple listings due to multiple major cities (e.g. New York City and Washington))
country.atts <- merge(countrylist, cepii.geo, by.x = "iso3", by.y = "iso3", all.x=TRUE) #all.x = TRUE keeps unmatched countries from the countrylist.

grav.keep <- c("iso3_o", "gdp_o", "gdpcap_o", "gatt_o") #List of grav variables to keep
cepii.grav <- subset(cepii.grav, year == year.used) #keeps only the desired year.
cepii.grav <- unique(cepii.grav[grav.keep]) 
country.atts <- merge(country.atts, cepii.grav, by.x = "iso3", by.y = "iso3_o", all.x=TRUE)

##GDP Measures
country.atts <- country.atts[order(-country.atts$gdp_o),] #Sorts on GDP
GDP.top20 <- head(country.atts, n = 20L) #Graps first observations
GDP.top20 <- as.vector(GDP.top20["iso3"]) #converts to vector
country.atts$gdp.top20 <- ifelse(country.atts$iso3 %in% as.character(GDP.top20[,1]) ,1,0) #generates variable = 1 if the country is in the list of top countries.
GDP.top50 <- head(country.atts, n = 50L)
GDP.top50 <- as.vector(GDP.top50["iso3"])
country.atts$gdp.top50 <- ifelse(country.atts$iso3 %in% as.character(GDP.top50[,1]) ,1,0)


## Languages
country.atts$english <- ifelse(country.atts$lang20_1 == "English" |country.atts$lang20_2 == "English" | country.atts$lang20_3 == "English" | country.atts$lang20_4 == "English" ,1,0)
country.atts$french <- ifelse(country.atts$lang20_1 == "French" |country.atts$lang20_2 == "French" | country.atts$lang20_3 == "French" | country.atts$lang20_4 == "French" ,1,0)
country.atts$spanish <- ifelse(country.atts$lang20_1 == "Spanish" |country.atts$lang20_2 == "Spanish" | country.atts$lang20_3 == "Spanish" | country.atts$lang20_4 == "Spanish" ,1,0)

#Colonizers
country.atts$colGBR <- ifelse(country.atts$colonizer1 == "GBR" |country.atts$colonizer2 == "GBR" | country.atts$colonizer3 == "GBR" | country.atts$colonizer4 == "GBR" ,1,0)
country.atts$colFRA <- ifelse(country.atts$colonizer1 == "FRA" |country.atts$colonizer2 == "FRA" | country.atts$colonizer3 == "FRA" | country.atts$colonizer4 == "FRA" ,1,0)
country.atts$colESP <- ifelse(country.atts$colonizer1 == "ESP" |country.atts$colonizer2 == "ESP" | country.atts$colonizer3 == "ESP" | country.atts$colonizer4 == "ESP" ,1,0)

#NAFTA
if( year.used >= 1994){
  nafta.members <- c("USA", "CAN", "MEX")
  country.atts$nafta <- ifelse(country.atts$iso3 %in% nafta.members,1,0) 
}

#EEA 
country.atts <- merge(country.atts, EEA.entry, by.x = "iso3", by.y = "X", all.x=TRUE)
country.atts$eea <- ifelse(country.atts$EEA_entry<= year.used,1,0)
country.atts$eea[is.na(country.atts$eea)] <- 0

#Region
country.atts$americas <- ifelse(country.atts$continent == "America",1,0)
country.atts$europe <- ifelse(country.atts$continent == "Europe",1,0)
country.atts$africa <- ifelse(country.atts$continent == "Africa",1,0)
country.atts$asia <- ifelse(country.atts$continent == "Asia",1,0)
country.atts$pacific <- ifelse(country.atts$continent == "Pacific",1,0)


keep <- c("iso3", "continent","gatt_o", "gdp.top20", "gdp.top50", "english", "french", "spanish", "colGBR", "colFRA", "colESP", "nafta", "eea", "americas", "europe" , "africa" , "asia" , "pacific")
#keep <- c("V1", "gatt_o", "gdp.top20", "gdp.top50", "english", "french", "spanish", "colGBR", "colFRA", "colESP", "nafta", "eea")
country.atts <- subset(country.atts, select = keep)
country.atts <- country.atts[order(country.atts$iso3),]
return(country.atts)
}


network.attribute.appender <- function(sub.network, node.atts){
  #sub.network %v% "iso3" <- as.vector(node.atts$iso3)
  #sub.network %v% "continent" <- node.atts$continent
  #sub.network %v% "gatt" <- node.atts$gatt_o
  #sub.network %v% "gdp.top20" <- node.atts$gdp.top20
  #sub.network %v% "gdp.top50" <- node.atts$gdp.top50
  #sub.network %v% "english" <- node.atts$english
  #sub.network %v% "french" <- node.atts$french
  #sub.network %v% "spanish" <- node.atts$spanish
  #sub.network %v% "colGBR" <- node.atts$colGBR
  #sub.network %v% "colFRA" <- node.atts$colFRA
  #sub.network %v% "colESP" <- node.atts$colESP
  #sub.network %v% "nafta" <- node.atts$nafta
  #sub.network %v% "eea" <- node.atts$eea
  return(sub.network)
}




subnetwork.unvalued <- function(data, cepii.grav, linktype, yr) #creates an unvalued network
{
  require(foreign)
  countrypairs <- expand.grid(data$countries, data$countries)
  colnames(countrypairs) <- c( "iso3_o","iso3_d")
  cepii.grav <- subset(cepii.grav, select = c("iso3_o","iso3_d", "year", linktype ))
  cepii.grav <- subset(cepii.grav,  year == yr)
  cepii.grav <- subset(cepii.grav, select = c("iso3_o","iso3_d", linktype ))
  subdata <- merge(countrypairs, cepii.grav, by.x = c("iso3_o", "iso3_d"), by.y = c("iso3_o", "iso3_d"), all.x = TRUE )
  subdata <- unique(subdata)
  subdata <- subset(subdata, subdata[[3]] == 1)
  subdata <- subset(subdata, select = c("iso3_o", "iso3_d"))
  #  temp = as.matrix(unique(data.frame(data$data$exporter, data$data$importer)))
  sub.network <- network.initialize(length(data$countries))
  network.vertex.names(sub.network) <- as.character(data$countries)
  temp1 <- as.matrix(subdata)
  sub.network[as.matrix(temp1),] <- 1
  return(sub.network)
}

subnetwork.valued.edge.attribute <- function(data, edge.att, yr, cepii.grav) 
{
  require(foreign)
  countrypairs <- expand.grid(data$countries, data$countries)
  colnames(countrypairs) <- c( "iso3_o","iso3_d")
  cepii.grav <- subset(cepii.grav, select = c("iso3_o","iso3_d", "year", edge.att ))
  cepii.grav <- subset(cepii.grav,  year == yr)
  cepii.grav <- subset(cepii.grav, select = c("iso3_o","iso3_d", edge.att ))
  subdata <- merge(countrypairs, cepii.grav, by.x = c("iso3_o", "iso3_d"), by.y = c("iso3_o", "iso3_d"), all.x = TRUE ) 
  require(tidyr)
  require(dplyr)
  colnames(subdata) <- c("iso3_o", "iso3_d", "att")
  subdata.adj <- spread(subdata,iso3_d, att)
  rownames(subdata.adj) <- as.vector(subdata.adj$iso3_o)
  subdata.adj <- as.matrix(subset(subdata.adj, select = -c(iso3_o)))
  subnetwork <- network(subdata.adj, loops = FALSE, ignore.eval = FALSE, names.eval = edge.att)
  return(subnetwork)
  #set.edge.attribute(agg.network, edge.att, subdata.adj)
}


node.attribute.adder <- function(trade.network, data, cepii.grav, year.used, attrib)
#an updated version of the previous one based on my updated needs.
{ 
  countrylist <- data.frame(data$countries)
  keepers <- c("iso_o", "year", attrib)
  cepii.unilateral <- subset(cepii.grav, select = c("iso3_o" , "year"  , attrib))
  cepii.unilateral <- unique(subset(cepii.unilateral, year == year.used))
  node.att.mat <- merge(countrylist, cepii.unilateral, by.x = c("data.countries"), by.y = c("iso3_o"), all.x = TRUE)
  node.att.mat[is.na(node.att.mat)] <- quantile(cepii.unilateral$gdp_o, .1, na.rm = TRUE)
  agg.network %v% attrib <- node.att.mat[,3]                           
  return(agg.network)                           
  }
  
node.gdp.adder <- function(trade.network, data, year.used)
  #Uses the world bank data for GDP
{ gdp.data <- read.dta("P:\\Documents\\Working Papers\\Data Various\\World Bank GDPs.dta")
  countrylist <- data.frame(data$countries)
  keepers <- c("countrycode", "year", "GDP")
  
  gdp.data <- unique(subset(gdp.data, year == year.used))
  node.att.mat <- merge(countrylist, gdp.data, by.x = c("data.countries"), by.y = c("countrycode"), all.x = TRUE)
  #node.att.mat[is.na(node.att.mat)] <- 
  agg.network %v% attrib <- node.att.mat[,3]                           
  return(agg.network)                           
} 

identify.missingdata.countries <- function(data, cepii.grav, yr, varbls)
{
  
  require(foreign)
  countrypairs <- expand.grid(data$countries, data$countries)
  colnames(countrypairs) <- c( "iso3_o","iso3_d")
  cepii.grav <- subset(cepii.grav, select = c("iso3_o","iso3_d", "year", varbls ))
  cepii.grav <- subset(cepii.grav,  year == yr)
  cepii.grav <- subset(cepii.grav, select = c("iso3_o","iso3_d", varbls ))
  subdata <- merge(countrypairs, cepii.grav, by.x = c("iso3_o", "iso3_d"), by.y = c("iso3_o", "iso3_d"), all.x = TRUE )
  subdata <- subdata[ !complete.cases(subdata), ]
  subdata <- subset(subdata, iso3_o != iso3_d)
  return(subdata)
}
