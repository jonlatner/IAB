# Top commands ----
# https://alfurka.github.io/2023-01-30-creating-synthetic-values-with-synthepop-cart/
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
library(janitor)

# FOLDERS - ADAPT THIS PATHWAY
main_dir = "/Users/jonathanlatner/Documents/GitHub/IAB/simulation_data/continuous_dim/"

data_files = "data_files/synthetic/ctgan/"

setwd(main_dir)

# Load data ----

df_ctgan <- read.csv(paste0(data_files,"loss_function.csv")) 

# Clean data ----

df_ctgan <- clean_names(df_ctgan)
df_ctgan$epochs <- gsub("Epoch ", "", df_ctgan$epochs)
df_ctgan$loss_g <- gsub(" Loss G: ", "", df_ctgan$loss_g)
df_ctgan$loss_d <- gsub("Loss D: ", "", df_ctgan$loss_d)
df_ctgan <- data.frame(lapply(df_ctgan, as.numeric))
df_ctgan <- pivot_longer(df_ctgan, !epochs)

# Graph data ----

df_graph <- ggplot(df_ctgan, aes(x = epochs, y = value, color = name)) +
  geom_line(linewidth = 1) +
  theme_bw() +
  theme(panel.grid.minor = element_blank(), 
        legend.position = "bottom",
        legend.title = element_blank(), 
        legend.key.width=unit(1, "cm"),
        axis.line.y = element_line(color="black", linewidth=.5),
        axis.line.x = element_line(color="black", linewidth=.5)
  )

df_graph

