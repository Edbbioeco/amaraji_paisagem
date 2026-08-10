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
