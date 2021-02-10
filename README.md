# Replication Instructions
This repository contains instructions for how to replicate the work in the 2021 revision of "Modeling Complex Network Patterns in Trade" by Peter Herman. To do so, follow the instructions below in sequence to reproduce all of the analysis. 

## Source Data Files
The following files reflect the source data used in the analysis. Two of the files are included here as comma separated text files. The remaining files are not included due to file size, but are readily available from their original sources at http://www.cepii.fr/cepii/en/bdd_modele/bdd.asp. The specific versions used for the original analysis are available by request from the author.

**Data Files:**
* data/207countrylist.csv  (A list of countries for use in main analysis, included in repo in .txt format)
* data/baci92_1995.csv (1995 trade flows from BACI dataset) 
* data/baci92_2006.csv (2006 trade flows from BACI dataset) 
* data/country_name_correspondence.dta (Correspondences for renaming country codes, included in repo in .txt format)
* data/geo_cepii.dta (GEO CEPII dataset)
* data/grav_data_1995to2015.csv (CEPII Gravity dataset for 1995--2006)
* Source BACI data files (BACI trade data files for 1995--2006)

## Trade Data Prep
**Scripts:**
* data/gravity_data_constructor.R
 
**Inputs:**
* data/country_name_correspondence.dta
* data/grav_data_1995to2015.csv
* Source BACI data files



## Gravity Analysis
The analysis is made up of two components: a PPML analysis using trade values and an extensive margin analysis using probit and OLS estimators.

### PPML
**Scripts:**
* gravity/PPML/two_stage_ppml.do

**Inputs:**
* data\gravity_estimation_data.csv (estimating data)

**Outputs:**
* gravity/PPML/results/ppml_hdfe_multi-specs_output.txt (table of first stage PPML results)
* gravity/PPML/results/ppml_hdfe_[multiple].dta (results from each individual PPML specification)
* gravity/PPML/results/second_stage.txt (table of second stage results)
* gravity/PPML/results/second_stage_data.dta (data sample created in first stage and used in second stage, saved for convenience)
* gravity/PPML/results/standard_fe_estimates.csv (fixed effect estimates, used for full sample ERGMs)
* gravity/PPML/results/two_stage_ppml_log.txt (stata log file)

### Extensive Margin

#### Probit Model
**Scripts:** 
* gravity/extensive_margin/extensive_margin_probit.do

**Inputs:**
* data\gravity_estimation_data.csv (estimating data)

**Outputs:**
* gravity/extensive_margin/results_probit/probit_stata_output.txt (table of results)
* gravity/extensive_margin/results_probit/extensive_margin_estimation_log.txt (stata log file)
* gravity/extensive_margin/results_probit/probit_[multiple].csv (results for each individual specification)

#### OLS Model
**Scripts:**
* gravity/extensive_margin/extensive_margin_ols.do

**Inputs:**
* data\gravity_estimation_data.csv (estimating data)

**Outputs:**
* gravity/extensive_margin/ols_results/ols_stata_output.txt (table of results)
* gravity/extensive_margin/ols_results/extensive_margin_estimation_log.txt (stata log file)
* gravity/extensive_margin/ols_results/ols_[multiple].csv (results for each individual specification)






## ERGM Analysis


The analysis takes place in two parts. The first chunk analyzes the 1995 and 2006 trade networks using the full sample of 207 countries. The second piece uses a subsample of HS 36 trade among the top 50 trading countries in 1995 and 2006.

### Support Functions

* ergm_analysis/BACI.functions.R
* ergm_analysis/BACI_node_attributes.R

### Full Sample ERGM

#### 1995 
**Scripts:** 
* ergm_analysis/Full Sample/1995_full_sample_ergm.R

**Inputs:** 
* data\\207countrylist.csv
* data\\geo_cepii.dta
* data\\grav_data_1995to2015.csv
* data\\baci92_1995.csv
* data\\country_name_correspondence.dta
* ergm_analysis\\BACI.functions.R
* ergm_analysis\\BACI_node_attributes.R
* gravity\\main_analysis\\PPML\\results\\standard_fe_estimates.csv

**Outputs:** 
* ergm_analysis/Full Sample/ERGM_full_sample_results/1995_full_sample_ergm_results.txt (main findings)
* ergm_analysis/Full Sample/ERGM_full_sample_results/[various other outputs]

#### 2006 
**Scripts:** 
* ergm_analysis/Full Sample/2006_full_sample_ergm.R

**Inputs:** 
* data\\207countrylist.csv
* data\\geo_cepii.dta
* data\\grav_data_1995to2015.csv
* data\\baci92_2006.csv
* data\\country_name_correspondence.dta
* ergm_analysis\\BACI.functions.R
* ergm_analysis\\BACI_node_attributes.R
* gravity\\main_analysis\\PPML\\results\\standard_fe_estimates.csv

**Outputs:** 
* ergm_analysis/Full Sample/ERGM_full_sample_results/2006_full_sample_ergm_results.txt (main findings)
* ergm_analysis/Full Sample/ERGM_full_sample_results/[various other outputs]


### Partial Sample ERGM

The partial sample has three steps
1. Create the partial sample
2. Estimate PPML models to get fixed effects for multilateral resistances
3. Estimate ERGMs

#### Step 1 Create partial sample
**Scripts:** 
* ergm_analysis/HS 50 countries/create_partial_sample.py

**Inputs:**
* Source BACI data files
* data\\country_name_correspondence.dta
* data\\grav_data_1995to2015.csv
* data\\country_code_baci92.csv
* data\\baci92_1995.csv
* data\\baci92_2006.csv

**Outputs:**
* "ergm_analysis\\HS 50 countries\\hs36_baci_data_1995_top50_traders.csv" (1995 partial network trade for ERGM)
* "ergm_analysis\\HS 50 countries\\hs36_baci_data_2006_top50_traders.csv" (1995 partial network trade for ERGM)
* "ergm_analysis\\HS 50 countries\\ppml_hs2_panel_top50.dta" (Multi-year panel dataset for probit estimation)
* "ergm_analysis\\HS 50 countries\\top_50_countries.csv" (List of countries in partial sample)

#### Step 2 Estimate fixed effects for MRT covariates
**Scripts:**
* ergm_analysis/HS 50 countries/ppml_hs36_top50.do

**Inputs:**
* "ergm_analysis\\HS 50 countries\\ppml_hs2_panel_top50.dta" (Multi-year panel dataset for estimation)

**Outputs:**
* "ergm_analysis\HS 50 countries\ppml_hs36_top50_log.txt" (stata log file)
* "ergm_analysis\HS 50 countries\ppml_hdfe_standard_fe_estimates.dta" (country-year fixed effect estimates)
* "ergm_analysis\HS 50 countries\ppml_hs36_top50_output.txt" (ppml estimates table)
* "ergm_analysis/HS 50 countries/ppml_hdfe_standard.dta" (datafile of estimate values)


#### Step 3 Estimate ERGMs

##### 1995
**Scripts:** 
* "ergm_analysis/HS 50 countries/1995_HS36_50cntrys_ergm.R"

**Inputs:**
* "ergm_analysis\\HS 50 countries\\hs36_baci_data_1995_top50_traders.csv" (1995 partial network from [ERGM step 1](#-step-1-create-partial-sample)) 
* "ergm_analysis\\HS 50 countries\\ppml_hs36_top50_standard_fe_estimates.csv" (Fixed effect estimates from [ERGM step 2](#-step-1-create-partial-sample))
* "ergm_analysis\\BACI.functions.R"
* "ergm_analysis\\BACI_node_attributes.R"
* "data\\grav_data_1995to2015.csv"
* "data\\country_name_correspondence.dta"

**Outputs:**
* "ergm_analysis\\HS 50 countries\\ERGM_results\\1995_ergm_hs36_top50.txt" (Main findings)
* "ergm_analysis\\HS 50 countries\\ERGM_results\\1995_ergm_hs36_top50_[timestamp]_gof_obj.rda" (goodness of fit R object)
* "ergm_analysis\\HS 50 countries\\ERGM_results\\1995_ergm_hs36_top50_[timestamp]_output.rda" (model fit R object)
* "ergm_analysis/HS 50 countries/ERGM_results/1995_ergm_hs36_top50_[timestamp]_diagnostic_plots.pdf (diagnostic plots)
* "ergm_analysis/HS 50 countries/ERGM_results/1995_ergm_hs36_top50_[timestamp]_gof_plots.pdf" (goodness of fit plots)

##### 1995
**Scripts:** 
* "ergm_analysis/HS 50 countries/2006_HS36_50cntrys_ergm.R"

**Inputs:**
* "ergm_analysis\\HS 50 countries\\hs36_baci_data_2006_top50_traders.csv" (2006 partial network from [ERMG step 1](#-step-1-create-partial-sample)) 
* "ergm_analysis\\HS 50 countries\\ppml_hs36_top50_standard_fe_estimates.csv" (Fixed effect estimates from [ERGM step 2](#-step-1-create-partial-sample))
* "ergm_analysis\\BACI.functions.R"
* "ergm_analysis\\BACI_node_attributes.R"
* "data\\grav_data_1995to2015.csv"
* "data\\country_name_correspondence.dta"

**Outputs:**
* "ergm_analysis\\HS 50 countries\\ERGM_results\\2006_ergm_hs36_top50.txt" (Main findings)
* "ergm_analysis\\HS 50 countries\\ERGM_results\\2006_ergm_hs36_top50_[timestamp]_gof_obj.rda" (goodness of fit R object)
* "ergm_analysis\\HS 50 countries\\ERGM_results\\2006_ergm_hs36_top50_[timestamp]_output.rda" (model fit R object)
* "ergm_analysis/HS 50 countries/ERGM_results/2006_ergm_hs36_top50_[timestamp]_diagnostic_plots.pdf (diagnostic plots)
* "ergm_analysis/HS 50 countries/ERGM_results/2006_ergm_hs36_top50_[timestamp]_gof_plots.pdf" (goodness of fit plots)


## Comparisons

### Step 0 Create gravity subsample with network variables
This step creates network variables based on the subsamples and adds them to the estimating panel.

**Scripts:** 
* comparisons/recreate_partial_sample_network_variables.R

**Inputs:**
* ergm_analysis\\HS 50 countries\\ppml_hs2_panel_top50.dta (created by subsample python script in [ERGM step 1](#-step-1-create-partial-sample))

**Outputs:** 
* comparisons/partial_data_set_hs36_top50_with_ntw_vars.csv

### Step 1 Estimate partial sample probit
This step estimates two probit models for 1995 and 2006. The estimated models are each used to predict link formation probabilities that are used in the next step to simulate networks.

**Scripts:**
* comparisons/1995/step1_1995_partial_gravity_analysis_for_comparisons.do 
* comparisons/2006/step_1_2006_partial_gravity_analysis_for_comparisons.do

**Inputs:** 
* comparisons/partial_data_set_hs36_top50_with_ntw_vars.csv (estimating data from [comparison step 1](#-step-0-create-gravity-subsample-with-network-variables))

**Outputs:** 

[1995]
* comparisons/1995/1995_results/1995_partial_gravity_log.txt (stata log file)
* comparisons/1995/1995_results/1995_partial_probit_stata_output.txt (table of estimates)
* comparisons/1995/1995_results/1995_probit_predicted_probabilities_subset_network_stats.csv (predicted probabilities)

[2006]
* comparisons/2006/2006_results/2006_partial_gravity_log.txt (stata log file)
* comparisons/2006/2006_results/2006_partial_probit_stata_output.txt (table of estimates)
* comparisons/2006/2006_results/2006_probit_predicted_probabilities_subset_network_stats.csv (predicted probabilities)

### Step 2 Simulate probit networks
For each year, there are 2 sets of simulations. The first simulates a probit model that did not network covariates. The second simulates a probit model that does include network covariates.
 
**Scripts:**

[1995]
* comparisons/1995/step_2a_1995_standard_probit_simulation.R (standard probit script)
* comparisons/1995/step_2b_1995_network_probit_simulation.R (network probit script)

[2006]
* comparisons/2006/step_2a_2006_standard_probit_simulation.R (standard probit script)
* comparisons/2006/step_2b_2006_network_probit_simulation.R (network probit script)

**Inputs:**
* ergm_analysis/BACI.functions.R

[1995]
* comparisons/1995/1995_results/1995_probit_predicted_probabilities_subset_network_stats.csv

[2006]
* comparisons/2006/2006_results/2006_probit_predicted_probabilities_subset_network_stats.csv

**Outputs:**

[1995]
* comparisons/1995/1995_results/1995_network_probit_simulation_gof_obj.rda (network probit goodness of fit object)
* comparisons/1995/1995_results/1995_network_probit_simulation_gof_plots.pdf (network probit goodness of fit plots)

[2006]
* comparisons/1995/1995_results/1995_standard_probit_simulation_gof_obj.rda (standard probit goodness of fit object)
* comparisons/1995/1995_results/1995_standard_probit_simulation_gof_plots.pdf (network probit goodness of fit plots)

### Step 3 Compare ERGM and probit fits
This step generates ISE measures for each of the three models (ERGM, standard probit, and network probit) and creates files containing the comparrisons. Two outputs get created: a standard probit and network probit file. The ERGM results are included in both files.

**Scripts:**
* comparisons/1995/step_3_1995_ergm_probit_comparison.R
* comparisons/2006/step_3_2006_ergm_probit_comparison.R

**Inputs:** 
* comparisons/comparison_functions.R

[1995]
* ergm_analysis\\HS 50 countries\\ERGM_results\\1995_ergm_hs36_top50_[time stamp].txt_gof_obj.rda (ERGM goodness of fit object)
* comparisons\\1995\\1995_results\\1995_standard_probit_simulation_gof_obj.rda (standard probit goodness of fit object)
* comparisons\\1995\\1995_results\\1995_network_probit_simulation_gof_obj.rda (network goodness of fit object)

[2006]
* ergm_analysis/HS 50 countries/ERGM_results/2006_ergm_hs36_top50_2021-01-30_23-38.txt_gof_obj.rda
* comparisons/2006/2006_results/2006_standard_probit_simulation_gof_obj.rda
* comparisons/2006/2006_results/2006_network_probit_simulation_gof_obj.rda

**Outputs:**

[1995]
* comparisons/1995/1995_results/1995_combined_gof_tables_network_probit.txt (ERGM/standard probit comparison)
* comparisons/1995/1995_results/1995_combined_gof_tables_standard_probit.txt (ERGM/network probit comparison)

[2006]
* comparisons/2006/2006_results/2006_combined_gof_tables_standard_probit.txt (ERGM/standard probit comparison)
* comparisons/2006/2006_results/2006_combined_gof_tables_network_probit.txt (ERGM/network probit comparison)