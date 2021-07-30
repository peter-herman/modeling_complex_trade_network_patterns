* PPML Gravity analysis using cross section of HS36 in 2006
* DESCRIPTION: This is the file that runs the PPML two-stage estimations using the cross sectional data used for the ERGMs. 
*   In the first sage, a series of structural gravity models are estimated. In the second stage, fixed
*   effect estimates from one of the first stage specifications are used in OLS estimations of their 
*   determinants.

clear all
set matsize 8000
set maxvar 30000
cd "gravity\PPML\cross_sections"
log using "hs36_2006_two_stage_ppml_log.log", replace
set more off

import delimited "comparisons\HS36\partial_data_set_hs36_top50_with_ntw_vars.csv", clear
keep if year == 2006

tostring year, gen(year_str)
tostring importer, replace

gen imp_year = importer+ "_" + year_str

tostring exporter, replace

gen exp_year = exporter+ "_" + year_str

* Generate Remotness measures based on Baldwin and Harrigan (2011)
gen distw = exp(lndist)
foreach var of varlist gdp_d gdpcap_d gdp_o gdpcap_o lngdp_o lngdp_d lngdpcap_o lngdpcap_d {
	replace `var' = "" if `var' == "NA"
} 
destring gdp_d gdpcap_d gdp_o gdpcap_o lngdp_o lngdp_d lngdpcap_o lngdpcap_d, replace
gen weighted_dist_o = gdp_d/distw
bysort exp_year: egen remoteness_o=sum(weighted_dist_o)
replace remoteness_o=1/remoteness_o
gen lnremoteness_o = log(remoteness_o)

gen weighted_dist_d = gdp_o/distw
bysort imp_year: egen remoteness_d=sum(weighted_dist_d)
replace remoteness_d=1/remoteness_d
gen lnremoteness_d = log(remoteness_d)

sum gdp_o gdp_d weighted_dist_o weighted_dist_d remoteness_o remoteness_d

qui tab exporter, gen(exp_fe)
qui tab importer, gen(imp_fe)
qui tab year, gen(year_fe)
qui tab imp_year, gen(imp_year_fe)
qui tab exp_year, gen(exp_year_fe)



 
* HDFE PPML
*ppml trade_value lndist contig comlang_ethno colony rta exp_year_fe* imp_year_fe*, cluster(clusterid)
ppml_panel_sg trade_value lndist contig comlang_ethno colony rta, ex(exporter) im(importer) y(year) nopair robust genS(exp_fe) genM(imp_fe) genO(omr_est) genI(imr_est) predict(ppml_prediction)
gen traded_prediction = 0
replace traded_prediction = 1 if ppml_prediction>0
sum traded traded_prediction if traded_prediction != .

parmest, saving(ppml_hdfe_standard_hs36_2006, replace) stars(0.1 0.05 0.01)
estimates store standard_ppml


* HDFE PPML with Network Effects (dummy/count)
ppml_panel_sg trade_value lndist contig comlang_ethno colony rta recip_exp cyclical_count transitive_count, ex(exporter) im(importer) y(year) nopair robust genS(exp_fe_network) genM(imp_fe_network) maxiter(100000) verbose(1000)
parmest, saving(ppml_hdfe_network_hs36_2006, replace) stars(0.1 0.05 0.01)
estimates store network_ppml


* HDFE PPML with only transitive
ppmlhdfe trade_value lndist contig comlang_ethno colony rta recip_exp transitive_count, absorb(exp_year imp_year) vce(robust)
parmest, saving(ppml_hdfe_trans_only_hs36_2006, replace) stars(0.1 0.05 0.01)
estimates store network_ppml_transitive

* HDFE PPML with only cyclical
ppmlhdfe trade_value lndist contig comlang_ethno colony rta recip_exp cyclical_count, absorb(exp_year imp_year) vce(robust)
parmest, saving(ppml_hdfe_cycl_only_hs36_2006, replace) stars(0.1 0.05 0.01)
estimates store network_ppml_cyclical



* Store Estimates
esttab standard_ppml network_ppml network_ppml_transitive network_ppml_cyclical using ppml_hdfe_multi-specs_output_hs36_2006.txt, se aic pr2 scalars(ll) star(* 0.1 ** 0.05 *** 0.01) replace 
/* esttab standard_ppml network_ppml network_ppml_transitive network_ppml_cyclical using ppml_hdfe_multi-specs_output.tex, se aic pr2 scalars(ll) star(* 0.1 ** 0.05 *** 0.01) replace  */


* Store fixed effect estimates
preserve
keep exporter importer year exp_fe imp_fe exp_fe_network imp_fe_network
export delimited using standard_fe_estimates_hs36_2006.csv, replace
restore


* ###
* Second Stage
* ###
preserve 
keep importer year imp_fe_network gdp_d gdpcap_d gatt_d importer_imp_degree importer_exp_degree  lngdp_d lngdpcap_d remoteness_d exporter year exp_fe_network gdp_o gdpcap_o gatt_o exporter_exp_degree exporter_imp_degree  lngdp_o lngdpcap_o remoteness_o
save second_stage_data_hs36_2006.dta, replace
restore 
** 
* Importer FEs
**

preserve
* Generate a unilateral degree measure as the original was exclsive of link ij itselve, which created two values depending on the value of ij (x or x+1)
egen max_importer_imp_degree = max(importer_imp_degree), by(importer year)

keep importer year imp_fe_network gdp_d gdpcap_d gatt_d max_importer_imp_degree importer_exp_degree  lngdp_d lngdpcap_d remoteness_d 
duplicates drop
gen constant = 1
tab importer

* Rename some variables so they align in the table
rename lngdp_d lngdp
rename lngdpcap_d lngdpcap
rename gatt_d gatt
rename remoteness_d remoteness
gen lnremoteness = log(remoteness)

* Estimate
regress  imp_fe_network lngdp lngdpcap gatt lnremoteness, vce(robust)
estimates store importer_fe_lnremote

regress  imp_fe_network lngdp lngdpcap gatt lnremoteness max_importer_imp_degree importer_exp_degree, vce(robust)
estimates store importer_fe_lnr_network

regress  imp_fe_network lngdp lngdpcap gatt max_importer_imp_degree importer_exp_degree, vce(robust)
estimates store importer_fe_network



**
* Exporter FEs
**

* Restore earlier dataset
restore 

preserve
* Generate a unilateral degree measure as the original was exclsive of link ij itselve, which created two values depending on the value of ij (x or x+1)
egen max_exporter_exp_degree = max(exporter_exp_degree), by(exporter year)

keep exporter year exp_fe_network gdp_o gdpcap_o gatt_o max_exporter_exp_degree exporter_imp_degree  lngdp_o lngdpcap_o remoteness_o
duplicates drop
gen constant = 1
tab exporter

* Rename some variables so they align in the table
rename lngdp_o lngdp
rename lngdpcap_o lngdpcap
rename gatt_o gatt
rename remoteness_o remoteness
gen lnremoteness = log(remoteness)

* Estimate
regress  exp_fe_network lngdp lngdpcap gatt lnremoteness, vce(robust)
estimates store exporter_fe_lnremote

regress  exp_fe_network lngdp lngdpcap gatt lnremoteness max_exporter_exp_degree exporter_imp_degree, vce(robust)
estimates store exporter_fe_lnr_network

regress  exp_fe_network lngdp lngdpcap gatt max_exporter_exp_degree exporter_imp_degree, vce(robust)
estimates store exporter_fe_network



esttab  importer_fe_lnremote importer_fe_lnr_network importer_fe_network exporter_fe_lnremote exporter_fe_lnr_network exporter_fe_network using second_stage_hs36_2006.txt, se ar2 star(* 0.1 ** 0.05 *** 0.01) replace



restore
log close






