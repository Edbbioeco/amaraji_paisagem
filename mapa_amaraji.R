# Pacotes ----

library(geobr)

library(tidyverse)

library(CDSE)

library(terra)

library(tidyterra)

library(ggspatial)

library(ggview)

library(cowplot)

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
                                from = "2000-01-01",
                                to = "2026-07-01",
                                collection = "sentinel-2-l2a",
                                with_geometry = FALSE,
                                client = cliente,
                                filter = "eo:cloud_cover < 5")

catalogo

### Evalscript ----

evalscript <- system.file("scripts",
                          "TrueColorS2L2A.js",
                          package = "CDSE")

evalscript

### Selecionar periodo ----

periodo <- catalogo |>
  dplyr::filter(tileCloudCover < 5) |>
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
               collection = "sentinel-2-l2a",
               format = "image/tiff",
               mosaicking_order = "leastRecent",
               resolution = 10,
               mask = TRUE,
               buffer = 100,
               client = cliente)

### Importar raster ----

amaraji_tif <- terra::rast("./rasters_rgb/raster_rgb_modelo.tif")

### Visualizar ----

amaraji_tif

ggplot() +
  tidyterra::geom_spatraster_rgb(data = amaraji_tif) +
  geom_sf(data = amaraji, color = "red", fill = "transparent") +
  coord_sf(expand = FALSE)

# Mapas ----

## Mapa principal ----

mapa_principal <- ggplot() +
  geom_sf(data = br,
          fill = "gray",
          aes(color = "Brasil"),
          linewidth = 1) +
  geom_sf(data = pe,  fill = "goldenrod",
          aes(color = "Pernambuco"),
          linewidth = 1) +
  tidyterra::geom_spatraster_rgb(data = amaraji_tif) +
  geom_sf(data = amaraji, fill = "transparent",
          aes(color = "Amaraji"),
          linewidth = 2) +
  scale_color_manual(values = c("Brasil" = "black",
                                "Pernambuco" = "black",
                                "Amaraji" = "darkred"),
                     breaks = c("Brasil", "Pernambuco", "Amaraji")) +
  coord_sf(expand = FALSE,
           label_graticule = "NSWE",
           xlim = c(-35.56442, -35.37131),
           ylim = c(-8.458444, -8.25894)) +
  labs(color = NULL) +
  ggspatial::annotation_scale(text_cex = 2,
                              text_col = "white",
                              location = "br") +
  theme_bw() +
  theme(axis.text = element_text(color = "black", size = 20),
        legend.text = element_text(color = "black", size = 20),
        legend.title = element_text(color = "black", size = 20),
        legend.position = "bottom") +
  ggview::canvas(height = 10, width = 12)

mapa_principal

## Mapa br ----

mapa_br <- ggplot() +
  geom_sf(data = br,
          fill = "gray",
          color = "black",
          linewidth = 0.75) +
  geom_sf(data = pe,
          fill = "goldenrod",
          color = "black",
          linewidth = 0.75) +
  theme_void() +
  ggview::canvas(height = 10, width = 12)

mapa_br

## Mapa pe ----

mapa_pe <- ggplot() +
  geom_sf(data = br,
          fill = "gray",
          color = "black",
          linewidth = 0.75) +
  geom_sf(data = pe,
          color = "black",
          fill = "goldenrod",
          linewidth = 0.75) +
  geom_sf(data = amaraji,  color = "darkred", fill = "transparent",
          linewidth = 0.75) +
  coord_sf(xlim = c(-36, -34.8),
           ylim = c(-9, -8),
           expand = FALSE) +
  theme_void() +
  theme(axis.text = element_blank(),
        legend.position = "none",
        panel.background = element_rect(color = "black",
                                        fill = "transparent",
                                        linewidth = 2),
        panel.ontop = TRUE) +
  ggview::canvas(height = 10, width = 12)

mapa_pe

## Mapa final ----

cowplot::ggdraw(mapa_principal) +
  cowplot::draw_plot(mapa_br,
                     height = 0.275,
                     width = 0.275,
                     x = 0.125,
                     y = 0.1) +
  cowplot::draw_plot(mapa_pe,
                     height = 0.2,
                     width = 0.2,
                     x = 0.635,
                     y = 0.75) +
  ggview::canvas(height = 10, width = 12)

ggsave(filename = "mapa_amaraji.png",
       height = 10, width = 12)
