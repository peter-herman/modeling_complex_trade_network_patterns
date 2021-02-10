* Gravity analysis using full sample
* DESCRIPTION: This is the file that runs the PPML and Probit estimations using all countries and years for section 2 
*   in "Modeling Complex Trade Patterns in International Trade".

clear all
set matsize 8000
set maxvar 30000
cd "D:\work\Peter_Herman\projects\trade_network_research\files_used_in_submission\gravity_analysis\full_specifications"
log using "log_gravity_estimation.txt", replace
set more off

use "D:\work\Peter_Herman\projects\trade_network_research\files_used_in_submission\data\gravity_estimation_data.dta", clear

tostring year, gen(year_str)
tostring importer, gen(imp)
gen imp_year = imp+ "_" + year_str

tostring exporter, gen(exp)
gen exp_year = exp+ "_" + year_str

qui tab exporter, gen(exp_fe)
qui tab importer, gen(imp_fe)
qui tab year, gen(year_fe)
qui tab imp_year, gen(imp_year_fe)
qui tab exp_year, gen(exp_year_fe)



probit traded lndist contig comlang_ethno colony rta  imp_year_fe* exp_year_fe*, vce(cluster clusterid) noconstant
estimates store probit_traditional

probit traded lndist contig comlang_ethno colony rta exp_fe*  imp_fe*  year_fe*, vce(cluster clusterid) noconstant 
estimates store probit_simple

probit traded lndist contig comlang_ethno colony rta recip_dummy transitive_count cyclical_count importer_imp_degree importer_exp_degree exporter_exp_degree exporter_imp_degree exp_fe*  imp_fe*  year_fe*, vce(cluster clusterid) noconstant
estimates store probit_network

probit traded lngdp_o  lngdp_d  lndist contig comlang_ethno colony rta recip_dummy transitive_count cyclical_count importer_imp_degree importer_exp_degree exporter_exp_degree exporter_imp_degree, vce(cluster clusterid) noconstant
estimates store probit_network_noFE

esttab probit_traditional probit_simple probit_network probit_network_noFE using probit_stata_output.txt, se aic pr2 scalars(ll) replace drop(imp_year* exp_year* exp_fe* imp_fe* year_fe*) compress
esttab probit_traditional probit_simple probit_network probit_network_noFE using probit_stata_output.tex, se aic pr2 scalars(ll) replace drop(imp_year* exp_year* exp_fe* imp_fe* year_fe*) compress wide
esttab probit_traditional probit_simple probit_network probit_network_noFE using probit_stata_output_long.tex, se aic pr2 scalars(ll) replace drop(imp_year* exp_year* exp_fe* imp_fe* year_fe*) compress 

gen trade_value_rescale = trade_value/1000000
ppml trade_value_rescale lndist contig comlang_ethno colony rta    exp_fe*  imp_fe*  year_fe*, cluster(clusterid) noconstant 
estimates store ppml_simple

ppml trade_value_rescale lndist contig comlang_ethno colony rta   recip_dummy transitive_count cyclical_count importer_imp_degree importer_exp_degree exporter_exp_degree exporter_imp_degree exp_fe*  imp_fe*  year_fe*, cluster(clusterid) noconstant 
estimates store ppml_network

ppml trade_value lngdp_o  lngdp_d  lndist contig comlang_ethno colony rta   recip_dummy transitive_count cyclical_count importer_imp_degree importer_exp_degree exporter_exp_degree exporter_imp_degree, cluster(clusterid) noconstant
estimates store ppml_network_noFE

ppml trade_value_rescale lndist contig comlang_ethno colony rta  imp_year_fe* exp_year_fe*, cluster(clusterid) noconstant 
estimates store ppml_traditional




esttab ppml_traditional ppml_simple ppml_network ppml_network_noFE using ppml_network_stata_output.txt, se aic pr2 scalars(ll) replace drop(exp_fe* imp_fe* year_fe*) compress
esttab ppml_traditional ppml_simple ppml_network ppml_network_noFE using ppml_network_stata_output_long.tex, se aic pr2 scalars(ll) replace drop(exp_fe* imp_fe* year_fe*) compress
esttab ppml_traditional ppml_simple ppml_network ppml_network_noFE using ppml_network_stata_output_wide.tex, se aic pr2 scalars(ll) replace drop(exp_fe* imp_fe* year_fe*) compress wide

