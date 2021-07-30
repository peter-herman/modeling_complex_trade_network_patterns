__author__ = "Peter Herman"
__project__ = "trade_network_revisions_2020"
__description__ = "This scxript prepares the data for the FLEX model of the extensive margin."


import os as os
import pandas as pd

# ---
# Specifications
# ---

baci_directory = "data\\BACI (HS92)"
code_concordance_local = "data\\country_name_correspondence.dta"
cepii_grav_local = "data\\grav_data_1995to2015.csv"
baci_countries_loc = "data\\country_code_baci92.csv"
country_list = "data\\207countrylist.csv"
est_data_local = "data\\gravity_estimation_data.csv"

years = list(range(1995,2007))
version = 'v1'
save_location = "gravity\\FLEX"


# ---
# Prep trade data
# ---
count_datasets = list()
# for file in os.listdir(baci_directory):
#     if file.endswith('.csv') and file!='country_code_baci92.csv':
for yr in years:
    file = "baci92_{}.csv".format(yr)
    # Load data
    year_data = pd.read_csv(os.path.join(baci_directory, file), encoding = 'latin')
    # Drop zero values if any
    year_data = year_data.loc[year_data['v']>0,['t','i','j','hs6']]
    # Count by importer-exporter-year
    year_count_data = year_data.groupby(['t','i','j']).count().reset_index()
    count_datasets.append(year_count_data)

# Combine years
count_data = pd.concat(count_datasets, axis = 0)



# ---
# Concord country names
# ---
country_codes = pd.read_stata(code_concordance_local)
country_codes= country_codes[['CountryCode','ISO3digitAlpha']]
country_codes.sort_values('ISO3digitAlpha', inplace = True)

# Replace iso code for Antartica (10) so that it doesn't conflict with Nth. Antilles (530), which both map to 'ANT'.
country_codes.loc[country_codes['CountryCode']==10,'ISO3digitAlpha'] = 'ATA'

flex_panel = count_data.merge(country_codes, how ='left', left_on ='i', right_on='CountryCode', validate="m:1")
flex_panel.rename(columns = {'ISO3digitAlpha': 'exporter'}, inplace = True)
flex_panel = flex_panel.merge(country_codes, how ='left', left_on ='j', right_on='CountryCode', validate="m:1")
flex_panel.rename(columns = {'ISO3digitAlpha': 'importer'}, inplace = True)
flex_panel.drop(['CountryCode_x', 'CountryCode_y'], axis = 1, inplace = True)
flex_panel.rename(columns = {'t':'year'}, inplace = True)

# Check that all 207 desired countries are labeled.
used_countries = pd.read_csv(country_list)
used_countries = used_countries['x'].unique().tolist()
data_countries = set(flex_panel['importer'].unique().tolist()).union(set(flex_panel['exporter'].unique().tolist()))
missing_countries = [cntry for cntry in used_countries if cntry not in data_countries]
if len(missing_countries)>0:
    raise ValueError('Some unlabeled countries.')

uncoded = flex_panel.loc[flex_panel['importer'].isna() | flex_panel['exporter'].isna(),:]

flex_panel = flex_panel.loc[flex_panel['exporter'].isin(used_countries),:]
flex_panel = flex_panel.loc[flex_panel['importer'].isin(used_countries),:]
# duplicates = flex_panel.duplicated(['exporter', 'importer', 'year'], keep = False)
# duplicates = flex_panel.loc[duplicates, :].copy()

# ---
# Create Square Panel
# ---
years_used = flex_panel['year'].unique().tolist()
square_list = [(exp, imp, yr) for exp in used_countries for imp in used_countries for yr in years_used if exp != imp]
square_panel = pd.DataFrame(square_list, columns = ['exporter', 'importer', 'year'])
square_panel = square_panel.merge(flex_panel, how = 'left', on = ['exporter', 'importer', 'year'], validate = '1:1')
square_panel.drop(['i','j'], axis = 1, inplace = True)
square_panel['hs6'].fillna(0, inplace = True)


# ---
# Add network variables
# ---
other_data = pd.read_csv(est_data_local)
square_panel = square_panel.merge(other_data, how = 'left', on = ['exporter', 'importer', 'year'], validate = '1:1',
                                  indicator=True)
unmatched = square_panel.loc[square_panel['_merge']=='left_only',:]


# ---
# Export
# ---
square_panel.to_csv("{}\\flex_count_panel_{}.csv".format(save_location, version), index = False)


