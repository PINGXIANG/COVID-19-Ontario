# COVID-19-Ontario
This is a subproject to support Prof Luo's analysis paper.

##Result:

  ppl_plots: the plot for total number of cases for each CMA city
  per_plots: the plot for percentage of cases for each CMA city based on population/1000
  
  summary_cases: the numerical result of cases for future useage
	- ppl: population
	- per: percentage

##To re-run:

Python packages may need to install:
  pandas: pip install pandas

R packages may need to instaill:
  packages = c(sf,
	         ggplot2,
	         dplyr,
	         data.table)

Step 1: Run CMA_creator.py to obtain "xxx_new.csv" from "###.csv" (case_data) and "T###.csv" (ppl_data).
Step 2: Run df_ploter.R to obtain "summary_cases.csv" and per_plots and ppl_plots from "###_new.csv" and "T###.csv". 
Step 3: Open the per_plots and ppl_plots directories and enjoy ~

## rsc:
"T###.csv": 
  https://www12.statcan.gc.ca/census-recensement/2016/dp-pd/hlt-fst/pd-pl/Table.cfm?Lang=Eng&T=201&SR=1&S=3&O=D&RPP=9999

*** Note: 
the file name will change every time we download (I guess the same thing happens for "###.csv" as well). Further modification should be considered.
For example, make it automatically obtains the file name (which is hard since both of them are .csv file, hard to distinguish), or save the file to different directory, or save the file name in a new .txt file.
For now, you have to modify the file name at the begining of df_ploter.R and CMA_creator.py.


