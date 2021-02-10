## Modifies some aspects of the BACI data. Input BACI data, outputs a list of 
BACI.data.prep <- function(data, dropcountries, countrylist.path){
  #data <- subset(data, exporter != "NULL" & importer != "NULL") #Old way of doing the following line
  data <- subset(data, !(exporter %in%  dropcountries) & !(importer %in%  dropcountries))
  data$hs6 <- formatC(data$hs6, width = 6, format = "d", flag = "0") #Fills all data to 6 digits by adding a zero infront.
  data$hs4 <- substring(data$hs6, 1,4) 
  data$hs2 <- substring(data$hs6, 1,2)
  #Create list of Countries (for the BACI data, "i" and "j" are the names of the variables for importers and exporters)
  #importer.countries <- as.matrix(unique(data$importer))
  #exporter.countries <- as.matrix(unique(data$exporter))
  #countries <- unique(rbind(importer.countries, exporter.countries)) #A list of the unique countries in the data.
  #countries <- countries[order(countries)]
  
  ## \-> Just use the premaid list
  countrylist <- read.csv("G:\\data\\Peter Herman\\Trade Network Reserach\\Data\\207countrylist.csv")
  countrylist <- countrylist$x
  countrylist <-countrylist[order(countrylist)]
  prepped.data = list("data"=data, "countries"=countrylist) 
  return(prepped.data)
}

countrycode.replacer <- function(data, code.correspondence.path){
  # Load alternative coutry names and replace original IDs in data
  require(tidyr) 
  iso.names <- read.dta(code.correspondence.path) 
  datatemp <- merge(data, iso.names, by.x = "i", by.y = "CountryCode", all.x = TRUE)
  datatemp$exporter <- datatemp$ISO3digitAlpha 
  datatemp <- subset(datatemp, select = c("t","hs6", "j", "v", "q", "exporter"))
  datatemp <- merge(datatemp, iso.names, by.x = "j", by.y = "CountryCode", all.x = TRUE)
  datatemp$importer <- datatemp$ISO3digitAlpha
  datatemp <- subset(datatemp, select = c("t","hs6", "v", "q", "exporter", "importer"))
  return(datatemp)
}



#Creates a network structure without isolates
hs.network.noisolates <- function(hs6code, data, countries)
{
  data.sub <- subset(data, hs6 == hs6code)
  temp = as.matrix(data.frame(data.sub$exporter, data.sub$importer))
  sub.network <- network(temp, vertex.attrnames = countries, matrix.type = "edgelist")
  return(sub.network)
}





#Creates a network structure with isolates
hs.network.isolates <- function(hs6code, data)
{data.sub <- subset(data$data, hs6 == hs6code)
temp = as.matrix(data.frame(data.sub$exporter, data.sub$importer))
sub.network <- network.initialize(dim(data$countries)[1])#WARNING: may need to change "dim" to "length" after sorting countries (see agg version)
network.vertex.names(sub.network) <- as.character(data$countries)
sub.network[as.matrix(temp),] <- 1
return(sub.network)
}




#Creates a network structure with isolates
hs4.network.isolates <- function(hs4code, data)
{data.sub <- subset(data$data, hs4 == hs4code)
temp = as.matrix(data.frame(data.sub$exporter, data.sub$importer))
sub.network <- network.initialize(dim(data$countries)[1]) #WARNING: may need to change "dim" to "length" after sorting countries (see agg version)
network.vertex.names(sub.network) <- as.character(data$countries)
sub.network[as.matrix(temp),] <- 1
return(sub.network)
}


hs2.network.isolates <- function(hs2code, data)
{data.sub <- subset(data$data, hs2 == hs2code)
temp = as.matrix(data.frame(data.sub$exporter, data.sub$importer))
sub.network <- network.initialize(dim(data$countries)[1]) #WARNING: may need to change "dim" to "length" after sorting countries (see agg version)
network.vertex.names(sub.network) <- as.character(data$countries)
sub.network[as.matrix(temp),] <- 1
return(sub.network)
}

agg.network.isolates <- function(data)
{
temp = as.matrix(unique(data.frame(data$data$exporter, data$data$importer)))
sub.network <- network.initialize(length(data$countries))
network.vertex.names(sub.network) <- as.character(data$countries)
sub.network[as.matrix(temp),] <- 1
return(sub.network)
}


agg.network.fast <- function(data ) 
{
  require(foreign)
  countrypairs <- expand.grid(data$countries, data$countries)
  colnames(countrypairs) <- c( "iso3_o","iso3_d")
  trade = unique(data.frame(data$data$exporter, data$data$importer))
  trade$value <- 1
  allflows <- merge(countrypairs, trade, by.x = c("iso3_o", "iso3_d"), by.y = c("data.data.exporter", "data.data.importer"), all.x = TRUE ) 
  require(tidyr)
  allflows.adj <- spread(allflows,iso3_d, value)
  rownames(allflows.adj) <- as.vector(allflows.adj$iso3_o)
  allflows.adj <- as.matrix(subset(allflows.adj, select = -c(iso3_o)))
  allflows.adj[is.na(allflows.adj)] <- 0
  agg.network2 <- network::network(allflows.adj, loops = FALSE)
  network.vertex.names(agg.network2) <- as.character(data$countries)
  return(agg.network2)
  
}


agg.network.fast.update <- function(data ) 
{
  require(foreign)
  require(tidyr)
  require(statnet)
  
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
  agg.network2 <- network(allflows.adj, loops = FALSE)
  # Set node names
  network.vertex.names(agg.network2) <- as.character(data$countries)
  return(agg.network2)
  
}


HS2sector.network.fast <- function(data, hscode ) 
{
  require(foreign)
  countrypairs <- expand.grid(data$countries, data$countries)
  colnames(countrypairs) <- c( "iso3_o","iso3_d")
  trade <- subset(data$data, hs2 == hscode)
  trade = unique(data.frame(trade$exporter, trade$importer))
  trade$value <- 1
  allflows <- merge(countrypairs, trade, by.x = c("iso3_o", "iso3_d"), by.y = c("trade.exporter", "trade.importer"), all.x = TRUE ) 
  require(tidyr)
  allflows.adj <- spread(allflows,iso3_d, value)
  rownames(allflows.adj) <- as.vector(allflows.adj$iso3_o)
  allflows.adj <- as.matrix(subset(allflows.adj, select = -c(iso3_o)))
  allflows.adj[is.na(allflows.adj)] <- 0
  agg.network2 <- network(allflows.adj, loops = FALSE)
  network.vertex.names(agg.network2) <- as.character(data$countries)
  return(agg.network2)
  
}


agg.network.isolates.attributes <- function(data, node.atts)
{
  temp = as.matrix(unique(data.frame(data$data$exporter, data$data$importer)))
  sub.network <- network.initialize(dim(data$countries)[1])#WARNING: may need to change "dim" to "length" after sorting countries (see agg version)
  network.vertex.names(sub.network) <- as.character(data$countries)
  sub.network[as.matrix(temp),] <- 1
  
  
  return(sub.network)
}



hs2.massnetworks.isolates.alt <- function(hscodes, data)
{
num.codes <-length(hscodes)
hs2.networks <- vector("list", num.codes)
for (q in 1:num.codes){
  hs2.networks[[q]] <- hs2.network.isolates(hscodes[[q]],data)
}
names(hs2.networks) <- hscodes
return(hs2.networks)
}








outlinks <- function(network, countryiso)
{
  return(cbind(data$countries, network[countryiso,]))
}  

inlinks <- function(network, countryiso)
{
  return(cbind(data$countries, network[,countryiso]))
}  


write_ergm_results_2 <- function(ergm_output, file_name = "ergm_results", results_location = ""){
  time_stamp = format(Sys.time(), "%Y-%m-%d_%H-%M")
  file_name_new = paste(file_name ,"_", time_stamp, ".txt", sep = "")
  print(file_name_new)
  fileConn<-file(file_name_new)
  writeLines(paste("File Name: ", file_name_new, sep = ""), fileConn)
  #writeLines(summary(ergm_output), fileConn)
  
  #cat("\n\n===========")
  #cat("\nDiagnostics\n")
  #cat("===========\n\n")
  #mcmc.diagnostics(ergm.output)
  
  #cat("\n\n=================")
  #cat("\nCoefficient Table\n")
  #cat("=================\n\n")
  #summary(ergm.output)$coefs
  #stargazer(summary(ergm.output)$coefs, summary = FALSE)
  close(fileConn)
}



write_ergm_results <- function(ergm_output, file_name = "ergm_results"){
  # This function sends certain results to a text file. It also sends diagnostic plots to 
  #     a pdf file. 
  # atr:
  #     ergm_output: (obj) an object returned from  ergm() [statnet]
  #     file_name: (str) a file name (e.g. "results.txt").
  
  time_stamp = format(Sys.time(), "%Y-%m-%d_%H-%M")
  file_name_new = paste(file_name ,"_", time_stamp, ".txt", sep = "")
  file_name_figure = paste(file_name ,"_", time_stamp,"_", sep = "")
  print(file_name_new)
  
  # Open file and create header
  sink(file_name_new)
  paste("File Name: ", file_name_new, sep = "")
  cat("\n \n")
  
  # Print ERGM summary
  print(summary(ergm_output))
  
  # Print Diagnostics
  cat("\n\n===========")
  cat("\nDiagnostics\n")
  cat("===========\n\n")
  # Open a pdf to store diagnostic plats in.
  pdf(paste(file_name_figure,"diagnostic_plots.pdf", sep = "_"))
  mcmc.diagnostics(ergm_output)
  dev.off()
  
  # Add goodness of fit
  cat("\n\n===============")
  cat("\nGoodness-of-fit\n")
  cat("===============\n\n")
  
  # Gof with only model attributes
  cat("* GoF with Model Attributes *")
  gof_fit_model <- gof(ergm_output, GOF=~model)
  print(gof_fit_model)
  par(mfrow = c(1,1))
  
  # Gof with alternative terms
  cat("\n\n* GoF with Default Terms *")
  gof_fit_default <-gof(ergm_output)
  ergm_gof = gof_fit_default
  save(ergm_gof, file = paste(file_name_new, "_gof_obj.rda", sep = ""))
  print(gof_fit_default)
  
  pdf(paste(file_name_figure,"gof_plots.pdf", sep = "_"))
  plot(gof_fit_model)
  plot(gof_fit_default)
  dev.off()
  
  # Add a coefficient table
  cat("\n\n=================")
  cat("\nCoefficient Table\n")
  cat("=================\n\n")
  print(summary(ergm_output)$coefs)
  #stargazer(summary(ergm_output)$coefs, summary = FALSE)
  sink()
}


store_gof_results <- function(gof_obj){
  
}
