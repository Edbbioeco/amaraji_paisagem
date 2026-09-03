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

## Mapa ----

ggplot() +
  tidyterra::geom_spatraster(data = alt) +
  tidyterra::scale_fill_hypso_c(
    palette = "colombia_hypso",
    na.value = "transparent",
    direction = -1,
    guide = guide_colourbar(title = "Atitude (m)",
                            title.position = "top",
                            title.hjust = 0.5,
                            barheight = 2,
                            barwidth = 30,
                            frame.colour = "black",
                            ticks.colour = "black")) +
  theme_bw() +
  theme(axis.text = element_text(color = "black", size = 20),
        legend.text = element_text(color = "black", size = 20),
        legend.title = element_text(color = "black", size = 20),
        legend.position = "bottom",
        panel.border = element_rect(color = "black", linewidth = 1)) +
  ggview::canvas(height = 10, width = 12)

ggsave(filename = "./amaraji_altitude.png",
       height = 10, width = 12)
