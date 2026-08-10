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

## Pesquisar católogo ----

catalogo <- CDSE::SearchCatalog(
  client = cliente,
  aoi = amaraji,
  from = "2000-01-01",
  to = "2024-12-31",
  collection = "sentinel-3-slstr-l2",
  filter = "eo:cloud_cover < 1"
  )

catalogo

## Selecionar um registro por mês e ano ----

datas <- catalogo |>
  dplyr::mutate(Ano = acquisitionDate |> lubridate::year(),
                Mes = acquisitionDate |> lubridate::month()) |>
  dplyr::group_by(Ano, Mes) |>
  dplyr::arrange(tileCloudCover) |>
  dplyr::select(acquisitionDate, tileCloudCover, Ano, Mes) |>
  dplyr::slice_head(n = 1) |>
  dplyr::pull(acquisitionDate)

datas

## Evalscript ----

evalscript <- '
//VERSION=3
function setup() {
  return {
    input: ["LST", "dataMask"],
    output: { bands: 2, sampleType: "FLOAT32" }
  }
}
function evaluatePixel(sample) {
  return [sample.LST, sample.dataMask]
}
'
evalscript

## Baixar imagens ----

dir.create("./temp")

purrr::map(datas,
           purrr::in_parallel(

             ~CDSE::GetImage(bbox = amaraji |> sf::st_bbox(),
                             script = evalscript,
                             time_range = .x,
                             file = paste0("./temp/temp_",
                                           .x[[1]],
                                           ".tif"),
                             collection = "sentinel-3-slstr-l2",
                             format = "image/tiff",
                             mosaicking_order = "leastRecent",
                             resolution = 10,
                             mask = TRUE,
                             buffer = 100,
                             client = cliente)

           ),
           .progress = TRUE)

## Importar rasters ----

raster_temp <- purrr::map(list.files(path = "./temp",
                                     full.names = TRUE),
                          purrr::in_parallel(

                            ~terra::rast(.x)

                          ),
                          .progress = TRUE) |>
  setNames(list.files(path = "./temp") |>
             stringr::str_remove(".tif$"))

raster_temp

## Converter para °C ----

raster_temp %<>%
  purrr::map(purrr::in_parallel(

    ~.x[[1]] - 273.15

    ),
    .progress = TRUE)

raster_temp
