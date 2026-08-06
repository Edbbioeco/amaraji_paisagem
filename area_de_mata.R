# PAcotew ----

library(geobr)

library(tidyverse)

library(terra)

library(tidyterra)

library(ggview)

library(magick)

# Município de Amaraji ----

## Importar ----

## Importar ----

amaraji <- geobr::read_municipality(
  year = 2022,
  code_muni = geobr::lookup_muni(name_muni = "Amaraji",
                                 year = 2022) %>%
    .$code_muni)
