
# DESCRIPTION: Recreates Network Variables using the partial sample
library(foreign)
library(plyr)
library(doBy)
library(data.table)
library(tidyr)

data_path = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\partial_dataset_60-ctrys_50-pct_95-06_full_sample_network_vars.csv"
save_path = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\partial_dataset_60_ctrys_50_pct_95-06_partial_sample_network_stats.csv"


in_data =read.csv(data_path)
in_data = in_data[, !(names(in_data) %in% c("recip_dummy","recip_exp", "transitive_value", "transitive_count", "cyclical_value", "cyclical_count", "importer_imp_degree", "importer_exp_degree", "exporter_exp_degree", "exporter_imp_degree"))]

firstyear <- 1995
lastyear <- 2006
adjmats <- vector("list", (2006 - 1995 + 1))

count <- 1
for(yr in firstyear:lastyear){
    print(yr)

    in_data_yr = subset(in_data, year == yr)
    adjmat <- subset(in_data_yr, select=c('importer', 'exporter', 'traded'))
    adjmat <- spread(adjmat, exporter, traded)
    adjmat[is.na(adjmat)] <- 0
    adjmats[[count]] <- adjmat


    
    # Change the format of the adjacency matrix.
    adjmathold <- adjmats[[count]] #Grabs a specific year adjaceny matrix
    
    adjrows <- as.vector(adjmathold$importer) #Creates a vector of rox names for the importers
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

write.csv(combineddata, file = save_path)

# One-time use code for combining old data with new so as to not have to run the entire data generation process again.
#combineddata.degree <- subset(combineddata, select = c("importer", "exporter", "year", "importer_imp_degree", "importer_exp_degree", "exporter_exp_degree", "exporter_imp_degree"))
#combineddata.triangles <- subset(combineddata, select = -c("importer_imp_degree", "importer_exp_degree", "exporter_exp_degree", "exporter_imp_degree"))
#combineddata.triangles <- combineddata[1:23]
#combineddata <- merge(combineddata.triangles, combineddata.degree, by.x = c("importer", "exporter", "year"), by.y = c("importer", "exporter", "year"))
