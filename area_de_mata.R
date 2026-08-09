# PAcotew ----

library(geobr)

library(tidyverse)

library(terra)

library(crayon)

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

## Visualizar mapas ----

purrr::imap(uso_trat_mata,
            purrr::in_parallel(

              ~ggplot()+
                tidyterra::geom_spatraster(data = .x) +
                scale_fill_manual(values = "forestgreen",
                                  na.translate = FALSE) +
                geom_sf(data = amaraji, color = "black", fill = "transparent") +
                labs(title = .y)

              ),
            .progress = TRUE)

## Criar e exportar os mapas ----

purrr::imap(uso_trat_mata,
            purrr::in_parallel(

              ~ggplot()+
                tidyterra::geom_spatraster(data = .x) +
                scale_fill_manual(values = "forestgreen",
                                  na.translate = FALSE) +
                geom_sf(data = amaraji, color = "black",
                        fill = "transparent") +
                guides(fill = guide_legend(title.position = "top",
                                           title.hjust = 0.5)) +
                labs(title = paste0("Área de mata para ", .y),
                     subtitle = "Fonte: MapBiomas",
                     fill = "Mata") +
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
            filename = paste0("./mapas_area_mata/mapa_",
                              .y,
                              ".png"),
            height = 10,
            width = 12)

  ),
  .progres = TRUE)

# Gif dos mapas ----

## Importar imagens ----

imagens_mata <- list.files(path = "./mapas_area_mata/",
                           pattern = "^mapa_.*.png$",
                           full.names = TRUE) |>
  magick::image_read()

imagens_mata

## Criar gif ----

gif_mata <- imagens_mata |> magick::image_animate(fps = 1)

gif_mata

## Exportar gif ----

gif_mata |>
  magick::image_scale("1280x1066!") |>
  magick::image_write("./gif_amaraji_area_mata.gif")

## Exportar como vídeo ----

gif_mata |>
  magick::image_scale("1280x1066!") |>
  magick::image_write_video(
    path = "./gif_amaraji_area_mata.mp4",
    framerate = 1)

# Área de mata ----

## Calcular área da mata ----

area_mata <- purrr::imap_dfr(
  uso_trat_mata,
  purrr::in_parallel(

    ~tibble::tibble(Área = .x |>
                      terra::expanse() |>
                      as.numeric() %>%
                      .[2] / 1e6,
                    Ano = .y |> as.numeric())

    ),
  .progress = TRUE)

area_mata
