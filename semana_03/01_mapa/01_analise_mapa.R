#########################################################################
# Zetta Health Academy - Curso Dashboards com Shiny
# Mapas com Leaflet 
# Link: https://github.com/zetta-academy/curso-dashboards-com-shiny
# Autor: Henrique Gomide, Ph.D., Zetta R&D, UFV
#########################################################################


# Objetivos ---------------------------------------------------------------
# 1. Criar mapa com visualização interativa dos dados de COVID para determinada cidade brasileira e demais municípios de seu estado

# 2. Preparar o mapa para nossa Dashboard:
#    - Carregar dados de geolocalização e dos limites dos municípios (shapefiles)
#    - Combinar dados das bases para criar o mapa
#    - Criar um mapa interativo com limites dos municípios



# Carregar pacotes e bibliotecas ------------------------------------------
library(tidyverse) # Manipulacao de dados e criacao de graficos
library(leaflet)   # Visualizar mapas com Leaflet 
library(rgdal)     # Abrir e manipular shapefiles


# Carregar banco de dados -------------------------------------------------
# Baixar dados da API Brasil IO
# OBS: Pode demorar um pouco dependendo de sua conexao
covid19 <- read_csv("https://data.brasil.io/dataset/covid19/caso_full.csv.gz") 
geolocalizacao <- read_csv("starter_template/data/base_geolocalizacao_br.csv")


# Parte A -----------------------------------------------------------------

# Encontrar código de SP, cidade
amostra <- covid19[sample(nrow(covid19), 10E4, replace = FALSE), 
                   c("city", "city_ibge_code")]
# view(amostra)

# Código de São Paulo
cidade_sp <- 3550308


# Filtrar dados de São Paulo em geolocalizacao
# Informacao Cidades do estado de SP têm código que iniciam em "35".
geolocalizacao %>% 
  filter(codigo_ibge == cidade_sp)


# Exercício 1
# Selecionar apenas a última informação disponível dos municípios do estado 
# de São Paulo na Base da COVID19

covid19 %>% 
  filter(is_last & 
           grepl("^35", city_ibge_code))


# Combinar bases de dados da COVID19 e geolocalizacao (latitude e longitude)
data_estado_sp <- 
  covid19 %>% 
  filter(is_last & 
           grepl("^35", city_ibge_code)) %>% 
  left_join(., 
            geolocalizacao, 
            by = c("city_ibge_code" = "codigo_ibge"))

## Testar join
data_estado_sp %>% 
  filter(city_ibge_code == city_ibge_code)



# Mapa 1 - Básico --------------------------------------------------------------
m <- 
  leaflet() %>% 
  addProviderTiles(providers$Stamen.TonerLite)


# Selecionar dados da cidade de Sao Paulo
cidade_sp_geo <- 
  geolocalizacao %>% 
  filter(codigo_ibge == cidade_sp)


# Adicionar cidade ao centro do mapa
m <- 
  leaflet() %>% 
  addProviderTiles(providers$Stamen.TonerLite) %>% 
  setView(lng = cidade_sp_geo$longitude,
          lat = cidade_sp_geo$latitude, 
          zoom = 11)
  

# Adicionar divisas das cidades, marcadores e informações no mapa.
# Ação - Identificar padrões na pasta 'started_template/data/geoson'

caminho_shapefile <- sprintf("starter_template/data/geoson/geojs-%s-mun.json",
                             substr(cidade_sp, start = 1, stop = 2))

shapefile <- readOGR(caminho_shapefile)
glimpse(shapefile)


# Join colunas do banco de dados da covid19 com shapefiles
shapefile@data$id <- as.numeric(shapefile@data$id)

shapefile@data <- 
  left_join(shapefile@data,
            data_estado_sp, 
            by = c("id" = "city_ibge_code"))




# Mapa 2 - ShapeFiles ----------------------------------------------------------
pal <- colorNumeric("viridis", NULL)
m <- 
  leaflet(shapefile) %>% 
  addProviderTiles(providers$Stamen.TonerLite) %>% 
  setView(lng = cidade_sp_geo$longitude,
          lat = cidade_sp_geo$latitude, 
          zoom = 11) %>% 
  addPolygons(stroke = FALSE,
              smoothFactor = .5,
              fillOpacity = .4,
              fillColor = ~pal(new_confirmed),
              label = ~paste0(name, 
                              ": ",
                              formatC(new_confirmed,
                                      big.mark = ",")))
m

 

# Mapa 3 - Final ----------------------------------------------------------
pal <- colorNumeric("viridis", NULL)
m <- 
  leaflet(shapefile) %>% 
  addProviderTiles(providers$Stamen.TonerLite) %>% 
  setView(lng = cidade_sp_geo$longitude,
          lat = cidade_sp_geo$latitude, 
          zoom = 11) %>% 
  addPolygons(stroke = FALSE,
              smoothFactor = .5,
              fillOpacity = .4,
              fillColor = ~pal(log(new_confirmed + 1e-3)),
              label = ~paste0(name, 
                              ": ",
                              formatC(new_confirmed,
                                      big.mark = ","))) %>% 
  addAwesomeMarkers(~longitude, 
                    ~latitude, 
                    icon = makeAwesomeIcon(icon = "",
                                           text = "", 
                                           markerColor = "cadetblue"),
                    popup = 
                      sprintf("<h3>%s</h3>
                                   <p>Última atualização: %s</p>
                                   <p><b>Últimas 24h:</b></h5>
                                   <p>Casos<b>: %0.f</b></p>
                                   <p>Mortes<b>: %0.f</b></p>
                                   ", 
                              shapefile@data$nome,
                              format.Date(shapefile@data$date, "%d/%m/%Y"),
                              shapefile@data$new_confirmed,
                              shapefile@data$new_deaths
                      ),
                    clusterOptions = markerClusterOptions()
  ) 
m
