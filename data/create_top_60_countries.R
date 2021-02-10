#----------
# Determine Ranking of total imports and cummulative sum
#----------

data_local = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\gravity_estimation_data.dta"

all_data = read.csv(data_local)
head(all_data)

agg_data = aggregate(all_data$trade_value, by=list(importer = all_data$importer), FUN = sum)
agg_data = agg_data[order(-agg_data$x),]
rownames(agg_data) <- NULL
head(agg_data)
agg_data$cumulative = cumsum(agg_data$x)/sum(agg_data$x)
agg_data$rank = rownames(agg_data)
colnames(agg_data)[colnames(agg_data)=="x"] <- "total_imports_1995_to_2006"

# write.csv(agg_data, file = "G:\\data\\Peter Herman\\Trade Network Reserach\\Data\\country_share_of_imports.csv", row.names = FALSE)

top_60 = head(agg_data['importer'], 60)
top_60 = expand.grid(top_60$importer, top_60$importer)
colnames(top_60) = c('importer', 'exporter')
head(top_60)
write.csv(top_60, file = "D:\\work\\Peter_Herman\\projects\\trade_network_research\\files_used_in_submission\\data\\top_60_importers.csv", row.names=FALSE)
