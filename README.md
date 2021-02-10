

The following describes the files used to generate the empirical results in the the revised version of "Modeling Complex Network Patterns in International Trade".



# Data Preparation

## Gravity Data
The dataset used for estimating the full gravity models in section 2. It contains all 207 countries for 1995--2006.

### Scripts
**Main Script:** gravity_data_constructor.R 

(Originally: "P\Documents\Working Papers\Extensive Margin Estimation with Network Attributes\Data Construction v2.R")

### Inputs
**CEPII Gravity Dataset:** Not included here (Originally "P:\Documents\Working Papers\Data Various\gravdata_cepii.dta")

**Country Name Concordance:** Not included here (Originally "P:\Documents\Working Papers\Data Various\countrynamecorrespondence_stata12.dta")

**BACI Datasets:** Not included here (Originally "P:\Documents\Working Papers\Data Various\BACI\")

### Outputs
**Gravity Estimation Data:** gravity_estimation_data.rda (originally: "P:\Documents\Working Papers\Extensive Margin Estimation with Network Attributes\combineddata.rda")

Data later converted to .dta instead of .rda.




## 60 Country, 50th Percentile Dataset:  
The dataset used for the partial sample ERGM estimates and both ERGM and Probit comparison estimations. It contains data for the top 60 importers between 1995--2006 and the top 50 percent of imports by value for each importer. The bottom fifty percent of imports were converted to zeros.

### Scripts

**Step 1 - Create List of top 60 Importers:** create_top_60_countries.R 

Takes in: gravity_estimation_data.dta

Outputs: top_60_importers.csv

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v2_common_data_sets\v2_country_set.R")



**Step 2 -  Create Subsample of 60 countries and 50 percentile:** create_subsample_60ctrys_50pct.do

Takes in: gravity_estimation_data.dta, top_60_importers.csv

Outputs: partial_dataset_60-ctrys_50-pct_95-06_full_sample_network_vars.csv

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\create_subsample_60ctrys_50pct.do")

**Step 3 - Recreate Network Variables Fir Partial Sample:** recreate_partial_sample_network_variables.R

Takes in: partial_dataset_60-ctrys_50-pct_95-06_full_sample_network_vars.csv

Outputs: partial_dataset_60_ctrys_50_pct_95-06_partial_sample_network_stats.csv

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\Data_Construction_for_60-ctry_50-pct_subsamples_1995.R")






### Inputs

**Gravity Estimation Data:** gravity_estimation_data.dta (originally: "P:\Documents\Working Papers\Extensive Margin Estimation with Network Attributes\combineddata.dta")

### Outputs
**60 Country, 50th Percentile Dataset with partial sample network variables:** partial_dataset_60_ctrys_50_pct_95-06_partial_sample_network_stats.csv

(Originally: "G:\data\Peter Herman\Trade Network Reserach\Data\60-ctrys_50-pct_95-06_subset_network_stats.csv")

**60 Country, 50th Percentile Dataset with original network variables** partial_dataset_60-ctrys_50-pct_95-06_full_sample_network_vars.csv

(Originally: "G:\data\Peter Herman\Trade Network Reserach\Data\60-ctrys_50-pct_95-06.csv")

**Top 60 Importers:** top_60_importers.csv

(Originally: "G:\data\Peter Herman\Trade Network Reserach\Data\top_60_importers.csv")








# Gravity Analysis
The gravity analysis has two parts. The first covers a full panel of countries, years, and trade flows using both PPML and probit models, which is presented in section 2 of the paper. The second considers only a subset of the data and probit models for use in the comparisons of section 4.  




## Full Gravity analysis
### Scripts 
**Main Script:** "full_gravity_analysis.do"

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\Gravity Modeling\Stata Analysis\v1 - first revision\gravity_estimations_rr_v1.do")

### Inputs
**Primary Data:** gravity_estimation_data.dta 

(Originally: "P:\Documents\Working Papers\Extensive Margin Estimation with Network Attributes\combineddata.dta")

### Outputs
**Log File:** log_gravity_estimation.txt 

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\Gravity Modeling\Stata Analysis\v1 - first revision\log_gravity_estimation_v1.txt")

**PPML Table in Paper:** ppml_network_stata_output_long.tex 

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\Gravity Modeling\Stata Analysis\v1 - first revision\ppml_network_stata_output_long.tex")

**Probit Table in Paper:** probit_stata_output_long.tex

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\Gravity Modeling\Stata Analysis\v1 - first revision\probit_stata_output_long.tex")

**Other Unused Tables:** 
* ppml_network_stata_output.txt (Originally: "D:\work\Peter_Herman\projects\trade_network_research\Gravity Modeling\Stata Analysis\v1 - first revision\ppml_network_stata_output.txt")
* ppml_network_stata_output_wide.tex (Originally: "D:\work\Peter_Herman\projects\trade_network_research\Gravity Modeling\Stata Analysis\v1 - first revision\ppml_network_stata_output_wide.tex")
* probit_stata_output.tex (Originally: "D:\work\Peter_Herman\projects\trade_network_research\Gravity Modeling\Stata Analysis\v1 - first revision\probit_stata_output.tex")
* probit_stata_output.txt (Originally: "D:\work\Peter_Herman\projects\trade_network_research\Gravity Modeling\Stata Analysis\v1 - first revision\probit_stata_output.txt")



## Partial Gravity Analysis for Comparisons

### Scripts
**1995 Script:** 1995_partial_gravity_analysis_for_comparisons.do

Takes in: partial_dataset_60_ctrys_50_pct_95-06_partial_sample_network_stats.csv

Outputs: "1995_partial_garvity_log.txt", "1995_probit_predicted_probabilities_subset_network_stats.csv", probit_stat_output.tex, probit_stata_output.txt, and other tables.

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\Gravity Modeling\Stata Analysis\v3 - 60 countries\60-ctrys_50-pct_1995_subset_network_stats\v3_60-ctrys_50-pct_1995_subset_network_stats.do")

**2006 Script:** "D:\work\Peter_Herman\projects\trade_network_research\files_used_in_submission\gravity_analysis\comparrison_specifications\2006\2006_partial_gravity_analysis_for_comparisons.do"

Takes in: partial_dataset_60_ctrys_50_pct_95-06_partial_sample_network_stats.csv

Outputs: 2006_probit_predicted_probabilities_subset_network_stats, regression tables

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\Gravity Modeling\Stata Analysis\v3 - 60 countries\60-ctrys_50-pct_2006_subset_network_stats\v3_60-ctrys_50-pct_2006_subset_network_stats.do")

### Inputs
**60 Country, 50th Percentile Dataset with partial sample network variables:** partial_dataset_60_ctrys_50_pct_95-06_partial_sample_network_stats.csv

(Originally: "G:\data\Peter Herman\Trade Network Reserach\Data\60-ctrys_50-pct_95-06_subset_network_stats.csv")

### Outputs
**1995 Predicted Probabilities:** 1995_probit_predicted_probabilities_subset_network_stats

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\Gravity Modeling\Stata Analysis\v3 - 60 countries\60-ctrys_50-pct_1995_subset_network_stats\probit_predicted_probabilities_subset_network_stats.csv")

**2006 Predicted Probabilities:** 2006_probit_predicted_probabilities_subset_network_stats

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\Gravity Modeling\Stata Analysis\v3 - 60 countries\60-ctrys_50-pct_2006_subset_network_stats\probit_predicted_probabilities_subset_network_stats.csv")

**Multiple unlisted and unused tables**



# ERGM Analysis

The ERGM analysis contains two components. The first uses the full sample of countries. The second uses a subsample of 60 countries and the top 50 percent of trade flows for each importer.

## Full Sample Models


### Scripts

**1995 Model:** 1995_full_sample_ergm.R

Takes in: 207countrylist.csv, geo_cepii.dta, grav_data_1995to2015.csv, BACI.functions.R, BACI_node_attributes.R, baci92_1995.csv, country_name_correspondence.dta

Outputs: 1995_model_fit.rda, 1995_full_sample_results.txt, 1995_full_sample_results_gof_plots.pdf, 1995_full_sample_resultsdiagnostic_plots.pdf

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\original_code\ERGM_BACIagg_v4_gravity4paper.R")

**2006 Model:** 2006_full_sample_ergm.R

Takes in: 207countrylist.csv, geo_cepii.dta, grav_data_1995to2015.csv, BACI.functions.R, BACI_node_attributes.R, baci92_2006.csv, country_name_correspondence.dta

Outputs: 2006_model_fit.rda, 2006_full_sample_results.txt, 2006_full_sample_results_gof_plots.pdf, 2006_full_sample_results_diagnostic_plots.pdf



(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\original_code\ERGM_BACIagg_v4_gravity4paper_2006.R")



### Inputs

**BACI Trade Data:** baci92_1995.csv, baci92_2006.csv

(originally in: P:\\Documents\\Working Papers\\Data Various\\BACI (HS92)\\)

**Support Functions** BACI.functions.R

(Originally: D:\\work\\Peter_Herman\\projects\\trade_network_research\\rr_ergm_analysis\\original_code\\BACI.functions.R)

**Support Functions:** BACI_node_attributes.R

(originally: D:\\work\\Peter_Herman\\projects\\trade_network_research\\rr_ergm_analysis\\original_code\\BACI_node_attributes.R)

**List of countries:** 207countrylist.csv

(originally: "P:\Documents\Working Papers\ERGM Trade Networks\Data Work\BACISectors_v1\207countrylist.csv")

**Geographic Characteristics:** geo_cepii.dta

(originally: "G:\data\Peter Herman\Trade Network Reserach\Data\geo_cepii.dta")

**Gravity Data:** grav_data_1995to2015.csv

(originally: "G:\data\Peter Herman\Trade Network Reserach\Data\grav_data_1995to2015.csv")

**Country Name Correspondence:** country_name_correspondence.dta

(Originally: "P:\Documents\Working Papers\Data Various\countrynamecorrespondence_stata12.dta")



### Outputs
**1995 Model Fit** 1995_model_fit.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\original_code\results\BACI_agg_fit_extendedgravity1995_v1.rda")

**1995 Results Summary:** 1995_full_sample_results.txt

(Originally "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\original_code\results\ERGM_BACIagg_v4_gravity4paper_2019-04-30_13-06.txt")

**1995 GoF Plots:** 1995_full_sample_results_gof_plots.pdf

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\original_code\results\ERGM_BACIagg_v4_gravity4paper_2019-04-30_13-06__gof_plots.pdf")

**1995 Diagnostic Plots:** 1995_full_sample_results_diagnostic_plots.pdf

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\original_code\results\ERGM_BACIagg_v4_gravity4paper_2019-04-30_13-06__diagnostic_plots.pdf")


**2006 Model Fit** 2006_model_fit.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\original_code\results\BACI_agg_fit_extendedgravity2006_v1.rda")

**2006 Results Summary:** 2006_full_sample_results.txt

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\original_code\results\v4_2006_results_2019-06-21_11-54.txt" )

**2006 GoF Plots:** 2006_full_sample_results_gof_plots.pdf

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\original_code\results\ERGM_BACIagg_v4_gravity4paper_2019-04-30_13-06__gof_plots.pdf")

**2006 Diagnostic Plots:** 2006_full_sample_results_diagnostic_plots.pdf

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\original_code\results\ERGM_BACIagg_v4_gravity4paper_2019-04-30_13-06__diagnostic_plots.pdf")














## Partial Sample Models

### Scripts

**1995 Model:** 1995_partial_sample_ergm.r 

Takes in: 207countrylist.csv, geo_cepii.dta, grav_data_1948to2015.csv, partial_dataset_60-ctrys_50-pct_95-06_full_sample_network_vars.csv (doesn't use the network vars)

Outputs: 1995_ergm_partial_sample.txt, 1995_ergm_partial_sample_gof_obj.rda, 1995_ergm_partial_sample_gof_plots.pdf, 1995_ergm_partial_sample_diagnostic_plots.pdf, 1995_ergm_partial_sample_output.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\100_countries\june 17 60 countries 1995 gwesp.r")



**2006 Model:** 2006_partial_sample_ergm.r

Takes in: Takes in: 207countrylist.csv, geo_cepii.dta, grav_data_1948to2015.csv, partial_dataset_60-ctrys_50-pct_95-06_full_sample_network_vars.csv (doesn't use the network vars)

Outputs: 2006_ergm_partial_sample.txt, 2006_ergm_partial_sample_gof_obj.rda, 2006_ergm_partial_sample_gof_plots.pdf, 2006_ergm_partial_sample_diagnostic_plots.pdf, 2006_ergm_partial_sample_output.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\100_countries\june 13 60 countries 2006 gwesp.r")

### Inputs

**60 Country, 50th Percentile Dataset with original network variables** partial_dataset_60-ctrys_50-pct_95-06_full_sample_network_vars.csv

[Note: the ERGMS do not use the network stats so this version of the partial sample is fine.]

(Originally: "G:\data\Peter Herman\Trade Network Reserach\Data\60-ctrys_50-pct_95-06.csv") 

**Support Functions** BACI.functions.R

(Originally: D:\\work\\Peter_Herman\\projects\\trade_network_research\\rr_ergm_analysis\\original_code\\BACI.functions.R)

**Support Functions:** BACI_node_attributes.R

(originally: D:\\work\\Peter_Herman\\projects\\trade_network_research\\rr_ergm_analysis\\original_code\\BACI_node_attributes.R)

**List of countries:** 207countrylist.csv

(originally: "P:\Documents\Working Papers\ERGM Trade Networks\Data Work\BACISectors_v1\207countrylist.csv")

**Geographic Characteristics:** geo_cepii.dta

(originally: "G:\data\Peter Herman\Trade Network Reserach\Data\geo_cepii.dta")

**Gravity Data:** grav_data_1995to2015.csv

(originally: "G:\data\Peter Herman\Trade Network Reserach\Data\grav_data_1995to2015.csv")

### Outputs



**1995 Summary of Results** 1995_ergm_partial_sample.txt
(Originally:"D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\100_countries\60_countries_50_percentile_1995_v1_2019-06-18_03-09.txt")

**1995 Goodness of Fit Object** 1995_ergm_partial_sample_gof_obj.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\100_countries\60_countries_50_percentile_1995_v1_2019-06-18_03-09.txt_gof_obj.rda")

**1995 Goodness of Fit Plots** 1995_ergm_partial_sample_gof_plots.pdf

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\100_countries\60_countries_50_percentile_1995_v1_2019-06-18_03-09__gof_plots.pdf")

**1995 Diagnostic Plots** 1995_ergm_partial_sample_diagnostic_plots.pdf

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\100_countries\60_countries_50_percentile_1995_v1_2019-06-18_03-09__diagnostic_plots.pdf")

**1995 Model Fit Object** 1995_ergm_partial_sample_output.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\100_countries\60_countries_50_percentile_1995_v1_output.rda")

**2006 Summary of Results** 2006_ergm_partial_sample.txt

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\100_countries\60_countries_50_percentile_2006_v2_2019-06-14_02-20.txt")

**2006 Goodness of Fit Object** 2006_ergm_partial_sample_gof_obj.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\100_countries\60_countries_50_percentile_2006_v2_2019-06-14_02-20.txt_gof_obj.rda")

**2006 Goodness of Fit Plots** 2006_ergm_partial_sample_gof_plots.pdf

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\100_countries\60_countries_50_percentile_2006_v2_2019-06-14_02-20__gof_plots.pdf")

**2006 Diagnostic Plots** 2006_ergm_partial_sample_diagnostic_plots.pdf

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\100_countries\60_countries_50_percentile_2006_v2_2019-06-14_02-20__diagnostic_plots.pdf")

**2006 Model Fit Object** 2006_ergm_partial_sample_output.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\rr_ergm_analysis\100_countries\60_countries_50_percentile_2006_v2_output.rda")





# Comparisons

## Setp 1: Probit Network Simulation Scripts


**1995 Standard Probit Simulation:** 1995_standard_probit_simulation.R

Takes In: 1995_probit_predicted_probabilities_subset_network_stats.csv, BACI.functions.r

Outputs: 1995_standard_probit_simulation_gof_plots.pdf, 1995_standard_probit_simulation_gof_obj.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\1995\probit_simulation_v3_60-countries_50-pct_1995.R")


**1995 Network Probit Simulation:** 1995_probit_network_simulation.R

Takes in: 1995_probit_predicted_probabilities_subset_network_stats.csv, BACI.functions.r

Outputs: 1995_network_probit_simulation_gof_plots.pdf, 1995_network_probit_simulation_gof_obj.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\1995\network_probit_simulation_v3_60-countries_50-pct_1995_subset_network_stats.R")


**2006 Standard Probit Simulation:** 2006_standard_probit_simulation.R

Takes in: 2006_probit_predicted_probabilities_subset_network_stats.csv, BACI.functions.r

Outputs: 2006_standard_probit_simulation_gof_plots.pdf, 2006_standard_probit_simulation_gof_obj.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\2006\probit_simulation_v3_60-countries_50-pct_2006.R")


**2006 Network Probit Simulation:** 2006_network_probit_simulation.R

Takes in: 2006_probit_predicted_probabilities_subset_network_stats.csv, BACI.functions.r

Outputs: 2006_network_probit_simulation_gof_plots.pdf, 2006_network_probit_simulation_gof_obj.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\2006\network_probit_simulation_v3_60-countries_50-pct_2006_subset_network_stats.R")


### Inputs

**Predicted Link Probabilities from Probit Model:** 1995_probit_predicted_probabilities_subset_network_stats.csv

(Located: "D:\work\Peter_Herman\projects\trade_network_research\files_used_in_submission\gravity_analysis\comparrison_specifications\1995\1995_probit_predicted_probabilities_subset_network_stats.csv")

(Originally: D:\\work\\Peter_Herman\\projects\\trade_network_research\\Gravity Modeling\\Stata Analysis\\v3 - 60 countries\\60-ctrys_50-pct_1995_subset_network_stats\\probit_predicted_probabilities_subset_network_stats.csv)


**Support Functions:** BACI.functions.R 

(Located: "D:\work\Peter_Herman\projects\trade_network_research\files_used_in_submission\ergm_analysis\BACI.functions.R")

(Originally: "D:\\work\\Peter_Herman\\projects\\trade_network_research\\rr_ergm_analysis\\original_code\\BACI.functions.R")


### Outputs

**1995 Network Probit Goodness of Fit Object:** 1995_network_probit_simulation_gof_obj.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\2006\network_probit_simulation_v3_60-ctrys_50-pct_2006_subset_network_stats_gof_obj.rda")


**1995 Network Probit Goodness of Fit Plots:** 1995_network_probit_simulation_gof_plots.pdf

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\2006\network_probit_simulation_v3_60-ctrys_50-pct_2006_subset_network_stats_gof_plots.pdf")


**1995 Standard Probit Goodness of Fit Object:** 1995_standard_probit_situation_gof_obj.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\1995\probit_simulation_v3_60-ctrys_50-pct_1995_gof_obj.rda")


**1995 Standard Probit Goodness of Fit Plots:** 1995_standard_probit_situation_gof_plots.pdf

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\1995\probit_simulation_v3_60-ctrys_50-pct_1995_gof_plots.pdf")


**2006 Network Probit Goodness of Fit Object:** 2006_network_probit_simulation_gof_obj.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\2006\network_probit_simulation_v3_60-ctrys_50-pct_2006_subset_network_stats_gof_obj.rda")


**2006 Network Probit Goodness of Fit Plots:** 2006_network_probit_simulation_gof_plots.pdf

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\2006\network_probit_simulation_v3_60-ctrys_50-pct_2006_subset_network_stats_gof_plots.pdf")


**2006 Standard Probit Goodness of Fit Object:** 2006_standard_probit_simulation_gof_obj.rda

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\2006\probit_simulation_v3_60-ctrys_50-pct_2006_gof_obj.rda")


**2006 Standard Probit Goodness of Fit Plots:** 2006_standard_probit_simulation_gof_plots.pdf

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\2006\probit_simulation_v3_60-ctrys_50-pct_2006_gof_plots.pdf")







## Step 2: Compare Simulation

**1995 ERGM/Probit Comparisons:** 1995_ergm_probit_comparison.R

Takes in: comparison_functions.r, 1995_ergm_partial_sample_gof_obj.rda, 1995_standard_probit_situation_gof_obj.rda, 1995_network_probit_simulation_gof_obj.rda

Outputs: 1995_combined_gof_tables_standard_probit.csv, 1995_combined_gof_tables_network_probit.csv 

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\1995\ergm_probit_comparrison_60-ctrys_50-pct_1995.R")



**2006 ERGM/Probit Comparisons:**

Takes in: comparison_functions.r, 2006_ergm_partial_sample_gof_obj.rda, 2006_standard_probit_simulation_gof_obj.rda, 2006_network_probit_simulation_gof_obj.rda

Outputs: 2006_combined_gof_tables_standard_probit.csv, 2006_combined_gof_tables_network_probit.csv

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\2006\ergm_probit_comparrison_60-ctrys_50-pct_2006.R")


**Comparison Tools:** comparison_functions.R

A collection of tools to extract, combine, and report comparisons from goodness of fit objects.

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\comparison_function.R")



### Inputs

**1995 ERGM GoF Object:** 1995_ergm_partial_sample_gof_obj.rda

(Located: "D:\work\Peter_Herman\projects\trade_network_research\files_used_in_submission\ergm_analysis\Partial Sample\1995_ergm_partial_sample_gof_obj.rda")

(Originally: D:\\work\\Peter_Herman\\projects\\trade_network_research\\rr_ergm_analysis\\100_countries\\60_countries_50_percentile_1995_v1_2019-06-18_03-09.txt_gof_obj.rda)


**1995 Standard Probit GoF Object:** 1995_standard_probit_situation_gof_obj.rda

(Originally: "D:\\work\\Peter_Herman\\projects\\trade_network_research\\probit_ergm_gof\\v3_60_countries_50_percent\\1995\\probit_simulation_v3_60-ctrys_50-pct_1995_gof_obj.rda")


**1995 Network Probit GoF Object:** 1995_network_probit_simulation_gof_obj.rda

(Originally: "D:\\work\\Peter_Herman\\projects\\trade_network_research\\probit_ergm_gof\\v3_60_countries_50_percent\\1995\\network_probit_simulation_v3_60-ctrys_50-pct_1995_subset_network_stats_gof_obj.rda")


**2006 ERGM GoF Object:** 2006_ergm_partial_sample_gof_obj.rda

(Located: "D:\work\Peter_Herman\projects\trade_network_research\files_used_in_submission\ergm_analysis\Partial Sample\2006_ergm_partial_sample_gof_obj.rda")

(Originally: "D:\\work\\Peter_Herman\\projects\\trade_network_research\\rr_ergm_analysis\\100_countries\\60_countries_50_percentile_2006_v2_2019-06-14_02-20.txt_gof_obj.rda")


**2006 Standard Probit Object:** 2006_standard_probit_simulation_gof_obj.rda

(Originally: "D:\\work\\Peter_Herman\\projects\\trade_network_research\\probit_ergm_gof\\v3_60_countries_50_percent\\2006\\probit_simulation_v3_60-ctrys_50-pct_2006_gof_obj.rda")


**2006 Network Probit Object** 2006_network_probit_simulation_gof_obj.rda

(Originally: "D:\\work\\Peter_Herman\\projects\\trade_network_research\\probit_ergm_gof\\v3_60_countries_50_percent\\2006\\network_probit_simulation_v3_60-ctrys_50-pct_2006_subset_network_stats_gof_obj.rda")


**Support Functions:** BACI.functions.R 

(Located: "D:\work\Peter_Herman\projects\trade_network_research\files_used_in_submission\ergm_analysis\BACI.functions.R")

(Originally: "D:\\work\\Peter_Herman\\projects\\trade_network_research\\rr_ergm_analysis\\original_code\\BACI.functions.R")



### Outputs

**1995 ERGM/Standard Probit Comparison Tables:** 1995_combined_gof_tables_standard_probit.csv

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\1995\combined_gof_tables_standard_probit.csv")


**1995 ERGM/Network Probit Comparison Tables:** 1995_combined_gof_tables_network_probit.csv

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\1995\combined_gof_tables_network_probit_subset_network_stats.csv")


**2006 ERGM/Standard Probit Comparison Tables:** 2006_combined_gof_tables_standard_probit.csv

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\2006\combined_gof_tables_standard_probit.csv")


**2006 ERGM/Network Probit Comparison Tables:** 2006_combined_gof_tables_network_probit.csv

(Originally: "D:\work\Peter_Herman\projects\trade_network_research\probit_ergm_gof\v3_60_countries_50_percent\2006\combined_gof_tables_network_probit_subset_network_stats.csv")







