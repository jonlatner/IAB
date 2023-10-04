# Top commands ----

# Create empty R application (no figures, data frames, packages, etc.)
# Get a list of all loaded packages
packages <- search()[grepl("package:", search())]
# Unload each package
for (package in packages) {
  unloadNamespace(package)
}

rm(list=ls(all=TRUE))

# load library
library(tidyverse)
library(synthpop)
library(ggh4x) # facet_nested

# FOLDERS - ADAPT THIS PATHWAY
main_dir = "/Users/jonathanlatner/Documents/GitHub/IAB/simulation_data/continuous_dim/"

data_files = "data_files/"
original_data = "data_files/original/"
graphs = "graphs/"
tables = "tables/"

setwd(main_dir)

#functions
options(scipen=999) 

# Load original data ----


# Dimensions
rows = [500000] # Rows/observations
cols = [10] # Columns/variables

for r in rows:
    for c in cols:
        
        # load data
        filename_ods = f"ods_rows_{r}_cols_{c}.csv"
        df_ods = pd.read_csv(os.path.join(original_data, filename_ods), index_col=False)

df_ods.describe()