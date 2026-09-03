# Pacotes ----

library(geobr)

library(tidyverse)

library(elevatr)

library(terra)

library(tidyterra)

library(ggview)

# Shapefile de Amaraji ----

## Importar ----

amaraji <- geobr::read_municipality(year = 2025,
                                    code_muni = 2600906)

## Visualizar ----

amaraji

ggplot() +
  geom_sf(data = amaraji, color = "black")
