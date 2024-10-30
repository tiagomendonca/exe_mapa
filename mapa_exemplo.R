library(tidyverse)
library(geojsonio)
library(sf)
library(geobr)
library(highcharter)

(mapa <- geobr::read_region(showProgress = FALSE))

geojson_file <- geojson_list(mapa, geometry = "MultiPolygon")

dados <- mapa %>% 
  as_tibble() %>% 
  mutate(valor = sample(1:nrow(.)), 
         tooltip = paste0(name_region, "<br>Valor: ", valor)) |> 
  mutate(
    # cria offsets x e y, definidos por trial and error
    offset_x = c(0, 0, -50, 20, 0),
    offset_y = c(0, 0, 0, -20, 0),
    # cria uma lista com os parâmetros customizados
    dataLabels = purrr::map2(offset_x, offset_y, \(x, y) list(x = x, y = y))
  ) |> 
  select(-offset_x, -offset_y)

highchart(type = "map") %>%
  hc_add_series_map(map = geojson_file,
                    df = dados,
                    name = "Procedimento",
                    dataLabels = list(enabled = TRUE, 
                                      format = "{point.properties.name_region}"
                                      # align = "center"
                                      # verticalAlign = "middle" 
                                      # allowOverlap = FALSE
                    ),
                    value = "valor",
                    joinBy = c("name_region", "name_region")) %>% 
  hc_tooltip(
    useHTML = TRUE,
    pointFormat = "{point.tooltip}"
  ) %>%
  hc_title(text = "Mapa Interativo das Regiões do Brasil")
