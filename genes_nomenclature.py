
# Autora: Maria Lourdes Linares Barrera

# Class for translating from affymetrix nomenclature to official gene symbol using DAVID BIOINFORMATICS DATABASE
# Reference: https://david.ncifcrf.gov/conversion2.jsp?status=convertRecord&convertFrom=AFFYMETRIX_3PRIME_IVT_ID&userId=1553354_a_at
# (some conversions not available)
# We load con David database the file genes_probes.txt and we obtain the conversions to genes_symbol and download the
# conversion table as genes_nomenclature.txt
# Now we create a class to help us in the process for summarizing the probes (for feature selection)

# Importaciones
import numpy as np
import pandas as pd

class GeneNomenclatureConversion:
    
    def __init__(self, table_file):
        df_nomenclature_raw = pd.read_csv(table_file, sep="\t").iloc[:, 0:2]
        self.df_nomenclature = pd.Series(df_nomenclature_raw['To'].values, 
                                    index=df_nomenclature_raw['From'].values,
                                    name = 'Gene conversion table')
        self.df_nomenclature = self.df_nomenclature.dropna()
    
    def get_table(self):
        return self.df_nomenclature
    
    def convert_affymatrix_to_gene(self, gene):
        return self.df_nomenclature[gene]

    def get_probes(self):
        return self.df_nomenclature.index.values
    
    def get_genes(self):
        return np.unique(self.df_nomenclature.values)

    def get_table_probes_per_gene(self):
        genes = self.get_genes()
        lprobes_per_gene = [ self.df_nomenclature[self.df_nomenclature==gen].index.values for gen in genes ]
        return pd.Series(lprobes_per_gene, index=genes, name='Table probes per gene')
    
    def get_table_number_probes_per_gene(self):
        genes = self.get_genes()
        lprobes_per_gene = [ self.df_nomenclature[self.df_nomenclature==gen].index.values.shape[0] for gen in genes ]
        return pd.Series(lprobes_per_gene, index=genes, name='Table probes per gene')




# Ejemplo de uso (Test)

def test():
    conversor = GeneNomenclatureConversion('genes_nomenclature_table.txt')
    print(conversor.convert_affymatrix_to_gene('1557848_at'))
    print(conversor.convert_affymatrix_to_gene('216232_s_at'))
    print(conversor.convert_affymatrix_to_gene('209541_at'))
    print('-----------------')
    tabla = conversor.get_table()
    print(tabla)
    print('-----------------')
    # Lets see that some genes appears in more than one probe
    print("Number of genes:", len(conversor.get_genes()))
    print("Number of probes:", len(conversor.get_probes()))
    count_genes = np.unique(tabla.values, return_counts=True)
    tabla_frecuencia = pd.Series(count_genes[1], index=count_genes[0], name='Frequency_table')
    print(tabla_frecuencia)
    print('-----------------')
    print(conversor.get_table_probes_per_gene())


# test()

# conversor = GeneNomenclatureConversion('table_nomenclature.txt')
# print(conversor.convert_affymatrix_to_gene('1007_s_at'))
# print(conversor.get_table())
# print(conversor.get_table_probes_per_gene())

