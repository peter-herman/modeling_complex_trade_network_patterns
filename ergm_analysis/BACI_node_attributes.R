
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
