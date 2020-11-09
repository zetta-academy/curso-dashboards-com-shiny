# IMPORTANTE - Lembre-se de configurar seu diretório de trabalho (setwd())
# Este arquivo contem a logica da aplicacao web. Voce pode executar a
# a aplicacao ao clicar em 'Run App' acima.
#
# Saiba mais sobre construir aplicacoes shiny em:
#
#    http://shiny.rstudio.com/
#

# Carregar pacotes do R para o arquivo do servidor
library(shiny)
library(dplyr)
library(readr)
library(ggplot2)
library(plotly)
library(scales)
library(rgdal)
library(leaflet)


# Carregar funcoes adicionais para obter dados de API, estimar o numero de 
# reproducao
source("helpers/utils.R")

covid19 <- fetch_data_brasil_io(use_cached_data = TRUE)
geodata <- read_csv("data/base_geolocalizacao_br.csv")

# Define a logica de programacao para gerar o grafico 1

shinyServer(function(input, output) {
    
    # Nome da cidade
        output$nome_cidade <- renderText({
        city_selector <- input$escolher_cidade
        city_name <- gsub("\\d+|\\(|\\)|[\\s]+$",
                          replacement = "",
                          city_selector)
        city_name
    })
    
    # 0. Value Boxes ----
    # 0.1 Numero de casos nas ultimas 24h
    output$casos_ultimas_24h <- renderbs4ValueBox({
        
        city_selector <- input$escolher_cidade
        citycode <- as.integer(str_extract(city_selector, "\\d+"))
        
        ncases <- 
            covid19 %>% 
            filter(is_last & covid19$city_ibge_code == citycode) %>% 
            select(new_confirmed)
        
        bs4ValueBox(
            value = h1(formatC(ncases$new_confirmed, 
                               digits = 12,
                               big.mark = ".",
                               decimal.mark = ",")),
            subtitle = "Casos na últimas 24h",
            elevation = 1,
            status = "white",
            icon = "user-friends",
            footer = ""
        )
    })
    
    
    # 0.2. Casos total
    output$casos_total <- renderbs4ValueBox({
        
        city_selector <- input$escolher_cidade
        citycode <- as.integer(str_extract(city_selector, "\\d+"))
        
        ncases <- 
            covid19 %>% 
            filter(is_last & covid19$city_ibge_code == citycode) %>% 
            select(last_available_confirmed)
        
        bs4ValueBox(
            value = h1(formatC(ncases$last_available_confirmed, 
                               digits = 12,
                               big.mark = ".",
                               decimal.mark = ",")),
            subtitle = "Total de casos",
            elevation = 1,
            status = "white",
            icon = "users",
            footer = ""
        )
    })
    
    
    # 0.3. Mortes
    output$mortes <- renderbs4ValueBox({
        
        city_selector <- input$escolher_cidade
        citycode <- as.integer(str_extract(city_selector, "\\d+"))
        
        ncases <- 
            covid19 %>% 
            filter(is_last & covid19$city_ibge_code == citycode) %>% 
            select(last_available_deaths)
        
        bs4ValueBox(
            value = h1(formatC(ncases$last_available_deaths, 
                               digits = 12,
                               big.mark = ".",
                               decimal.mark = ",")),
            subtitle = "Total de mortes",
            elevation = 1,
            status = "white",
            footer = ""
        )
    })
        
    
    # 0.4. Numero de reproducao efetivo
    output$n_reproducao <- renderbs4ValueBox({
        
        city_selector <- input$escolher_cidade
        city_code <- as.integer(str_extract(city_selector, "\\d+"))
        
        data_original <- 
          covid19 %>%
          filter(city_ibge_code == city_code) %>% 
          select(confirmed_n, date, city_ibge_code)

        data_original$confirmed_n <- ifelse(data_original$confirmed_n < 0, 
                                            0,
                                            data_original$confirmed_n)

        estimates <- get_growth_estimates(data_original)
        meanR <- mean(estimates[[2]])
        lowerR <- meanR - 2*sd(estimates[[2]])
        higherR <- meanR + 2*sd(estimates[[2]]) 
        
        bs4ValueBox(
            value = h1(formatC(meanR, 
                               digits = 2,
                               big.mark = ".",
                               decimal.mark = ","),
                       tags$sub(
                           paste0(
                               "[",
                               formatC(lowerR, digits = 2),
                               "-",
                               formatC(higherR, digits = 2),
                               "]"
                           )
                       )),
            subtitle = "R efetivo (IC95%)" ,
            icon = "registered",
            status = colorize_infovalue(meanR),
            elevation = 1,
            footer = ""
        )
    })
        
    
    
    # 1. Painel Mapa ----
    # 1.1 Map
    output$map <- renderLeaflet({
        # Definir paleta
        pal <- colorNumeric("viridis", NULL)
        
        city_selector <- input$escolher_cidade
        
        citycode <- as.integer(str_extract(city_selector, "\\d+"))
        
        state_subset <- 
            covid19 %>%
            filter(is_last & grepl(paste0("^", substr(citycode, 1, 2)), city_ibge_code)) %>% 
            left_join(., geodata, by = c("city_ibge_code" = "codigo_ibge")) %>% 
            mutate(city_ibge_code = as.character(city_ibge_code))
        
        path <- sprintf("data/geoson/geojs-%s-mun.json", substr(citycode, 1, 2))
        shapefile <- rgdal::readOGR(path)
        
        shapefile@data <- left_join(shapefile@data,
                                    state_subset,
                                    by = c("id" = "city_ibge_code"))
        
        selected_city_geocode <- 
            geodata %>% 
            filter(codigo_ibge == citycode)
        
        m <- 
            leaflet(shapefile) %>%
            addProviderTiles(providers$Stamen.TonerLite) %>% 
            setView(lng = selected_city_geocode$longitude,
                    lat = selected_city_geocode$latitude,
                    zoom = 11) %>%
            addPolygons(stroke = FALSE, 
                        smoothFactor = 0.5, 
                        fillOpacity = .4,
                        fillColor = ~pal(log(rolling_avg7d + 1e-3)),
                        label = ~paste0(name, 
                                        ": ", 
                                        formatC(rolling_avg7d, 
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
    })
    
    
    
    # 2.1. Media movel ----
    output$mediaMovel <- renderPlotly({
        
        # Criar banco de dados com cidade
        city_selector    <- input$escolher_cidade
        
        city_data <- 
            covid19 %>% 
            filter(selector == city_selector) %>% 
            select(date, rolling_avg7d)
        
        ggchart_01 <- city_data %>% 
            ggplot(aes(x = date, y = rolling_avg7d)) +
            geom_line(size = 1) + 
            theme_minimal(base_size = 18) + 
            xlab('') + 
            ylab('') +
            scale_y_continuous(labels = scales::comma) +
            scale_x_date(date_breaks = "1 month", 
                         date_labels = "%m/%y")
        
        ggplotly(ggchart_01)
        
    })
    
    
    # 2.2 Casos Acumulados
    output$casosAcumulados <- renderPlotly({
        
        city_selector    <- input$escolher_cidade
        
        city_data <- 
            covid19 %>% 
            filter(selector == city_selector) %>% 
            select(date, last_available_confirmed)
        
        ggchart_01 <- city_data %>% 
            ggplot(aes(x = date, y = last_available_confirmed)) +
            geom_line(size = 1) + 
            theme_minimal(base_size = 18) + 
            xlab('') + 
            ylab('') +
            scale_y_continuous(labels = scales::comma) +
            scale_x_date(date_breaks = "1 month", 
                         date_labels = "%m/%y")
        
        ggplotly(ggchart_01)
        
    })
    
    
    # 2.3. Óbitos
    output$obitos <- renderPlotly({
        
        # Criar banco de dados com cidade
        city_selector    <- input$escolher_cidade
        
        city_data <- 
            covid19 %>% 
            filter(selector == city_selector) %>% 
            select(date, last_available_deaths)
        
        ggchart_01 <- city_data %>% 
            ggplot(aes(x = date, y = last_available_deaths)) +
            geom_line(size = 1) + 
            theme_minimal(base_size = 18) + 
            xlab('') + 
            ylab('') +
            scale_y_continuous(labels = scales::comma) +
            scale_x_date(date_breaks = "1 month", 
                         date_labels = "%m/%y")
        
        ggplotly(ggchart_01)
    })
    
})


# Comments #####
# Painel 2
#        # Criar banco de dados com cidade
#        city_selector    <- input$escolher_cidade
#        city_data <- 
#            covid19 %>% 
#            # aqui aplica a selecao do usuario para a construcao do grafico 
#            filter(selector == city_selector) %>% 
#            #aqui seleciona as colunas para apresentacao no grafico 
#            select(date, last_available_confirmed, last_available_deaths, 
#                   rolling_avg7d) %>% 
#            # essa funcao gather serve para fazer a transposicao dos dados, invertendo linhas para colunas e vice-versa
#            # exemplo
#            #-----------------------------------------------
#            # codigo produto | descricao produto | preco 
#            #-----------------------------------------------
#            # ban001         | banana            | 1.00
#            # lar001         | laranja           | 2.00
#            # mac001         | maca              | 1.50
#            
#            #usando a funcao gather ficaria assim 
#            
#            # ban001 | lar001 | mac001 isso para a primeira coluna, e para todas as outras assim essa tabela acima
#            # ficaria com 12 colunas ao inves de apenas 3 como mostrado acima
#            # para cada linha ele cria uma nova coluna, usado para facilitar a visualizacao.
#        
#            gather("tipo", "indicador", -date)
#        
#        # Criar gráfico de linhas com acumulo de casos e mortes
#        ggchart_01 <- city_data %>% 
#            ggplot(aes(x = date, y = indicador, colour = tipo)) +
#            geom_line(size = 1) + 
#            theme_minimal(base_size = 18) + 
#            xlab('') + 
#            ylab('') +
#            scale_y_continuous(labels = scales::comma) +
#            scale_x_date(date_breaks = "1 month", 
#                         date_labels = "%m/%y")
#        ggplotly(ggchart_01)

