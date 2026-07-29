# Pacotes ----

library(geobr)

library(tidyverse)

library(terra)

library(tidyterra)

library(ggview)

library(magick)

library(landscapemetrics)

library(gganimate)

# Shapefile de Amaraji----

## Importar ----

amaraji <- geobr::read_municipality(year = 2025) |>
  dplyr::filter(name_muni == "Amaraji")

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

## Remover os NULL ----

uso_solo_trat <- uso_solo |> purrr::compact()

uso_solo_trat

## Visualizar ----

purrr::imap(uso_solo_trat,
            purrr::in_parallel(

              ~ggplot() +
                tidyterra::geom_spatraster(data = .x) +
                scale_fill_viridis_c(option = "turbo",
                                     na.value = "transparent") +
                labs(title = .y)

              ),
            .progress = TRUE)

## Exportar mapas ----

purrr::imap(uso_solo_trat,
            purrr::in_parallel(

              ~ggplot() +
                tidyterra::geom_spatraster(data = .x) +
                scale_fill_viridis_c(option = "turbo",
                                     na.value = "transparent") +
                labs(title = .y) +
                scale_fill_viridis_c(option = "turbo",
                                     na.value = "transparent",
                                     guide = guide_colourbar(

                                       title.position = "top",
                                       title.hjust = 0.5,
                                       barwidth = 20,
                                       frame.colour = "black",
                                       ticks.colour = "black")

                ) +
                labs(title = paste0("Uso e cobertura do solo para ", .y),
                     subtitle = "Fonte: MapBiomas",
                     fill = "Classe de uso e cobertura do solo") +
                theme_bw() +
                theme(axis.text = element_text(size = 20, color = "black"),
                      legend.text = element_text(size = 20, color = "black"),
                      legend.title = element_text(size = 20, color = "black"),
                      legend.position = "bottom",
                      strip.text = element_text(size = 30, color = "black"),
                      strip.background = element_rect(color = "black",
                                                      linewidth = 1),
                      panel.background = element_rect(linewidth = 1,
                                                      color = "black"),
                      plot.title = element_text(size = 20, color = "black"),
                      plot.subtitle = element_text(size = 17.5, color = "black")) +
                ggview::canvas(height = 10, width = 12)

            ),
            .progress = TRUE)

purrr::imap(uso_solo_trat,
            purrr::in_parallel(

              ~ggplot() +
                tidyterra::geom_spatraster(data = .x) +
                scale_fill_viridis_c(option = "turbo",
                                     na.value = "transparent") +
                labs(title = .y) +
                scale_fill_viridis_c(option = "turbo",
                                     na.value = "transparent",
                                     guide = guide_colourbar(

                                       title.position = "top",
                                       title.hjust = 0.5,
                                       barwidth = 20,
                                       frame.colour = "black",
                                       ticks.colour = "black")

                ) +
                labs(title = paste0("Uso e cobertura do solo para ", .y),
                     subtitle = "Fonte: MapBiomas",
                     fill = "Classe de uso e cobertura do solo") +
                theme_bw() +
                theme(axis.text = element_text(size = 20, color = "black"),
                      legend.text = element_text(size = 20, color = "black"),
                      legend.title = element_text(size = 20, color = "black"),
                      legend.position = "bottom",
                      strip.text = element_text(size = 30, color = "black"),
                      strip.background = element_rect(color = "black",
                                                      linewidth = 1),
                      panel.background = element_rect(linewidth = 1,
                                                      color = "black"),
                      plot.title = element_text(size = 20, color = "black"),
                      plot.subtitle = element_text(size = 17.5, color = "black"))

            ),
            .progress = TRUE) |>
  purrr::imap(purrr::in_parallel(

    ~ggsave(.x,
            filename = paste0("./mapas_uso_cobertura_solo/mapa_",
                              .y,
                              ".png"),
            height = 10,
            width = 12)

    ),
    .progres = TRUE)

