# PAcotew ----

library(geobr)

library(tidyverse)

library(terra)

library(tidyterra)

library(ggview)

library(magick)

# Município de Amaraji ----

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

    \(periodo){

      raster_uso_mapbiomas <- purrr::safely(
        \(periodo){

          terra::rast(paste0(
            "https://storage.googleapis.com/mapbiomas-public/initiatives/brasil/collection_10/lulc/coverage/brazil_coverage_",
            periodo,
            ".tif")) |>
            terra::crop(amaraji) |>
            terra::mask(amaraji)

        })

      raster_uso_mapbiomas(periodo)

      }

    ),
  .progress = TRUE)

uso_solo

## Remover os NULL ----

uso_solo_trat <- uso_solo |>
  purrr::compact() |>
  purrr::map(purrr::in_parallel(

    ~.x |> terra::as.factor()

  ),
  .progress = TRUE)


uso_solo_trat

## Filtrar a área de mata ----

### Códigos para área de mata ----

codigos <- c(1:6, 10:12, 29, 32, 49:50) |> as.character()

codigos

## Filtrar para as áreas de mata ----

uso_trat_mata <- purrr::imap(
  uso_solo_trat,
  ~.x |>
    tidyterra::mutate(
      !!{{paste0("brazil_coverage_", .y)}} := dplyr::case_when(

        .data[[paste0("brazil_coverage_", .y)]] %in%
          (codigos |> as.numeric()) ~ "Mata",
        .default = .data[[paste0("brazil_coverage_", .y)]] |> as.character()

      )
    ) |>
    tidyterra::filter(.data[[paste0("brazil_coverage_", .y)]] == "Mata"),
  .progress = TRUE)

uso_trat_mata

