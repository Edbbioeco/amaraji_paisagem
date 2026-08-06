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

## Visualizar ----

amaraji

ggplot() +
  geom_sf(data = amaraji, color = "black")

# Raster de uso e cobertura do solo ----

## Baixar ----

uso_solo <- purrr::map(
  1985:2025,
  purrr::in_parallel(
    \(periodo) {

      tryCatch({

        terra::rast(paste0(
          "https://storage.googleapis.com/mapbiomas-public/initiatives/brasil/collection_10/lulc/coverage/brazil_coverage_",
          periodo,
          ".tif"
        )) |>
          terra::crop(amaraji) |>
          terra::mask(amaraji)

      }, error = \(e) {

        message("Erro no ano ", periodo, ": ", e$message)
        NULL

      }

      )

    }

  ), .progress = TRUE) |>
  setNames(1985:2025 |> as.character())

uso_solo
