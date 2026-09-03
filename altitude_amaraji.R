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

# Altitude ----

## Baixar dados ----

alt <- amaraji |>
  elevatr::get_aws_terrain(z = 14,
                           prj = amaraji |> sf::st_crs(),
                           clip = "locations") |>
  terra::mask(amaraji) |>
  terra::crop(amaraji)

## Visualizar ----

alt

ggplot() +
  tidyterra::geom_spatraster(data = alt) +
  scale_fill_viridis_c(na.value = "transparent")
