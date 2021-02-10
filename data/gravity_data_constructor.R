## GRAVITY With Network Characteristics
library(foreign)
library(plyr)
library(doBy)
library(data.table)
library(tidyr)

#------------
# Set directories
#------------

working_directory = "D:\\work\\Peter_Herman\\projects\\trade_network_revisions_2020\\submission_files\\data"
country_name_concordance = "D:\\work\\Peter_Herman\\projects\\trade_network_revisions_2020\\submission_files\\data\\country_name_correspondence.dta"
gravity_data_path = "D:\\work\\Peter_Herman\\projects\\trade_network_revisions_2020\\submission_files\\data\\grav_data_1995to2015.csv"
baci_data_path = "P:\\Documents\\Working Papers\\Data Various\\BACI"



#--------
# Conbstruct Data
#--------


setwd(working_directory)
namecorrespondence <- read.dta(country_name_concordance)
namecorrespondence <- unique(subset(namecorrespondence, select = c("CountryCode", "ISO3digitAlpha")))
cepii.grav <- read.dta(gravity_data_path)
count <- 1

#Prep Countrylist
cepii.grav <- subset(cepii.grav, year >=1995)
missinggrav<- subset(cepii.grav, is.na(cepii.grav$gdp_o|cepii.grav$gdp_d ))
origins <- unique(cepii.grav$iso3_o)
destinations <- unique(cepii.grav$iso3_d)
countrypairs <- expand.grid(origins,destinations)
colnames(countrypairs)<-c("importer","exporter")

firstyear <- 1995
lastyear <- 2006
adjmats <- vector("list", (lastyear - firstyear + 1)) #input number of years considered
for (yr in firstyear:lastyear){
  print(yr)
  bldata <- read.csv(paste(baci_data_path,"\\baci92_",yr,".csv", sep = ""), header = TRUE)
  bldata <- rename(bldata, c("i"="exporter", "j" = "importer", "v" = "trade_value", "t" = "year", "q"= "quantity"))
  
  
  bldata <- summaryBy(trade_value ~ importer + exporter + year, data = bldata, FUN = sum)
  
  #Replace CountryCode with ISO3
  bldata <- merge(bldata, namecorrespondence,  by.x = "exporter", by.y = "CountryCode", all.x = TRUE)
  bldata <- subset(bldata, select = c("importer", "trade_value.sum", "year", "ISO3digitAlpha" ))
  bldata <- rename(bldata, c("ISO3digitAlpha" = "exporter"))
  bldata <- merge(bldata, namecorrespondence,  by.x = "importer", by.y = "CountryCode", all.x = TRUE)
  bldata <- subset(bldata, select = c("exporter", "trade_value.sum", "year", "ISO3digitAlpha" ))
  bldata <- rename(bldata, c("ISO3digitAlpha" = "importer", "trade_value.sum" = "trade_value"))
  bldata <- subset(bldata, importer != "NULL" & exporter != "NULL")  #Gets rid of  a handful of trade flows between unnamed countries (e.g.other asia areas unspecified).
  bldata <- summaryBy(trade_value ~ importer + exporter + year, data = bldata, FUN = sum)  #Sums again for the occational issue where one ISO3 code has more than one countrycode associated with it.  
  
  #merge trade flows with country pair list
  bldata <- merge(countrypairs, bldata,by.x = c("importer","exporter"), by.y = c("importer","exporter"), all.x=TRUE)
  bldata$year[is.na(bldata$year)] <- yr
  bldata$trade_value[is.na(bldata$trade_value)] <- 0
  
  #Create Adjacency Matrix
  adjmat <- subset(bldata, select=c("importer","exporter","trade_value"))
  adjmat <- spread(adjmat, exporter, trade_value)
  adjmats[[count]] <- adjmat
  
  
  
  
  
  
  
  ifelse(count == 1, combineddata <- bldata, combineddata <- rbind(combineddata,bldata))
  count <- count+1
  
  

} 

names(adjmats) <- firstyear:lastyear #Names the items in the adjacency list
combineddata <- subset(combineddata, select = c("importer", "exporter","year", "trade_value"))
save(combineddata, file = "combineddata_temp.rda")
save(adjmats, file = "adjmats.rds")


## Part 2: Adding Gravity Data

#load("combineddata_temp.rda")
#load("adjmats.rds")

combineddata <- subset(combineddata, year <= 2006) #cepii data stops in 2006
cepii.grav <- read.dta(gravity_data_path)
cepii.grav <- subset(cepii.grav, select = (c("iso3_o","iso3_d","year","contig","comlang_off","comlang_ethno","comcol", "distw", "gdp_o", "gdp_d", "gdpcap_o","gdpcap_d","colony", "gatt_o", "gatt_d", "rta", "comcur")))

combineddata <- merge(combineddata, cepii.grav, by.x = c("importer", "exporter", "year"), by.y = c("iso3_d", "iso3_o", "year"), all.x = TRUE )

## Part 3: Computing network attributes
count <- 1
for(yr in firstyear:lastyear){
  print(yr)
  # Change the format of the adjacency matrix.
  adjmathold <- adjmats[[count]] #Grabs a specific year adjaceny matrix
  adjrows <- as.vector(adjmathold$importer) #Creates a vector of rox names for the importers
  adjmathold <- as.matrix(subset(adjmathold, select = -c(importer))) #Creates a matrix without the first column of country names
  row.names(adjmathold) <- adjrows #names the rows of the dajacency matrix
  
  
  networkdata <- countrypairs #Initializes a data frame to store the network variable to be generated
  networkdata$recip.exp <- 0 #Creates a variable for reciprocal exports (i.e. for trade i <- j, does there exist trade from i -> j?)
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
    networkdata$recip.exp[[k]] <- adjmathold[networkdata$exporter[k],  networkdata$importer[k]] #for each country pair (i,j), it assigns the value of cell (j,i) in the adjacency matrix
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
    
    ##Degree                                      if A_ij > 0, then sum_k(A_ik/A_ik) - 1, else sum_k(A_ik/A_ik)
    networkdata$importer_imp_degree[k] <- ifelse(adjmathold[networkdata$importer[k],  networkdata$exporter[k]]>0, sum(adjmathold[networkdata$importer[k],]/adjmathold[networkdata$importer[k],], na.rm = TRUE)-1, sum(adjmathold[networkdata$importer[k],]/adjmathold[networkdata$importer[k],],na.rm = TRUE)) #calculates importer import degree (indegree) excluding the current link.
    networkdata$importer_exp_degree[k] <- sum(adjmathold[,networkdata$importer[k]]/adjmathold[,networkdata$importer[k]], na.rm = TRUE) #calculates importer export degree (indegree) excluding the current link.
    networkdata$exporter_exp_degree[k] <- ifelse(adjmathold[networkdata$importer[k], networkdata$exporter[k]]>0, sum(adjmathold[,networkdata$exporter[k]]/adjmathold[,networkdata$exporter[k]],na.rm = TRUE)-1, sum(adjmathold[,networkdata$exporter[k]]/adjmathold[,networkdata$exporter[k]],na.rm = TRUE)) #calculates importer import degree (indegree) excluding the current link.
    networkdata$exporter_imp_degree[k] <- sum(adjmathold[networkdata$exporter[k],]/adjmathold[networkdata$exporter[k],], na.rm = TRUE) #calculates importer import degree (indegree) excluding the current link.
    print(c(yr,k/length(networkdata$importer)))
  
    }
  
 
  
  
  
  
  
  networkdata$year <-yr #Assigns the year to each observation
  ifelse(count == 1, nwdata <- networkdata, nwdata <- rbind(nwdata, networkdata)) #On the first cycle, it saves the data to a new frame nwdata, on following cycles, it is appended 
  count <- count+1 
} #end year loop
  

combineddata <- merge(combineddata, nwdata, by.x = c("importer", "exporter", "year"), by.y = c("importer", "exporter", "year"))

save(combineddata, file = "gravity_estimation_data.rda")

# One-time use code for combining old data with new so as to not have to run the entire data generation process again.
#combineddata.degree <- subset(combineddata, select = c("importer", "exporter", "year", "importer_imp_degree", "importer_exp_degree", "exporter_exp_degree", "exporter_imp_degree"))
#combineddata.triangles <- subset(combineddata, select = -c("importer_imp_degree", "importer_exp_degree", "exporter_exp_degree", "exporter_imp_degree"))
#combineddata.triangles <- combineddata[1:23]
#combineddata <- merge(combineddata.triangles, combineddata.degree, by.x = c("importer", "exporter", "year"), by.y = c("importer", "exporter", "year"))
