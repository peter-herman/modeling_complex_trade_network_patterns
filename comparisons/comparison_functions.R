library(statnet)
library(btergm)

compare_gof <- function(probit_gof, ergm_gof, attribute = 'esp'){
  ###
  # Match ergm and probit gof statistics and compute sum of squared errors.
  ###

  # Determine correct probit and ergm component names for supplied attribute
  if(attribute=='esp'){
    attribute_list = list('ergm' = 'summary.espart', 'probit' = 'Edge-wise shared partners', 'probit_row_prefix' = 'esp')}
  if(attribute=='ideg'){
    attribute_list = list('ergm' = 'summary.ideg', 'probit' = 'Indegree', 'probit_row_prefix' = '')}
  if(attribute=='odeg'){
    attribute_list = list('ergm' = 'summary.odeg', 'probit' = 'Outdegree', 'probit_row_prefix' = '')}
  if(attribute=='dist'){
    attribute_list = list('ergm' = 'summary.dist', 'probit' = 'Geodesic distances', 'probit_row_prefix' = '')}
  if(attribute=='edges'){
    attribute_list = list('ergm' = 'summary.model', 'probit' = 'Edges', 'probit_row_prefix' = '')}
  
  #--
  # prep ergm data
  #--
  ergm_df = ergm_gof[[attribute_list$ergm]] # Collect results data
  # If edges, grab only the edges row
  if(attribute=='edges'){ergm_df = subset(ergm_df, rownames(ergm_df)=='edges')}
  # Rename some columns
  for(i in 1:length(colnames(ergm_df))){
    colnames(ergm_df)[i] = paste("ergm", colnames(ergm_df)[i], sep = " " ) # Add ergm colomn prefix
  }
  ergm_df =  cbind(gof_stat = rownames(ergm_df), ergm_df) # Create column from row names
  rownames(ergm_df) <- NULL # reset rownames

  #--
  # prep probit data
  #--
  if(attribute=='edges'){probit_df =probit_gof[[attribute_list$probit]]
    rownames(probit_df) = attribute
  } else{probit_df = probit_gof[[attribute_list$probit]]$stats}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           # collect results data

  for(i in 1:length(colnames(probit_df))){ # Rename certain columns to match those in ergm data
    if (colnames(probit_df)[i] == "sim: mean") {colnames(probit_df)[i] = "mean" } 
    if (colnames(probit_df)[i] == "Pr(>z)") {colnames(probit_df)[i] = "MC p-value" }
    colnames(probit_df)[i] = paste("probit", colnames(probit_df)[i], sep = " " ) # add probit column prefix
  }
  probit_df$gof_stat = paste(attribute_list$probit_row_prefix, rownames(probit_df), sep = "") # create a list of identifiers for each row
  
  # Combine ergm with probit
  comp_df = merge(probit_df, ergm_df,  by = c("gof_stat")) # Combine probit and ergm results
  comp_df$probit_error = (comp_df$'probit obs' - comp_df$'probit mean')**2 # compute squared error for probit
  comp_df$ergm_error = (as.numeric(as.character(comp_df$'ergm obs')) - as.numeric(as.character(comp_df$'ergm mean')))**2 # compute squared error for ergm 
  comp_df$gof_attribute = attribute                                                                                                                       # (these are wierdly stored as factors rather than numbers)

  comp_errors = list(attribute = attribute, 'ergm' = sum(comp_df$ergm_error), 'probit' = sum(comp_df$probit_error)) # Store results in a list
  return(list(df = comp_df, total = comp_errors)) # Store results and dataframes in a list to return
}


compile_gof_comps <- function(probit_gof, ergm_gof){
    df_list = list()
    comparrison_df <- data.frame(matrix(ncol = 3, nrow = 0))
    colnames(comparrison_df) = c('attribute', 'probit', 'ergm')
    
    for(atb in c('edges','esp', 'ideg', 'odeg', 'dist')){
      print(atb)
      gof_results = compare_gof(probit_gof, ergm_gof, attribute = atb)
      #compiled_dfs = temp$
      df_list[[atb]] = gof_results$df
      temp_df = data.frame("attribute" = atb, "probit" = gof_results$total$probit, "ergm" = gof_results$total$ergm)
      comparrison_df = rbind(comparrison_df, temp_df)       
    }
    return(list(comparisons = comparrison_df, all_dfs = df_list))
}

write_gof_comparisons <- function(gof_comp, save_path, file_name = "combined_gof_tables.csv"){
  write.table(gof_comp$comparisons, paste(save_path, file_name, sep = '\\'), col.names=TRUE, sep=",", row.names = FALSE)
  for(i in 1:length(gof_comp$all_dfs)){    
    write.table(gof_comp$all_dfs[[i]], paste(save_path, file_name, sep = '\\'), col.names=TRUE, sep=",", row.names = FALSE, append=TRUE)
  }
}

