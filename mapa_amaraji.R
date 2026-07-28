# Pacotes ----

library(geobr)

library(tidyverse)

library(maptiles)

library(tidyterra)

library(cowplot)

library(ggview)

# Dados ----

## Shapefile do Brasil ----

### Importar ----

br <- geobr::read_state(year = 2025)

### Visualizar ----

br

ggplot() +
  geom_sf(data = br,  color = "black")

## Shapefile de Pernambuco ----

### Filtrar ----

pe <- br |>
  dplyr::filter(abbrev_state == "PE")

pe

ggplot() +
  geom_sf(data = br,  color = "black") +
  geom_sf(data = pe,  color = "black", fill = "goldenrod")

## Shapefile de Amaraji ----

### Importar ----

amaraji <- geobr::read_municipality(year = 2025) |>
  dplyr::filter(name_muni == "Amaraji")

### Visualizar ----

amaraji

ggplot() +
  geom_sf(data = br,  color = "black") +
  geom_sf(data = pe,  color = "black", fill = "goldenrod") +
  geom_sf(data = amaraji,  color = "red", fill = "transparent") +
  coord_sf(xlim = c(-36, -34.8),
           ylim = c(-9, -8))
