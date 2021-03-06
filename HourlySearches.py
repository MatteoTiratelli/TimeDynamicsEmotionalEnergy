import pandas as pd
from pytrends.request import TrendReq

# Set up dataframe of search specifications

search_df = pd.DataFrame()
search_df["Event"] = ['Charlie Hebdo shooting','November 2015 Paris attacks',
                           '2016 Nice truck attack','2016 Berlin truck attack',
                           'Boston Marathon bombings','Manchester Arena bombing',
                           '2016 Brussels bombings', '2017 Barcelona attacks']
search_df["TopicSearchCode"] = ['terrorisme','terrorisme','terrorisme','terrorismus',
                                     'terrorism','terrorism','terrorisme','terrorismo']
search_df["Country"] = ['FR','FR','FR','DE','US','GB','BE','ES']
search_df['year_s'] = [2015,2015,2016,2016,2013,2017,2016,2017]
search_df['month_s'] = [1,11,7,12,4,5,3,8]
search_df['day_s'] = [6,12,13,18,14,21,21,16]
search_df['hour_s'] = [1,1,1,1,1,1,1,1]
search_df['year_e'] = [2015,2015,2016,2016,2013,2017,2016,2017]
search_df['month_e'] = [1,11,7,12,4,5,3,8]
search_df['day_e'] = [12,18,19,24,20,27,27,22]
search_df['hour_e'] = [1,1,1,1,1,1,1,1]

# Execute pytrends search by row, save output as separate csv file and to dictionary of dataframes which can be accessed directly in R 
# reticulate::py_run_file("https://raw.githubusercontent.com/MatteoTiratelli/TimeDynamicsEmotionalEnergy/main/Appendix/HourlySearches.py")
# list_of_dfs <- py$list_of_dfs

list_of_dfs = {}
pytrends = TrendReq()
for row in search_df.itertuples():
    try:
        kw_list = [row.TopicSearchCode]
        interest_over_time_df = pytrends.get_historical_interest(kw_list, geo=row.Country,
        	                                 year_start=row.year_s,
                                             month_start=row.month_s, day_start=row.day_s,
                                             hour_start=row.hour_s, year_end=row.year_e,
                                             month_end=row.month_e, day_end=row.day_e, hour_end=row.hour_e)
        interest_over_time_df["Event"] = row.Event
        list_of_dfs[row.Event] = interest_over_time_df
        interest_over_time_df.to_csv(f"/Users/matteo/Downloads/export/{row.Index}.csv")
        print(f"{row.Event} succesfully downloaded")
    except Exception as e:
        print(f"{row.Event} not downloaded because of the following error:" + str(e))
        continue  

