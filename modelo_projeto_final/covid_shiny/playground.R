library(rgdal)
library(leaflet)


source("helpers/utils.R")

covid19 <- fetch_data_brasil_io(use_cached_data = TRUE)


# mapa --------------------------------------------------------------------

geodata <- read_csv("data/base_geolocalizacao_br.csv")

path <- sprintf("data/geoson/geojs-%s-mun.json", 31)
sp <- rgdal::readOGR(path)

state_subset <- 
  covid19 %>%
  filter(is_last & grepl("^31", city_ibge_code)) %>% 
  mutate(city_ibge_code = as.character(city_ibge_code))

sp@data <- left_join(x = sp@data,
                     y = state_subset[, c("city_ibge_code",
                                          "new_confirmed")],
                     by = c("id" = "city_ibge_code"))

pal <- colorNumeric("viridis", NULL)

leaflet(sp) %>%
  addProviderTiles(providers$Stamen.TonerLite) %>%
  addPolygons(stroke = FALSE, smoothFactor = 0.5, fillOpacity = .5,
              fillColor = ~pal(sqrt(new_confirmed)),
              label = ~paste0(name, ": ", formatC(new_confirmed, big.mark = ","))) %>%
  addLegend(pal = pal,
            values = ~sqrt(new_confirmed), 
            opacity = 1.0,
            labFormat = labelFormat(transform = function(x) round(10^x)))
  



# numero de reproducao ----------------------------------------------------


city <- filtro_opcoes_cidades[1]
city_code <- as.integer(str_extract(city, "\\d+"))

data_original <- 
  covid19 %>%
  filter(city_ibge_code == city_code) %>% 
  select(confirmed_n, date, city_ibge_code)

data_original$confirmed_n <- ifelse(data_original$confirmed_n < 0, 
                                   0,
                                   data_original$confirmed_n)


estimates <- get_growth_estimates(data_original)
