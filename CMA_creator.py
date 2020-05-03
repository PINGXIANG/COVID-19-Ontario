import os
import pandas

# Set up working dir
CWD = os.path.dirname(
    os.path.abspath(__file__))  # If failed to work, change the working dir to your current working dir manually
os.chdir(CWD)

# Get the df of COVID-19 cases and df of population
df = pandas.read_csv("455fd63b-603d-4608-8216-7d8647f43350.csv")

ppl_df = pandas.read_csv("T20120200501055302.CSV")
ppl_df = ppl_df[ppl_df["Population, 2016"].notna() & ppl_df["Geographic name"].notna()].loc[1:, :]  # Delete the note and Canada info
ppl_df = ppl_df[["Geographic name", "Population, 2016"]]  # Keep only the 2016 population and Geographic name
ppl_df.rename(columns={"Geographic name": "CMA_PHU_city"}, inplace=True)  # Change to name of ppl_df for left_join method later on

########################################################################################################################
### Assign the name for each PHU_city as CMA_PHU_city
# Create the dic {census division city name -> CMA city name} manually
dic = {
    "Whitby": "Oshawa",
    "Thorold": "St. Catharines - Niagara",
    "St. Thomas": "London",
    "Point Edward": "Sarnia",
    "Chatham": "Chatham-Kent",
    "Oakville": "Toronto",
    "Newmarket": "Toronto",
    "Waterloo": "Kitchener - Cambridge - Waterloo",
    "Mississauga": "Toronto",
    "Ottawa": "Ottawa - Gatineau (Ontario part / partie de l'Ontario)",
    "Sudbury": "Greater Sudbury / Grand Sudbury"
}

# Create a new column mapping from df.Reporting_PHU_City to df.CMA_PHU_city
CMA_PHU_city = []
for i in range(len(df)):
    if df.loc[i, "Reporting_PHU_City"] in dic:
        CMA_PHU_city.append(dic[df.loc[i, "Reporting_PHU_City"]])
    else:
        CMA_PHU_city.append(df.loc[i, "Reporting_PHU_City"])
df["CMA_PHU_city"] = CMA_PHU_city

########################################################################################################################


########################################################################################################################
### Give population to CMA_PHU_city in df
# Create a new df mapping from ppl_df.Geometric.name to df.CMA_PHU_city_ppl
df = pandas.merge(df, ppl_df, how='left', on=['CMA_PHU_city'])

# # Test
# CMA_cities = set(ppl_df["CMA_PHU_city"])
# CMA_PHU_cities = set(df["CMA_PHU_city"])
# diff = CMA_PHU_cities - CMA_cities

# Create the dic {CMA city name -> PPL CMA city name} manually
ppl_dic = {"Ottawa - Gatineau (Ontario part / partie de l'Ontario)": "Ottawa - Gatineau (Ontario part)",
           'Greater Sudbury / Grand Sudbury': "Greater Sudbury",
           # 'New Liskeard': None,
           # 'Simcoe': None,
           }


for i in range(len(df)):
    if df.loc[i, "CMA_PHU_city"] in ppl_dic:
        j = ppl_df.index[ppl_df["CMA_PHU_city"] == ppl_dic[df.loc[i, "CMA_PHU_city"]]].tolist()[0]  # Get the index of ppl_df for this city
        df.loc[i, "Population, 2016"] = ppl_df.loc[j, "Population, 2016"]  # Set the ppl for that row


# Save the new df as XXX_new.csv for further usage
df.rename(columns={"Population, 2016": "Population"}, inplace=True)

df.to_csv("455fd63b-603d-4608-8216-7d8647f43350_new.csv", index=False)
########################################################################################################################


if __name__ == "__main__":
    pass
