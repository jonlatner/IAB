'''
TOP COMMANDS
'''

# load libraries
## Basics 
import os
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# file paths - adapt main_dir pathway
main_dir = "/Users/jonathanlatner/Documents/GitHub/IAB/simulation_data/continuous_dim/"

data_files = "data_files/"
original_data = "data_files/original/"
synthetic_data = "data_files/synthetic/ctgan/"
graphs = "graphs/ctgan/"

os.chdir(main_dir)

# beginning commands
pd.set_option('display.width', 1000)
pd.set_option('display.float_format', '{:.2f}'.format)
pd.set_option('display.max_columns', None)

os.chdir(main_dir)

'''
Load original data
'''

# Dimensions
rows = [5000] # Rows/observations
cols = [10] # Columns/variables

for r in rows:
    for c in cols:
        
        # load data
        filename_ods = f"ods_rows_{r}_cols_{c}.csv"
        df_ods = pd.read_csv(os.path.join(original_data, filename_ods), index_col=False)

df_ods.describe()

'''
Graph original data
'''

fig, axes = plt.subplots(1, 2, figsize=(12, 4))

# Filter only continuous variables (numeric columns)
continuous_vars = df_ods.select_dtypes(include=['float64', 'int64'])

# Melt the DataFrame to create a long-form data structure
df_long_ods = continuous_vars.melt(var_name='Variable', value_name='Value')

# Create histograms using Seaborn facet grid
g1 = sns.FacetGrid(df_long_ods, col='Variable', col_wrap=5, sharex=True, sharey=True)
g1.map(plt.hist, 'Value', bins=20, edgecolor='k')

# Set labels for the facets
g1.set_axis_labels('Value', 'Frequency')

# Adjust spacing between subplots
plt.tight_layout()

# Show the plot
plt.show()

'''
Load synthetic data (by epochs)
'''

df_sds = pd.DataFrame()

epochs = [10, 20, 30]
for e in epochs:
       
    # load data
    filename_sds = f"sds_ctgan_rows_{r}_cols_{c}_n_1_epochs_{e}.csv"
    sds = pd.read_csv(os.path.join(synthetic_data, filename_sds), index_col=False)
    sds["epochs"] = e

    # append data
    df_sds = pd.concat([df_sds, sds], ignore_index=True)
    
continuous_vars = df_sds.select_dtypes(include=['float64', 'int64'])
continuous_vars["epochs"] = df_sds["epochs"]
df_long_sds = continuous_vars.melt(id_vars=['epochs'], var_name=['Variable'], value_name='Value')

# Create a custom color palette for your legend
legend_colors = sns.color_palette('husl', n_colors=len(df_long_sds['epochs'].unique()))

# Create histograms using Seaborn facet grid with the same color palette
g2 = sns.FacetGrid(df_long_sds, col='Variable', col_wrap=5, sharex=True, sharey=True, hue="epochs", palette=legend_colors)

# Overlay KDE plots on top of histograms
g2.map(sns.histplot, 'Value', bins=20, edgecolor='k', fill=False, alpha=0, kde=True)

# Add legend for the 'epochs' variable with the same color palette
g2.add_legend(title='epochs', labels=df_long_sds['epochs'].unique())

g2.set_axis_labels('Value', 'Frequency')

# Show the plot
plt.show()



'''
Graph
'''
# Append original + synthetic data
df_long_ods["epochs"] = "Original"
df_long = pd.concat([df_long_ods, df_long_sds], ignore_index=True)


# Create a custom color palette for your legend
legend_colors = sns.color_palette('husl', n_colors=len(df_long['epochs'].unique()))

g = sns.FacetGrid(df_long, col='Variable', col_wrap=5, sharex=True, sharey=True, hue="epochs", palette=legend_colors)

g.map(sns.histplot, 'Value', bins=20, edgecolor='k', fill=False, alpha=0, kde=True)

g.set_axis_labels('Value', 'Frequency')

legend = g.fig.legend(title='epochs', labels=df_long['epochs'].unique(), loc='lower center', ncol=5)

# Adjust legend position and appearance
plt.subplots_adjust(bottom=0.2)  # Increase the bottom margin
legend.set_bbox_to_anchor([0.5, -0])  # Adjust the second value to control the vertical position

# Show the plot
plt.show()

# Save
g.savefig(os.path.join(graphs,"graph_ctgan_tuning_epochs.pdf"), format="pdf")

