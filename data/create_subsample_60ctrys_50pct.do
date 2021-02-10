* Create a dataset containing only the top 60 exporters and generate a variable
* equal to 1 if trade is greater than the 50th percentile for each importer.

clear all
set matsize 8000
set maxvar 30000
cd "D:\work\Peter_Herman\projects\trade_network_research\files_used_in_submission\data"
set more off

local percentile 50 
local use_year 2006

import delimited "D:\work\Peter_Herman\projects\trade_network_research\files_used_in_submission\data\top_60_importers.csv", varnames(1) clear
gen top_importer = 1

merge 1:m importer exporter using "D:\work\Peter_Herman\projects\trade_network_research\files_used_in_submission\data\gravity_estimation_data.dta"
keep if _merge == 3
drop _merge 
sort importer year exporter

local pct_mod = (100 - `percentile')
by importer year: egen importer_pct = pctile(trade_value), p(`pct_mod')

drop traded
gen traded =1 if trade_value > importer_pct
replace traded = 0 if traded == .

export delimited "D:\work\Peter_Herman\projects\trade_network_research\files_used_in_submission\data\partial_dataset_60-ctrys_50-pct_95-06_full_sample_network_vars.csv"

