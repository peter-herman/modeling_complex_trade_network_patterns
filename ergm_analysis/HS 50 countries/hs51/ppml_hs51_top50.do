* PPML of HS chapter 51 with 50 countries to get fixed effect estimates for ERGM

clear all
set matsize 8000
set maxvar 30000

cd "ergm_analysis\HS 50 countries\hs51"
log using "ppml_hs51_top50_log.log", replace
set more off

use "data\ppml_hs51_panel_top50.dta", clear

keep if hs2 == "51"

gen clusterid = exporter + importer

ppml_panel_sg trade_value lndist contig comlang_ethno colony rta, ex(exporter) im(importer) y(year) nopair cluster(clusterid) genS(exp_fe) genM(imp_fe) genO(omr_est) genI(imr_est)


parmest, saving(ppml_hdfe_standard, replace) stars(0.1 0.05 0.01)
estimates store standard_ppml


keep exporter importer year exp_fe imp_fe
export delimited using ppml_hs51_top50_standard_fe_estimates.csv, replace

esttab standard_ppml using ppml_hs51_top50_output.txt, se aic pr2 scalars(ll) star(* 0.1 ** 0.05 *** 0.01) replace 
log close