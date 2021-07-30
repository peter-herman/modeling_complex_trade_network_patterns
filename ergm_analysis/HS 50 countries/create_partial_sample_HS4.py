__author__ = "Peter Herman"
__project__ = "trade_network_revisions_2020"
__description__ = "This script looks at trade data to examine good choices for sector level analysis in the ERGMs."

import pandas as pd
import numpy as np
from itertools import product
import os as os
from github_repo.tools.TraderRanking import TraderRanking


# ----
# Specs
# ----
baci_directory = "data\\BACI (HS92)"
code_concordance_local = "data\\country_name_correspondence.dta"
cepii_grav_local = "data\\grav_data_1995to2015.csv"
baci_countries_loc = "data\\country_code_baci92.csv"

data_locs = ["data\\baci92_1995.csv",
             "data\\baci92_2006.csv"]

years = [1995, 2006]

save_loc = "ergm_analysis\\HS 50 countries\\data"

country_number = 50
sector_list = ['0901','8703']

# ----
# Examine Density of HS2 networks in 1995 and 2006
# ----

# Load data
raw_datas = list()
for file in data_locs:
    loaded_data = pd.read_csv(file, dtype={'hs6':str})
    raw_datas.append(loaded_data)
raw_data = pd.concat(raw_datas, axis = 0)
raw_data['hs2'] = raw_data['hs6'].str[0:4]

sectors = raw_data['hs2'].unique()

# Aggregate to HS2
agg_trade = raw_data.groupby(['i','j','t']).agg({'v':'sum'}).reset_index()
# Drop non-country codes that don't have gravity data
drop_countries = [490, 839]
agg_trade = agg_trade.loc[(~agg_trade['i'].isin(drop_countries)) & (~agg_trade['j'].isin(drop_countries)),:]
ranking = TraderRanking(agg_trade,imp_var_name='j', exp_var_name='i',trade_var_name='v', year_var_name='t')
top_countries = ranking.top_countries(country_number=country_number)
top_countries = pd.DataFrame(top_countries, columns = ['country_code'])
cumulative_ranking = ranking.ranking()

#
# Add numeric codes to top countries
baci_codes = pd.read_csv(baci_countries_loc, encoding = 'latin')
baci_codes = baci_codes[['iso3','i']].sort_values('iso3')
# Drop a secondary SDN code that does not appear in the trade data
baci_codes = baci_codes.loc[baci_codes['i']!=729,:]
top_countries_labeled = top_countries.merge(baci_codes, how = 'left', left_on = 'country_code', right_on = 'i', validate = '1:1')

top_traders = top_countries['country_code'].tolist()

# Create square panel
all_combos = list(product(top_traders, top_traders, years, sectors))
square_panel = pd.DataFrame(all_combos, columns = ['j','i','t','hs2'])
square_panel = square_panel.loc[square_panel['i']!=square_panel['j'],:]

# Agg by chapter and merge to square panel
chapter_data = raw_data.groupby(['i','j','t','hs2']).agg({'v':sum})
square_panel = square_panel.merge(chapter_data, how = 'left', on=['i','j','t','hs2'], validate = "1:1")

# Create Extensive Margin Indicator
square_panel['v'].fillna(0, inplace = True)
square_panel['traded'] = 0
square_panel.loc[square_panel['v']>0,'traded'] = 1

# Check density of each chapter/year
density = square_panel.groupby(['hs2','t']).agg({'traded':'mean'}).reset_index()
density = density.set_index(['hs2','t']).unstack('t')

for ppml_sector in sector_list:
    # Output Data for use in ERGM analyses
    hs51_1995 = square_panel.loc[(square_panel['hs2']==ppml_sector) & (square_panel['t']==1995) & (square_panel['traded']==1),:].copy()
    hs51_2006 = square_panel.loc[(square_panel['hs2']==ppml_sector) & (square_panel['t']==2006) & (square_panel['traded']==1),:].copy()

    hs51_1995.to_csv("{}\\hs{}_baci_data_1995_top{}_traders.csv".format(save_loc,ppml_sector,country_number),index=False)
    hs51_2006.to_csv("{}\\hs{}_baci_data_2006_top{}_traders.csv".format(save_loc,ppml_sector,country_number),index=False)



# ----
# Prep Data for PPML estimation of sector FEs
# ----

baci_files = os.listdir(baci_directory)
baci_files = [file for file in baci_files if file.startswith('baci92') and file.endswith('.csv')]

raw_bacis = list()
for file in baci_files:
    loaded_data = pd.read_csv("{}\\{}".format(baci_directory,file), dtype={'hs6':str})
    raw_bacis.append(loaded_data)
baci_data = pd.concat(raw_bacis, axis=0)

# Create HS2 variable
baci_data['hs2'] = baci_data['hs6'].str[0:4]
# Aggregate to HS Chapter
baci_agg = baci_data.groupby(['i','j','t','hs2']).agg({'v':sum}).reset_index()

all_years = baci_agg['t'].unique()

for ppml_sector in sector_list:
    # Create new square panel
    expected_dimensions = len(top_traders)*(len(top_traders)-1)*len(all_years)*len([ppml_sector])
    ppml_combos = product(top_traders, top_traders, all_years, [ppml_sector])
    ppml_panel = pd.DataFrame(ppml_combos, columns = ['i','j','t','hs2'])
    ppml_panel = ppml_panel.loc[ppml_panel['j']!= ppml_panel['i'],:]

    # Add trade data to square panel
    ppml_panel = ppml_panel.merge(baci_agg, how ='left', validate="1:1", on = ['i','j','t','hs2'])
    ppml_panel['v'].fillna(0,inplace = True)

    # concord country names
    country_codes = pd.read_stata(code_concordance_local)
    country_codes= country_codes[['CountryCode','ISO3digitAlpha']]
    country_codes.sort_values('ISO3digitAlpha', inplace = True)

    ppml_panel = ppml_panel.merge(country_codes, how = 'left', left_on = 'i', right_on='CountryCode', validate="m:1")
    ppml_panel.rename(columns = {'ISO3digitAlpha':'exporter'}, inplace = True)
    ppml_panel = ppml_panel.merge(country_codes, how = 'left', left_on = 'j', right_on='CountryCode', validate="m:1")
    ppml_panel.rename(columns = {'ISO3digitAlpha':'importer'}, inplace = True)
    ppml_panel.drop(['CountryCode_x', 'CountryCode_y'], axis = 1, inplace = True)

    # Add Grav Data
    grav_data = pd.read_csv(cepii_grav_local)
    grav_data['lndist'] = np.log(grav_data['distw'])
    grav_data = grav_data[['iso3_o', 'iso3_d', 'year', 'lndist', 'contig', 'comlang_ethno', 'colony', 'rta']]

    est_panel = ppml_panel.merge(grav_data, how='left', left_on = ['exporter','importer','t'],
                                 right_on = ['iso3_o','iso3_d','year'], validate="m:1")
    est_panel.drop(['i','j','t','iso3_o','iso3_d'], axis = 1, inplace=True)
    est_panel.rename(columns={'v':'trade_value'}, inplace = True)

    est_panel.to_stata("{}\\ppml_hs{}_panel_top{}.dta".format( save_loc, ppml_sector, country_number))

country_list = pd.DataFrame(top_traders, columns = ['CountryCode'])
country_list = country_list.merge(country_codes, how = 'left', on = 'CountryCode')
country_list.to_csv("{}\\top_{}_countries.csv".format(save_loc, country_number), index=False)

