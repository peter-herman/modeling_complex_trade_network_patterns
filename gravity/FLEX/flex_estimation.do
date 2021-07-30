
// DESCRIPTION: Estimates FLEX models of the extensive margin
clear all
set matsize 8000
set maxvar 30000
cd "gravity\FLEX"
log using "flex_estimation_log.log", replace
set more off

import delimited "gravity\FLEX\flex_count_panel_v1.csv", clear



tostring year, gen(year_str)
gen imp_year = importer+ "_" + year_str

gen exp_year = exporter+ "_" + year_str

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

* generate rescaled count values
egen hs6_max = max(hs6) 
gen hs6_rescale = hs6/hs6_max

* -----
* Conduct Probit Analysis
* -----


* (1) Traditional Specification with country-year fixed effects
flex hs6_rescale lndist contig comlang_ethno colony rta  imp_year_fe* exp_year_fe*, cluster(clusterid)
estimates store flex_traditional
esttab using flex_traditional.csv, cells("b se t p ci_l ci_u _star") ar2 aic bic replace


* (2) Subset of Network Vars and country-year fixed effects
flex hs6_rescale lndist contig comlang_ethno colony rta  recip_dummy transitive_count cyclical_count imp_year_fe* exp_year_fe*, cluster(clusterid)
estimates store flex_network_partial
esttab using flex_network_with_fullFE.csv, cells("b se t p ci_l ci_u _star") ar2 aic bic replace



* (3) All Network Vars with country fixed effects
flex hs6_rescale lndist contig comlang_ethno colony rta recip_dummy transitive_count cyclical_count importer_imp_degree importer_exp_degree exporter_exp_degree exporter_imp_degree exp_fe*  imp_fe*  year_fe*, cluster(clusterid)
estimates store flex_network
esttab using flex_full_network_with_cntryFE.csv, cells("b se t p ci_l ci_u _star") ar2 aic bic replace


* (4) No constriants, All Network, no fixed effects but GDP, GDPPC, Remotness
flex hs6_rescale lndist contig comlang_ethno colony rta recip_dummy transitive_count cyclical_count importer_imp_degree importer_exp_degree exporter_exp_degree exporter_imp_degree lngdp_o  lngdp_d lngdpcap_o lngdpcap_d lnremoteness_o lnremoteness_d, cluster(clusterid) 
estimates store flex_network_noFE_noCns
esttab using flex_all_networks_noFE_no_constraints.csv, cells("b se t p ci_l ci_u _star") ar2 aic bic replace





* ----
* Save Flex Output
* ----

* Text table
esttab flex_traditional  flex_network_partial flex_network flex_network_noFE_noCns using flex_stata_output.txt, se aic bic ar2 scalars(ll) star(* 0.1 ** 0.05 *** 0.01) replace drop(imp_year* exp_year* exp_fe* imp_fe* year_fe*)

