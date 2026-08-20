# Pacotes ----

library(geobr)

library(tidyverse)

library(CDSE)

library(terra)

library(tidyterra)

library(ggview)

library(magic)

library(gganimate)

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

# Raster de imagem RGB de satélite de Amaraji ----

## Iniciar sessão do cliente ----

cliente <- CDSE::GetOAuthClient(id = Sys.getenv("CDSE_ID"),
                                secret = Sys.getenv("CDSE_SECRET"))

## Coleções ----

CDSE::GetCollections()

### Carregar catálogo ----

catalogo <- CDSE::SearchCatalog(aoi = amaraji,
                                from = "1985-01-01",
                                to = "2026-07-01",
                                collection = "landsat-ot-l1",
                                with_geometry = FALSE,
                                client = cliente,
                                filter = "eo:cloud_cover < 50")

catalogo

## Datas ----

datas <- catalogo |>
  dplyr::mutate(data_mes = acquisitionDate |>
                  lubridate::floor_date("month")) |>
  dplyr::distinct(data_mes) |>
  dplyr::arrange(data_mes) |>
  dplyr::mutate(data_final = data_mes |>
                  lubridate::ceiling_date("month") - lubridate::day(1),
                periodo = purrr::map2(data_mes,
                                      data_final,
                                      ~paste0(.x,
                                              " - ",
                                              .y))) |>
  dplyr::pull(periodo)

datas
