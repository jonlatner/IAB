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
# main_dir = "N:/Ablagen/D01700-KEM/Latner/little_etal_2021/"
main_dir = "/Users/jonathanlatner/Documents/GitHub/IAB/simulation_data/continuous_dim/"

data_files = "data_files/"
original_data = "data_files/original/"
synthetic_data = "data_files/synthetic/ctgan/"
graphs = "graphs/"
tables = "tables/"

setwd(main_dir)

# Create fake synthetic data ----

# Dimensions
# rows = c(5000) # Rows/observations
# cols = c(10) # Columns/variables

# for (r in rows) {
#   for (c in cols) {
#     df_ods <- read.csv(paste0(original_data,"ods_rows_",r,"_cols_",c,".csv"))
#     copies <- c(1)
#     for (c in copies) {
#       df_synds <- syn(df_ods, m = c)
#       saveRDS(df_synds, paste0(data_files,"synthetic/synds_",c,".rds"))
#     }
#   }
# }
  
# Load original data ----
# Dimensions
rows = c(5000) # Rows/observations
cols = c(10) # Columns/variables

for (r in rows) {
  for (c in cols) {
    df_ods <- read.csv(paste0(original_data,"ods_rows_",r,"_cols_",c,".csv"))
  }
}

# convert continuous variables to bins
continuous_vars <- sapply(df_ods, function(x) is.numeric(x))
continuous_var_names <- names(df_ods[continuous_vars])
df_ods_binned <- df_ods
for (col_name in continuous_var_names) {
  bins <- seq(min(df_ods_binned[[col_name]]), max(df_ods_binned[[col_name]]), length.out = 21) # 21 points to get 20 bins
  df_ods_binned[[col_name]] <- cut(df_ods_binned[[col_name]], breaks = bins, include.lowest = TRUE)
}

df_ods_long <- df_ods_binned %>%
  mutate(index = row_number()) %>%
  pivot_longer(cols = -index, names_to = "variables", values_to = "value")%>%
  select(-index) %>%
  group_by(variables, value) %>%
  tally() %>%
  mutate(total = sum(n)) %>%
  ungroup() %>%
  mutate(pct = n/total)

# graph
df_graph <- ggplot(df_ods_long, aes(x = value, y = pct)) +
  geom_bar(position = "dodge", stat = "identity") +
  facet_wrap( ~ variables, scales = "free", labeller = labeller(.cols = label_both), nrow = 2) +
  xlab("") +
  ylab("") +
  theme_bw() +
  guides(colour = guide_legend(nrow = 1)) +
  theme(panel.grid.minor = element_blank(), 
        legend.position = "bottom",
        legend.key.width=unit(1, "cm"),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.line.y = element_line(color="black", linewidth=.5),
        axis.line.x = element_line(color="black", linewidth=.5)
  )

df_graph

# Load synthetic data ----

df_sds <- data.frame()
epochs = c(10, 20, 30)
for (r in rows) {
  for (c in cols) {
    for (e in epochs) {
      sds <- read.csv(paste0(synthetic_data,"sds_ctgan_rows_",r,"_cols_",c,"_n_1_epochs_",e,".csv"))
      sds$epochs = e
      df_sds <- rbind(df_sds, sds)
    }
  }
}


# convert continuous variables to bins
continuous_vars <- sapply(df_sds, function(x) is.numeric(x))
continuous_var_names <- names(df_sds[continuous_vars])
df_sds_binned <- df_sds
for (col_name in continuous_var_names) {
  bins <- seq(min(df_sds_binned[[col_name]]), max(df_sds_binned[[col_name]]), length.out = 21) # 21 points to get 20 bins
  df_sds_binned[[col_name]] <- cut(df_sds_binned[[col_name]], breaks = bins, include.lowest = TRUE)
}
df_sds_binned$epochs <- df_sds$epochs

df_sds_long <- df_sds_binned %>%
  pivot_longer(cols = !epochs, names_to = "variables", values_to = "value") %>%
  group_by(variables, value, epochs) %>%
  tally() %>%
  mutate(total = sum(n)) %>%
  ungroup() %>%
  mutate(pct = n/total,
         epochs = as.factor(epochs))

# Graph
df_graph <- ggplot(df_sds_long, aes(x = value, y = pct, color = epochs, group = epochs)) +
  geom_line() +
  facet_wrap( ~ variables, scales = "free", labeller = labeller(.cols = label_both), nrow = 2) +
  xlab("") +
  ylab("") +
  theme_bw() +
  guides(colour = guide_legend(nrow = 1)) +
  theme(panel.grid.minor = element_blank(), 
        legend.position = "bottom",
        legend.key.width=unit(1, "cm"),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.line.y = element_line(color="black", linewidth=.5),
        axis.line.x = element_line(color="black", linewidth=.5)
  )

df_graph

# Combine data ----

df_long <- df_ods_long
df_long$epochs <- "Original"

df_long <- rbind(df_long, df_sds_long)
df_long$epochs <- fct_relevel(df_long$epochs, "Original")


# Graph
df_graph <- ggplot(df_long, aes(x = value, y = pct, fill = epochs, group = epochs)) +
  geom_bar(position = "dodge", stat = "identity") +
  facet_wrap( ~ variables, scales = "free", labeller = labeller(.cols = label_both), nrow = 2) +
  xlab("") +
  ylab("") +
  theme_bw() +
  guides(colour = guide_legend(nrow = 1)) +
  theme(panel.grid.minor = element_blank(), 
        legend.position = "bottom",
        legend.key.width=unit(1, "cm"),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.line.y = element_line(color="black", linewidth=.5),
        axis.line.x = element_line(color="black", linewidth=.5)
  )

df_graph
