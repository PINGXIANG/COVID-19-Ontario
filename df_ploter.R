####################################################################################################
### Set up

# Set up the library needed
library(sf)
library(ggplot2)
library(dplyr)
theme_set(theme_bw())
library(data.table)

# Set up the current dir
CWD = dirname(rstudioapi::getSourceEditorContext()$path)  # If failed, give the current working dir manually
setwd(CWD)

# Set up the rsc 
map_shp = "./lcma000a16a_e/lcma000a16a_e.shp"
dt_csv = "455fd63b-603d-4608-8216-7d8647f43350_new.csv"
cma_csv = "T20120200501055302.csv"

df = read.csv(dt_csv, header = T)
ppl = read.csv(cma_csv, header = T)
map = st_read(map_shp)
map = map[map$PRNAME == "Ontario",]

####################################################################################################


####################################################################################################
### Summary the cumulating COVID-19 cases

`%notin%` <- Negate(`%in%`)  # Create notin method
# Find the same city name in df and CMA city name in map
same_CMA_ctiy_name = unique(df[df$CMA_PHU_city %in% map$CMANAME,]$CMA_PHU_city)  # 28: ...
# Find the diff city name in df and CMA city name in map
diff_CMA_city_name = unique(df[df$CMA_PHU_city %notin% map$CMANAME,]$CMA_PHU_city)  # 2: "New Liskeard" "Simcoe" 


# Create a summary df with cumulating COVID-19 cases for each CMA_city given every 7 days
# *** Note: CMA cities not given in the df would be assigned as NA by left_join method.

# Initial the summary_df
summary_df = as.data.frame(c(same_CMA_ctiy_name, "Ontario"))
colnames(summary_df) = c("CMANAME")
#View(summary_df)

# Assign the ppl to each CMA city
ppl_df = df[c("CMA_PHU_city", "Population")]
ppl_df = unique(ppl_df)
colnames(ppl_df) = c("CMANAME", "Population")

summary_df = left_join(summary_df, ppl_df, c("CMANAME"))

total_ppl =as.numeric(ppl[ppl$Geographic.name == "Ontario", ]["Population..2016"]) 
summary_df[summary_df$CMANAME == "Ontario", ]["Population"] = total_ppl


# Summary the df to summary_df. (takes around 30s, python would work better given dict)
date = as.IDate("2020-03-17")  # Start date
while (date <= max(df$Accurate_Episode_Date)) {  # While date less or equal to the newest date
  cases_date = c()
  for (CMANAME in summary_df$CMANAME) {  # For each CMANAME in summary_df
    cases_date = c(cases_date, nrow(df[df$Accurate_Episode_Date <= date & df$CMA_PHU_city == CMANAME,]))
  }
  cases_date[length(cases_date)] = nrow(df[df$Accurate_Episode_Date <= date,])  # Ontario_case_date
  
  col_name = paste("ppl-", toString(date))
  summary_df[[col_name]] = cases_date  # Save the column to summary_df for that date
  
  date = date + 7
}

for (i in 3:ncol(summary_df)) {
  # Create the per- date name
  col_name = paste("per-", substr(colnames(summary_df)[i], start = 6, stop = nchar(colnames(summary_df)[i])))
  summary_df[[col_name]] = summary_df[,i]/summary_df$Population*1000
}


# Save the summary_df as summary_cases.csv for future usage
write.csv(summary_df, "summary_cases.csv", row.names=FALSE)

####################################################################################################


####################################################################################################
### Set up map

summary_map = left_join(map, summary_df, c("CMANAME"))
#View(summary_map)

# *** In case one may want to create a map with na elimated 
#non_na_map = map[map$CMANAME %in% unique(summary_df$CMANAME),]
#non_na_summary_map = left_join(non_na_map, summary_df, c("CMANAME"))
#View(non_na_summary_map)


# Get the center pnts for each cities in the map
ontario_city_pnts = st_centroid(summary_map)  
ontario_city_pnts = cbind(summary_map, st_coordinates(st_centroid(summary_map$geometry)))  

# Extract the first word of CMANAME as the city name present in the plot
ontario_city_pnts["CMANAME"] = gsub("([A-Za-z]+).*", "\\1", ontario_city_pnts$CMANAME)


## Plot the graphs
n = ncol(summary_df)
ppl_dates = colnames(summary_df)[3: (3+(n-2)/2)]
per_dates = colnames(summary_df)[(3+(n-2)/2): n]
summary_map[[date]]

# Plot the ppl graphs
dir.create(file.path("./ppl_plots"), showWarnings = FALSE)

for (date in ppl_dates) {
  # Open a png file
  path = paste("./ppl_plots/", paste(toString(date)), ".png")
  png(path) 
  
  # Do the plot
  case_plot = ggplot(data = summary_map) +
    geom_sf() +
    xlab("Longitude") + ylab("Latitude") +
    ggtitle("Ontario map") + 
    geom_sf(aes(fill = .data[[date]])) +  
    scale_fill_gradient(low="yellow", high="red", limits=c(0, 9000), 
                        na.value = "gray") 
  
  # Present the plot
  print(case_plot)
  
  # Save the plot
  dev.off()
}


# Plot the per graphs
dir.create(file.path("./per_plots"), showWarnings = FALSE)

for (date in per_dates) {
  # Open a png file
  path = paste("./per_plots/", paste(toString(date)), ".png")
  png(path) 
  
  # Do the plot
  case_plot = ggplot(data = summary_map) +
    geom_sf() +
    xlab("Longitude") + ylab("Latitude") +
    ggtitle("Ontario map") + 
    geom_sf(aes(fill = .data[[date]])) +  
    scale_fill_gradient(low="yellow", high="red", limits=c(0, 8), 
                        na.value = "gray") 
  
  # Present the plot
  print(case_plot)
  
  # Save the plot
  dev.off()
}



####################################################################################################
