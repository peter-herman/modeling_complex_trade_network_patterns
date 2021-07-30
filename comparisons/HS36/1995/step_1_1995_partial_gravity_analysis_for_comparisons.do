* 1995 partial gravity analysis for comparrison with ERGM
* DESCRIPTION: This condcts a probit gravity analysis using the partial sample 
* of the top 50 countries and trade in HS chapter 36 for use in the model comparrisons.
* log close
clear all
set matsize 8000
set maxvar 30000
cd "D:\work\Peter_Herman\projects\trade_network_revisions_2020\submission_files\comparisons\HS36\1995\1995_results"

log using "1995_partial_gravity_log.txt ", replace
set more off

local use_year 1995

import delimited "D:\work\Peter_Herman\projects\trade_network_revisions_2020\submission_files\comparisons\partial_data_set_hs36_top50_with_ntw_vars.csv", varnames(1) clear


keep if year == `use_year'

* fix the fact that the missing values are reading in as "NA" and, as a result, GDP is being loaded as strings.
replace gdp_o = "." if gdp_o == "NA"
destring gdp_o, replace

replace gdp_d = "." if gdp_d == "NA"
destring gdp_d, replace

replace lngdp_o = "." if lngdp_o == "NA"
destring lngdp_o, replace

replace lngdp_d = "." if lngdp_d == "NA"
destring lngdp_d, replace

replace lngdpcap_o = "." if lngdpcap_o == "NA"
destring lngdpcap_o, replace

replace lngdpcap_d = "." if lngdpcap_d == "NA"
destring lngdpcap_d, replace


* Create fixed effects
tostring year, gen(year_str)
gen imp_year = importer+ "_" + year_str
gen exp_year = exporter+ "_" + year_str

qui tab exporter, gen(exp_fe)
qui tab importer, gen(imp_fe)
qui tab year, gen(year_fe)
qui tab imp_year, gen(imp_year_fe)
qui tab exp_year, gen(exp_year_fe)

* Create Cluster ID
gen clusterid = exporter+importer


* Generate Remotness measures based on Baldwin and Harrigan (2011)
gen distw = exp(lndist)

gen weighted_dist_o = gdp_d/distw
bysort exp_year: egen remoteness_o=sum(weighted_dist_o)
replace remoteness_o=1/remoteness_o
gen lnremoteness_o = log(remoteness_o)

gen weighted_dist_d = gdp_o/distw
bysort imp_year: egen remoteness_d=sum(weighted_dist_d)
replace remoteness_d=1/remoteness_d
gen lnremoteness_d = log(remoteness_d)


// Conduct Estimations
probit traded lndist contig comlang_ethno colony rta exp_fe*  imp_fe*, vce(robust) noconstant
estimates store probit_simple
predict phat_standard

probit traded lndist contig comlang_ethno colony rta recip_exp transitive_count cyclical_count  exp_fe*  imp_fe*, vce(robust) noconstant
estimates store probit_network
predict phat_bilat_ntwk

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

local recip_b = _b[recip_exp]
constraint define 6 recip_exp = `recip_b'

local trans_b = _b[transitive_count]
constraint define 7 transitive_count = `trans_b'

local cyclic_b =_b[cyclical_count]
constraint define 8 cyclical_count = `cyclic_b'


probit traded lndist contig comlang_ethno colony rta recip_exp transitive_count cyclical_count importer_imp_degree importer_exp_degree exporter_exp_degree exporter_imp_degree lngdp_o  lngdp_d lngdpcap_o lngdpcap_d lnremoteness_o lnremoteness_d , vce(robust) constraints(1/8)
estimates store probit_network_noFE
predict phat_all_ntwk


export delimited exporter importer year traded phat_standard phat_bilat_ntwk phat_all_ntwk using "1995_probit_predicted_probabilities_subset_network_stats", replace


esttab probit_simple probit_network probit_network_noFE using 1995_partial_probit_stata_output.txt, se aic pr2 scalars(ll) star(* 0.1 ** 0.05 *** 0.01) replace drop(exp_fe* imp_fe*) compress


