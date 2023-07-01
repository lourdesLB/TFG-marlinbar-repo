# %% [markdown]
# ## Sumarizacion de sondas

# %% [markdown]
# Agrupamos la expresión de las sondas correspondientes a un mismo gen en un único valor

# %%
import pandas as pd
import numpy as np
from genes_nomenclature import GeneNomenclatureConversion
from numba import jit, cuda
import urllib
import json
import pickle
import sys
import os

# %%
# Obtener los parametros de entrada
file_source = os.path.join(os.getcwd(), sys.argv[1])
file_destination = os.path.join(os.getcwd(), sys.argv[2])
file_nomenclature = os.path.join(os.getcwd(), sys.argv[3])

# %%
ncbi_preprocess = pd.read_csv(file_source, 
                                  header=0, 
                                  sep=',', 
                                  quotechar='"')
ncbi_preprocess.head()

# %%
conversor = GeneNomenclatureConversion(file_nomenclature)
table_gene_probes = conversor.get_table_probes_per_gene()
table_gene_probes

# %%
@jit(target_backend='cuda')                         
def sumarizacion():
    ncbi_objective  = pd.DataFrame()
    cont=0
    for gen in table_gene_probes.index.values:
        cont = cont+1
        print(cont, gen)
        probes_gen = table_gene_probes[gen].tolist()
        ncbi_objective = pd.concat( [
            ncbi_objective, 
            pd.DataFrame(ncbi_preprocess[probes_gen].mean(axis=1), columns=[gen]) 
            ], axis=1 )
    return ncbi_objective

ncbi_objective = sumarizacion()
ncbi_objective

# %%
ncbi_objective.to_csv(file_destination, index=False)




