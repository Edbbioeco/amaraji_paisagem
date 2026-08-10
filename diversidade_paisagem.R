# Pacotes ----

library(geobr)

library(tidyverse)

library(terra)

library(tidyterra)

library(ggview)

library(magick)

library(landscapemetrics)

# Shapefile de Amaraji----

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

      tryCatch({

        terra::rast(paste0(
          "https://storage.googleapis.com/mapbiomas-public/initiatives/brasil/collection_10/lulc/coverage/brazil_coverage_",
          periodo,
          ".tif")) |>
          terra::crop(amaraji) |>
          terra::mask(amaraji)

        },
        error = \(e) {

          message("Erro no ano ", periodo, ": ", e$message) |>
            crayon::red()
          NULL

        })

    }

  ),
  .progress = TRUE) |>
  setNames(1985:2025 |> as.character())

uso_solo

## Remover os NULL ----

uso_solo_trat <- uso_solo |>
  purrr::compact() |>
  purrr::map(purrr::in_parallel(

    ~.x |> terra::as.factor()

  ),
  .progress = TRUE)


uso_solo_trat

## Visualizar ----

purrr::imap(uso_solo_trat,
            purrr::in_parallel(

              ~ggplot() +
                tidyterra::geom_spatraster(data = .x) +
                scale_fill_viridis_d(option = "turbo",
                                     na.translate = FALSE) +
                labs(title = .y)

              ),
            .progress = TRUE)

## Exportar mapas ----

purrr::imap(uso_solo_trat,
            purrr::in_parallel(

              ~ggplot() +
                tidyterra::geom_spatraster(data = .x) +
                scale_fill_manual(values = c("3" = "darkgreen",
                                             "4" = "forestgreen",
                                             "11" = "mediumseagreen",
                                             "15" = "goldenrod",
                                             "20" = "darkolivegreen3",
                                             "21" = "darkolivegreen1",
                                             "24" = "orangered4",
                                             "33" = "blue"),
                                  breaks = c("3",
                                             "4",
                                             "11",
                                             "15",
                                             "20",
                                             "21",
                                             "24",
                                             "33"),
                                  labels = c("Floresta",
                                             "Savana",
                                             "Campo alagado",
                                             "Pastagem",
                                             "Cana-de-açúcar",
                                             "Mosaico de usos",
                                             "Área urbana",
                                             "Corpo hídrico"),
                                  na.translate = FALSE) +
                guides(fill = guide_legend(title.position = "top",
                                            title.hjust = 0.5)) +
                labs(title = .y) +
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
                scale_fill_manual(values = c("3" = "darkgreen",
                                             "4" = "forestgreen",
                                             "11" = "mediumseagreen",
                                             "15" = "goldenrod",
                                             "20" = "darkolivegreen3",
                                             "21" = "darkolivegreen1",
                                             "24" = "orangered4",
                                             "33" = "blue"),
                                  breaks = c("3",
                                             "4",
                                             "11",
                                             "15",
                                             "20",
                                             "21",
                                             "24",
                                             "33"),
                                  labels = c("Floresta",
                                             "Savana",
                                             "Campo alagado",
                                             "Pastagem",
                                             "Cana-de-açúcar",
                                             "Mosaico de usos",
                                             "Área urbana",
                                             "Corpo hídrico"),
                                  na.translate = FALSE) +
                guides(fill = guide_legend(title.position = "top",
                                           title.hjust = 0.5)) +
                labs(title = .y) +
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

# Gif dos mapas ----

## Importar os mapas ----

imagem_mapas <- list.files(path = "./mapas_uso_cobertura_solo",
                            pattern = ".png$",
                            full.names = TRUE) |>
  magick::image_read()

imagem_mapas

## Criar gif ----

gif_amaraji_uso <- imagem_mapas |> magick::image_animate(fps = 1)

gif_amaraji_uso

## Exportar gif ----

gif_amaraji_uso |>
  magick::image_scale("1280x1066!") |>
  magick::image_write("./gif_amaraji_uso_cobertura_solo.gif")

## Exportar como vídeo ----

gif_amaraji_uso |>
  magick::image_scale("1280x1066!") |>
  magick::image_write_video(
    path = "./gif_amaraji_uso_cobertura_solo.mp4",
    framerate = 1)

# Diversidade da paisagem ----

## Calcular a diversidade ----

div_paisagem <- purrr::imap_dfr(
  uso_solo_trat,
  purrr::in_parallel(

    ~tibble::tibble(Ano = .y,
                    `Diversidade (D de Gini-Simpson)` = .x |>
                      landscapemetrics::lsm_l_sidi() %>%
                      .$value)

    ),
  .progress = TRUE) |>
  dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
                              .fns = ~. |> as.numeric()))

div_paisagem

## Visualizar a série temporal ----

div_paisagem |>
  ggplot(aes(Ano, `Diversidade (D de Gini-Simpson)`)) +
  geom_line(linewidth = 1) +
  theme_bw() +
  theme(axis.text = element_text(size = 20, color = "black"),
        axis.title = element_text(size = 20, color = "black"),
        legend.text = element_text(size = 20, color = "black"),
        legend.title = element_text(size = 20, color = "black"),
        legend.position = "bottom",
        panel.background = element_rect(linewidth = 1,
                                        color = "black")) +
  ggview::canvas(height = 10, width = 12)

ggsave(filename = "./diversidade_paisagem.png",
       height = 10, width = 12)

# Área das classes ----

## Criar o data frame das áreas das classes ----

df_area_classes <- purrr::imap_dfr(
  uso_solo_trat,
  purrr::in_parallel(

    ~.x |>
      terra::expanse(unit = "km",
                     byValue = TRUE) |>
      dplyr::select(2:3) |>
      dplyr::rename("Classe" = 1,
                    "Área (km²)" = 2) |>
      dplyr::mutate(Ano = .y |> as.numeric())

    ),
  .progress = TRUE)

df_area_classes
