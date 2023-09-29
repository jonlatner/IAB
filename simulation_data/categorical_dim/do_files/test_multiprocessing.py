import os
import pandas as pd
import multiprocess as mp

from sdv.metadata import SingleTableMetadata
from sdv.single_table import CTGANSynthesizer

main_dir = "/Users/jonathanlatner/Google Drive/My Drive/IAB/drechsler_latner_2023/simulation_data/categorical_dim/"
original_data = "data_files/original/"
synthetic_data = "data_files/synthetic/ctgan/"

os.chdir(main_dir)


# Define a function to synthesize data
def synthesize_data(j):

    j = j + 1

    ods_filename = "ods_rows_1000_cols_10.csv"
    df_ods = pd.read_csv(os.path.join(original_data, ods_filename), index_col=False)
        
    metadata = SingleTableMetadata()
    metadata.detect_from_dataframe(data=df_ods)
    synthesizer = CTGANSynthesizer(metadata, epochs=30)
    synthesizer.fit(df_ods)
    # sds = synthesizer.sample(num_rows=len(df_ods.index))

    sds = df_ods
    sds_filename = f"sds_ctgan_rows_1000_cols_10_n_{j}.csv"
    
    sds.to_csv(os.path.join(synthetic_data, sds_filename), index=False)
    
if __name__ == '__main__':
    
    num_processes = 2  # Adjust the number of processes as needed
    
    with mp.Pool(num_processes) as pool:

        pool.map(synthesize_data, range(2))

    print("All datasets have been created and saved.")
    