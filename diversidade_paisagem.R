# Pacotes ----

library(geobr)

library(tidyverse)

library(terra)

library(tidyterra)

library(ggview)

library(gganimate)

library(landscapemetrics)

# Shapefile de Amaraji----

## Importar ----

amaraji <- geobr::read_municipality(year = 2025) |>
  dplyr::filter(name_muni == "Amaraji")

## Visualizar ----

amaraji

ggplot() +
  geom_sf(data = amaraji, color = "black")
