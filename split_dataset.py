# %% [markdown]
# ## Importaciones

# %%
# Python imports
# ----------------------------------------

# Data structure
import pandas as pd
import numpy as np
from sklearn.model_selection import StratifiedShuffleSplit
import sys

## Hacer reproducibles los experimentos 
SEED=42
np.random.seed(SEED)

# %% [markdown]
# ## Lectura del dataset

# %%
file_source = sys.argv[1]
file_dest_trainval = sys.argv[2]
file_dest_test = sys.argv[3]
feature4stratify = sys.argv[4]

# %%
dataset = pd.read_csv(file_source, sep=',', header=0)
dataset

# %%
sss = StratifiedShuffleSplit(n_splits=1, test_size=0.15, random_state=SEED)
trainval_idx, test_idx = next(sss.split(dataset, dataset[feature4stratify]))
trainval_data = dataset.iloc[trainval_idx]
test_data = dataset.iloc[test_idx]

# %%
trainval_data.to_csv(file_dest_trainval)
test_data.to_csv(file_dest_test)

print("Division completada trainval_size=", trainval_data.shape[0], "test_size=", test_data.shape[0])


