
# -------------------------- Carga de datos -----------------------------------
# Cargamos los datos descargados del Kent Ridge Biomedical Data Sets Repository
# referentes al tumor de prostata


# Primero debemos de descargar y descomprimir en nuestro directorio de trabajo
# el fichero D4_ProstateTN.zip que encontraremos en el enlace:
# https://webdocs.cs.ualberta.ca/~rgreiner/RESEARCH/OLD-BiCluster/Diagnosis.html

dir.create("P0_ficheros_extraccion_prostateCancer")
dir.create("P1_ficheros_preprocesamiento_prostateCancer")
dir.create("P2_ficheros_comparativaSupervisado_prostateCancer")
dir.create("P3_ficheros_aprendizajeNoSupervisado_prostateCancer")

# Lectura de la matriz de datos de sondas genicas (fichero .dat)

datos_raw <- read.table("D4_ProstateTN.dat", sep="\t", header = F)
datos <- as.data.frame(t(datos_raw))
datos <- datos[-c(dim(datos)[1]),]



# Leer nombres de sondas (fichero .row)
sondas_raw <- read.table("D4_ProstateTN.row", sep="\t", header = F)[,c("V1")]

rownames(datos) <- NULL
colnames(datos) <- sondas_raw



# Leer valores de diagnostico o clasificacion (fichero .col)
# Aplicaremos parseo y codificacion binaria:
#     Tumor   = 1
#     Normal  = 0

group_raw <- read.table("D4_ProstateTN.col", sep="\t", header = F)

parse_group <- function(cadena) {
  if (!is.na(cadena) && grepl("\\d+Tumor", cadena)) {
    return(1)
  }
  else if (!is.na(cadena) && grepl("\\d+Normal", cadena)) {
    return(0)
  }
  else {
    return(NA)
  }
}

group <- apply(group_raw, MARGIN=c(1,2), FUN=parse_group)
group <- as.data.frame(group)[,c("V1")]



# Almacenar en un dataset los datos (ensamblando las partes anteriores)

datos <- cbind(group, datos)
datos <- datos %>% 
  dplyr::select(group, everything())




# Mostrar los resultados

print(paste("Numero de sondas:", dim(datos)[2] - 1))
print(paste("Numero de pacientes:", dim(datos)[1]))

group_muestra <- as.numeric(table(datos$group))

sprintf("Distribucion de la muestra de pacientes: Tumor(%i) | Normal(%i)", 
        group_muestra[1], 
        group_muestra[2])

cat("\nPrevisualizacion de las primeras filas y columnas (4x4) del conjunto de datos \n")
print(head(datos[,1:4], n=4), digits = 2, right = TRUE, numb = 4)



# Almacenar los datos en un fichero

write_csv(datos, 'P0_ficheros_extraccion_prostateCancer/prostateCancer_0_alldata.csv')
write_csv(datos, 'P0_ficheros_extraccion_prostateCancer/prostateCancer_1_notnulldata.csv')
