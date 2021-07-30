"C:\Program Files\Microsoft\R Open\R-4.0.2\bin\x64\R.exe"

# DESCRIPTION: Recreates Network Variables using the partial sample
library(foreign)
library(plyr)
library(doBy)
library(data.table)
library(tidyr)

data_path = "ergm_analysis\\HS 50 countries\\data\\ppml_hs51_panel_top50.dta"
save_path = "comparisons\\HS51\\partial_data_set_hs51_top50_with_ntw_vars.csv"
grav_path = "data\\grav_data_1995to2015.csv"

# Load Data
in_data =foreign::read.dta(data_path)
in_data$traded = 0
in_data$traded[in_data$trade_value >0] = 1

# Set dimensions for network var construction
firstyear <- 1995
lastyear <- 2006
adjmats <- vector("list", (2006 - 1995 + 1))

count <- 1
for(yr in firstyear:lastyear){
    print(yr)
    # Grab specific year
    in_data_yr = subset(in_data, year == yr)
    # Select only country IDs and trade indicator
    adjmat <- subset(in_data_yr, select=c('importer', 'exporter', 'traded'))
    # Reshape to adjacency matrix
    adjmat <- spread(adjmat, exporter, traded)
    # Replace missing with zero
    adjmat[is.na(adjmat)] <- 0
    # Send to list
    adjmats[[count]] <- adjmat


    
    # Change the format of the adjacency matrix.
    adjmathold <- adjmats[[count]] #Grabs a specific year adjaceny matrix
    
    adjrows <- as.vector(adjmathold$importer) #Creates a vector of row names for the importers
    adjmathold <- as.matrix(subset(adjmathold, select = -c(importer))) #Creates a matrix without the first column of country names
    row.names(adjmathold) <- adjrows #names the rows of the dajacency matrix


    networkdata <- subset(in_data_yr, select = c('importer', 'exporter')) #Initializes a data frame to store the network variable to be generated
    networkdata$recip_exp <- 0 #Creates a variable for reciprocal exports (i.e. for trade i <- j, does there exist trade from i -> j?)
    networkdata$transitive_value <- 0
    networkdata$transitive_count <- 0
    networkdata$cyclical_value <- 0
    networkdata$cyclical_count <- 0
    networkdata$importer_imp_degree <- 0
    networkdata$importer_exp_degree <- 0
    networkdata$exporter_exp_degree <- 0
    networkdata$exporter_imp_degree <- 0

    for(k in 1:length(networkdata$importer)){ #cycles through each country-pair
        ## Mutual
        networkdata$recip_exp[[k]] <- adjmathold[networkdata$exporter[k],  networkdata$importer[k]] #for each country pair (i,j), it assigns the value of cell (j,i) in the adjacency matrix
                #e.g. for pair "USA" "GBR" <- adjmathold["GBR","USA"]

        ## Transitive
        tranval <- 0
        trancnt <- 0
        cyclval <- 0
        cyclcnt <- 0
        for (m in 1:length(adjrows)){
            tranval <- tranval + adjmathold[networkdata$importer[k], adjrows[m]]*adjmathold[adjrows[m],networkdata$exporter[k]]
            trancnt <- trancnt + ifelse(adjmathold[networkdata$importer[k], adjrows[m]]*adjmathold[adjrows[m],networkdata$exporter[k]] >0,1,0)
            cyclval <- cyclval + adjmathold[networkdata$exporter[k],adjrows[m]]*adjmathold[adjrows[m],networkdata$importer[k]]
            cyclcnt <- cyclcnt + ifelse(adjmathold[networkdata$exporter[k],adjrows[m]]*adjmathold[adjrows[m],networkdata$importer[k]] >0,1,0)
        }
        networkdata$transitive_value[[k]] <- tranval
        networkdata$transitive_count[[k]] <- trancnt
        networkdata$cyclical_value[[k]] <- cyclval
        networkdata$cyclical_count[[k]] <- cyclcnt

        ##Degree
        networkdata$importer_imp_degree[k] <- ifelse(adjmathold[networkdata$importer[k],  networkdata$exporter[k]]>0, sum(adjmathold[networkdata$importer[k],]/adjmathold[networkdata$importer[k],], na.rm = TRUE)-1, sum(adjmathold[networkdata$importer[k],]/adjmathold[networkdata$importer[k],],na.rm = TRUE)) #calculates importer import degree (indegree) excluding the current link.
        networkdata$importer_exp_degree[k] <- sum(adjmathold[,networkdata$importer[k]]/adjmathold[,networkdata$importer[k]], na.rm = TRUE) #calculates importer export degree (indegree) excluding the current link.
        networkdata$exporter_exp_degree[k] <- ifelse(adjmathold[networkdata$importer[k], networkdata$exporter[k]]>0, sum(adjmathold[,networkdata$exporter[k]]/adjmathold[,networkdata$exporter[k]],na.rm = TRUE)-1, sum(adjmathold[,networkdata$exporter[k]]/adjmathold[,networkdata$exporter[k]],na.rm = TRUE)) #calculates importer import degree (indegree) excluding the current link.
        networkdata$exporter_imp_degree[k] <- sum(adjmathold[networkdata$exporter[k],]/adjmathold[networkdata$exporter[k],], na.rm = TRUE) #calculates importer import degree (indegree) excluding the current link.
        #print(c(yr,k/length(networkdata$importer)))
        } 
    
    
    networkdata$year <-yr #Assigns the year to each observation
    if(count == 1){nwdata <- networkdata
    } else{  nwdata <- rbind(nwdata, networkdata)} #On the first cycle, it saves the data to a new frame nwdata, on following cycles, it is appended 
    count <- count+1 
}
  

combineddata <- merge(in_data, nwdata, by.x = c("importer", "exporter", "year"), by.y = c("importer", "exporter", "year"))

# add GDP 
grav_data = read.csv(grav_path)
grav_part = grav_data[,c("iso3_o", "iso3_d", "year","gdp_d","gdpcap_d", "gdp_o", "gdpcap_o")]
grav_part$lngdp_o = log(grav_part$gdp_o)
grav_part$lngdp_d = log(grav_part$gdp_d)
grav_part$lngdpcap_o = log(grav_part$gdpcap_o)
grav_part$lngdpcap_d = log(grav_part$gdpcap_d)

combineddata_2 = merge(combineddata, grav_part, by.x = c("importer", "exporter", "year"), by.y = c('iso3_d','iso3_o','year'), all.x=TRUE)


write.csv(combineddata_2, file = save_path)

