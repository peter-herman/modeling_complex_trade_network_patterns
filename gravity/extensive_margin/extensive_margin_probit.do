
// DESCRIPTION: Estimates the probit models of the extensive margin
clear all
set matsize 8000
set maxvar 30000
cd "D:\work\Peter_Herman\projects\trade_network_revisions_2020\submission_files\gravity\extensive_margin\results_probit"
log using "extensive_margin_estimation_log.txt", replace
set more off

use "D:\work\Peter_Herman\projects\trade_network_revisions_2020\submission_files\data\gravity_estimation_data.csv", clear



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


* Generate Remotness measures based on Baldwin and Harrigan (2011)
gen weighted_dist_o = gdp_d/distw
bysort exp_year: egen remoteness_o=sum(weighted_dist_o)
replace remoteness_o=1/remoteness_o
gen lnremoteness_o = log(remoteness_o)

gen weighted_dist_d = gdp_o/distw
bysort imp_year: egen remoteness_d=sum(weighted_dist_d)
replace remoteness_d=1/remoteness_d
gen lnremoteness_d = log(remoteness_d)



* -----
* Conduct Probit Analysis
* -----


* Traditional Specification with country-year fixed effects
probit traded lndist contig comlang_ethno colony rta  imp_year_fe* exp_year_fe*, vce(cluster clusterid) noconstant
estimates store probit_traditional
esttab using probit_traditional.csv, cells("b se t p ci_l ci_u _star") ar2 aic bic replace



* Subset of Network Vars and country-year fixed effects
probit traded lndist contig comlang_ethno colony rta  recip_dummy transitive_count cyclical_count imp_year_fe* exp_year_fe*, vce(cluster clusterid) noconstant
estimates store probit_network_partial
esttab using probit_network_with_fullFE.csv, cells("b se t p ci_l ci_u _star") ar2 aic bic replace

* Define some later constraints
local dist_b = _b[lndist]
constraint define 1 lndist = `dist_b'

local contig_b = _b[contig]
constraint define 2 contig = `contig_b'

local comlang_ethno_b = _b[comlang_ethno]
constraint define 3 comlang_ethno = `comlang_ethno_b'

local colony_b = _b[colony]
constraint define 4 colony = `colony_b'

local rta_b = _b[rta]
constraint define 5 rta = `rta_b'

local recip_b = _b[recip_dummy]
constraint define 6 recip_dummy = `recip_b'

local trans_b = _b[transitive_count]
constraint define 7 transitive_count = `trans_b'

local cyclic_b =_b[cyclical_count]
constraint define 8 cyclical_count = `cyclic_b'


* All Network Vars with country fixed effects
probit traded lndist contig comlang_ethno colony rta recip_dummy transitive_count cyclical_count importer_imp_degree importer_exp_degree exporter_exp_degree exporter_imp_degree exp_fe*  imp_fe*  year_fe*, vce(cluster clusterid) noconstant
estimates store probit_network
esttab using probit_full_network_with_cntryFE.csv, cells("b se t p ci_l ci_u _star") ar2 aic bic replace


* All network terms and all contraints with country, year fixed effects 
probit traded lndist contig comlang_ethno colony rta recip_dummy transitive_count cyclical_count importer_imp_degree importer_exp_degree exporter_exp_degree exporter_imp_degree exp_fe* imp_fe* year_fe*, vce(cluster clusterid) noconstant constraints(1/8)
estimates store probit_cntryFE_ntw_cns
esttab using probit_all_networks_cntryFE_network_constraints.csv, cells("b se t p ci_l ci_u _star") ar2 aic bic replace



* Constrained network effects, All Network, no fixed effects but GDP, GDPPC, Remotness
probit traded lndist contig comlang_ethno colony rta recip_dummy transitive_count cyclical_count importer_imp_degree importer_exp_degree exporter_exp_degree exporter_imp_degree lngdp_o  lngdp_d lngdpcap_o lngdpcap_d lnremoteness_o lnremoteness_d, vce(cluster clusterid) noconstant constraints(1/8)
estimates store probit_network_noFE_ntw_cns
esttab using probit_all_networks_noFE_network_constraints.csv, cells("b se t p ci_l ci_u _star") ar2 aic bic replace

* No constriants, All Network, no fixed effects but GDP, GDPPC, Remotness
probit traded lndist contig comlang_ethno colony rta recip_dummy transitive_count cyclical_count importer_imp_degree importer_exp_degree exporter_exp_degree exporter_imp_degree lngdp_o  lngdp_d lngdpcap_o lngdpcap_d lnremoteness_o lnremoteness_d, vce(cluster clusterid) noconstant 
estimates store probit_network_noFE_noCns
esttab using probit_all_networks_noFE_no_constraints.csv, cells("b se t p ci_l ci_u _star") ar2 aic bic replace

* ----
* Save Probit Output
* ----

* Text table
esttab probit_traditional  probit_network_partial probit_network probit_cntryFE_ntw_cns probit_network_noFE_noCns probit_network_noFE_ntw_cns using probit_stata_output.txt, se aic bic ar2 scalars(ll) star(* 0.1 ** 0.05 *** 0.01) replace drop(imp_year* exp_year* exp_fe* imp_fe* year_fe*) 

