* 1995 partial gravity analysis for comparrison with ERGM
* DESCRIPTION: This runs the v2 specification but includes only to the top 60 countries. 
* It also thins trade flows on an importer/year basis so that all countries exhibit their top 
* X percent of trada flows in each year. This specific version uses a recalculation of the network statistics
* which reflects the subset network of 60 countries and 50 percentile flows.
* log close
clear all
set matsize 8000
set maxvar 30000
cd "D:\work\Peter_Herman\projects\trade_network_research\files_used_in_submission\gravity_analysis\comparrison_specifications\1995"

log using "1995_partial_garvity_log.txt ", replace
set more off

local use_year 1995

import delimited "D:\work\Peter_Herman\projects\trade_network_research\files_used_in_submission\data\partial_dataset_60_ctrys_50_pct_95-06_partial_sample_network_stats.csv", varnames(1) clear

* fix the fact that the missing values are reading in as "NA" and, as a result, GDP is being loaded as strings.
replace lngdp_o = "." if lngdp_o == "NA"
destring lngdp_o, replace

replace lngdp_d = "." if lngdp_d == "NA"
destring lngdp_d, replace

keep if year == `use_year'

tostring year, gen(year_str)
*tostring importer, gen(importer_str)
gen imp_year = importer + "_" + year_str

*tostring exporter, gen(exporter_str)
gen exp_year = exporter+ "_" + year_str

qui tab exporter, gen(exp_fe)
qui tab importer, gen(imp_fe)
qui tab year, gen(year_fe)
qui tab imp_year, gen(imp_year_fe)
qui tab exp_year, gen(exp_year_fe)



probit traded lndist contig comlang_ethno colony rta  imp_year_fe* exp_year_fe*, vce(cluster clusterid) noconstant
estimates store probit_traditional
predict phat_1

probit traded lndist contig comlang_ethno colony rta exp_fe*  imp_fe* year_fe, vce(cluster clusterid) noconstant
estimates store probit_simple
predict phat_2

probit traded lndist contig comlang_ethno colony rta recip_exp transitive_count cyclical_count  importer_exp_degree exporter_exp_degree exporter_imp_degree exp_fe*  imp_fe*  year_fe*, vce(cluster clusterid) noconstant
estimates store probit_network
predict phat_3

probit traded lngdp_o  lngdp_d  lndist contig comlang_ethno colony rta recip_exp transitive_count cyclical_count importer_exp_degree exporter_exp_degree exporter_imp_degree, vce(cluster clusterid) noconstant
estimates store probit_network_noFE
predict phat_4


export delimited exporter importer year traded phat_1 phat_2 phat_3 phat_4 using "1995_probit_predicted_probabilities_subset_network_stats", replace


esttab probit_traditional probit_simple probit_network probit_network_noFE using probit_stata_output.txt, se aic pr2 scalars(ll) replace drop(imp_year* exp_year* exp_fe* imp_fe* year_fe*) compress
esttab probit_traditional probit_simple probit_network probit_network_noFE using probit_stata_output.tex, se aic pr2 scalars(ll) replace drop(imp_year* exp_year* exp_fe* imp_fe* year_fe*) compress wide
esttab probit_traditional probit_simple probit_network probit_network_noFE using probit_stata_output_full_subset_network_stats.txt, se aic pr2 scalars(ll) replace compress


ppml trade_value lndist contig comlang_ethno colony rta  imp_year_fe* exp_year_fe*, cluster(clusterid) noconstant
estimates store ppml_traditional

ppml trade_value lndist contig comlang_ethno colony rta    exp_fe*  imp_fe*  year_fe*, cluster(clusterid) noconstant
estimates store ppml_simple

// Did not converge
*ppml trade_value lndist contig comlang_ethno colony rta   recip_dummy transitive_count cyclical_count importer_imp_degree importer_exp_degree exporter_exp_degree exporter_imp_degree exp_fe*  imp_fe*  year_fe*, cluster(clusterid) 
*estimates store ppml_network

ppml trade_value lngdp_o  lngdp_d  lndist contig comlang_ethno colony rta   recip_exp transitive_count cyclical_count importer_exp_degree exporter_exp_degree exporter_imp_degree, cluster(clusterid) noconstant 
estimates store ppml_network_noFE

// Commented out version includes the non-converged specification
* esttab ppml_traditional ppml_simple ppml_network ppml_network_noFE using ppml_network_stata_output.txt, se aic pr2 scalars(ll) replace drop(imp_year* exp_year* exp_fe* imp_fe*) compress
* esttab ppml_traditional ppml_simple ppml_network ppml_network_noFE using ppml_network_stata_output_full.txt, se aic pr2 scalars(ll) replace compress

esttab ppml_traditional ppml_simple ppml_network_noFE using ppml_network_stata_output_subset_network_stats.txt, se aic pr2 scalars(ll) replace drop(imp_year* exp_year* exp_fe* imp_fe*) compress
esttab ppml_traditional ppml_simple ppml_network_noFE using ppml_network_stata_output_full_subset_network_stats.txt, se aic pr2 scalars(ll)  replace compress

