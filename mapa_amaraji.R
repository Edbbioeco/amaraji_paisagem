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
