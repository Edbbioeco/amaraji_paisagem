# Pacotes ----

library(geobr)

library(tidyverse)

library(CDSE)

library(terra)

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

## Raster de imagem RGB de satélite de Amaraji ----

### Iniciar sessão do cliente ----

cliente <- CDSE::GetOAuthClient(id = Sys.getenv("CDSE_ID"),
                                secret = Sys.getenv("CDSE_SECRET"))

### Carregar catálogo ----

catalogo <- CDSE::SearchCatalog(aoi = amaraji,
                                from = "2020-01-01",
                                to = "2026-07-01",
                                collection = "sentinel-3-synergy-l2",
                                with_geometry = FALSE,
                                client = cliente,
                                filter = "eo:cloud_cover < 1")

catalogo

### Evalscript ----

evalscript <- system.file("scripts",
                          "TrueColor.js",
                          package = "CDSE")

evalscript

### Selecionar periodo ----

periodo <- catalogo |>
  dplyr::filter(tileCloudCover == 0) |>
  dplyr::arrange(acquisitionDate |> dplyr::desc(),
                 tileCloudCover) |>
  dplyr::slice(1) |>
  dplyr::pull(acquisitionDate)

periodo

### Baixar raster ----

dir.create("./rasters_rgb")

CDSE::GetImage(bbox = amaraji |> sf::st_bbox(),
               time_range = periodo,
               script = evalscript,
               file = "./rasters_rgb/raster_rgb_modelo.tif",
               collection = "sentinel-3-synergy-l2",
               format = "image/tiff",
               mosaicking_order = "leastRecent",
               resolution = 10,
               mask = TRUE,
               buffer = 100,
               client = cliente)
