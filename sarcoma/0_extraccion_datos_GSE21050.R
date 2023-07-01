# Importaciones

library(tidyverse)
library(dplyr)
library(GEOquery)

# Carga de datos
# Cargamos los datos y metadatos de la BD omica GSE21050 desde GEO, 
# extraemos los valores de expresion de las sondas y los valores fenotipicos de 
# metastasis y supervivencia y lo procesamos para eliminar nulos y transformarlo a dataframe.
# Documentacion: https://bioconductor.org/packages/release/bioc/manuals/GEOquery/man/GEOquery.pdf

dir.create("P0_ficheros_extraccion_GSE21050")
dir.create("P1_ficheros_preprocesamiento_GSE21050")
dir.create("P2_ficheros_comparativaSupervisado_GSE21050")
dir.create("P3_ficheros_aprendizajeNoSupervisado_GSE21050")

# -------------------------------------------------------------------------

# Expression Set completo con metadatos

ncbi_raw <- getGEO(
  GEO='GSE21050',
  GSEMatrix=TRUE,
  AnnotGPL=TRUE
)
ncbi_raw

ncbi_raw <- ncbi_raw[[1]]
ncbi_raw

save(ncbi_raw, file="P0_ficheros_extraccion_GSE21050/GSE21050_0_alldata.Rdata")



# Matriz de genes

gene_matrix <- t(exprs(ncbi_raw)) # Transposicion de la matriz experimental



# Leer valores de diagnostico o clasificacion
# Aplicaremos parseo y codificacion binaria:
#     Metastasis:yes   = 1
#     Metastasis:no    = 0

group_rawdata <- ncbi_raw$`metastasis:ch1`

parse_group <- function(cadena) {
  if (!is.na(cadena) && cadena == "yes") {
    return(1)
  }
  else if (!is.na(cadena) && cadena == "no") {
    return(0)
  }
  else {
    return(NA)
  }
}

group <- unlist(lapply(group_rawdata, parse_group))



# Leer valores de tiempo de supervivencia
# Aplicaremos parseo a float

time_survivor_rawdata <- ncbi_raw$`characteristics_ch1.4`

# Parseo de los datos
parse_time_survivivor <- function(cadena) {
  if (cadena!="") {
    return(as.double(gsub("[^0-9.]+", "", cadena)))
  }
  else {
    return(NA)
  }
}

time_survivor <- unlist(lapply(time_survivor_rawdata, parse_time_survivivor))

# -------------------------------------------------------------------------


# Almacenar en un dataset los datos (ensamblando las partes anteriores)

dataset0 <- as.data.frame(gene_matrix)
dataset0 <- cbind(group, time_survivor, dataset0)


# Reordenar columnas
dataset0 <- dataset0 %>% 
  dplyr::select(group, time_survivor, everything())


# Almacenar en csv
write_csv(dataset0, "P0_ficheros_extraccion_GSE21050/GSE21050_0_alldata.csv")

# -------------------------------------------------------------------------


# Eliminar nulls
not_null_index <- which(!is.na(group))

gene_matrix1 <- gene_matrix[not_null_index,]
group1 <- group[not_null_index]
time_survivor1 <- time_survivor[not_null_index]

# -------------------------------------------------------------------------

# Almacenar en un dataset los datos

dataset1 <- as.data.frame(gene_matrix1)
dataset1 <- cbind(group1, time_survivor1, dataset1)

# Reordenar columnas
dataset1 <- dataset1 %>% 
  dplyr::select(group1, time_survivor1, everything())

dataset1 <- dataset1 %>% 
  dplyr::rename(group = group1, time_survivor = time_survivor1)


# Mostrar los resultados en un fichero
cat("Numero de sondas:", dim(gene_matrix1)[2],"\n")
cat("Numero de pacientes/muestras:", dim(gene_matrix1)[1],"\n")

cat("\nPrevisualizacion de las 4 primeras filas y columnas de la matriz de sondas-pacientes\n")
print(head(dataset1[,1:4], n=4), digits = 2, right = TRUE, numb = 4)

cat("\nPrevisualizacion de los primeros datos binarios de clasificacion\n")
print(group1[1:10])

cat("\nPrevisualizacion de los primeros datos numericos de tiempo de supervivencia\n")
print(time_survivor1[1:10])


# Almacenar en csv
write_csv(dataset1, "P0_ficheros_extraccion_GSE21050/GSE21050_1_notnulldata.csv")


# Visualizamos como estan repartidos los valores de las clases

cat("Porcentaje de elementos de cada clase\n")
table(dataset1[,c("group")]) # Esta balanceado el dataset
