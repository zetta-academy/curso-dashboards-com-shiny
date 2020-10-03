#
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


# Carregar funcoes adicionais para obter dados de API, estimar o numero de 
# reproducao
source("helpers/utils.R")

covid19 <- fetch_data_brasil_io(use_cached_data = TRUE)
geodata <- read_csv("data/base_geolocalizacao_br.csv")

# Define a logica de programacao para gerar o grafico 1

shinyServer(function(input, output) {

    # Painel 1
    # 1.1 Casos Acumulados
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
        
    })
    
    #1.2. Media movel
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
    
    # 1.3. Óbitos
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
    
    # 1.4 Map
    output$map <- renderLeaflet({
        city_selector <- input$escolher_cidade
        
        
        citycode <- as.integer(str_extract(city_selector, "\\d+"))
        
        state_subset <- 
            covid19 %>%
            filter(is_last & grepl(paste0("^", substr(citycode, 1, 2)), city_ibge_code)) %>% 
            left_join(., geodata, by = c("city_ibge_code" = "codigo_ibge"))
        
        selected_city_geocode <- 
            geodata %>% 
            filter(codigo_ibge == citycode)
        
        m <- 
            leaflet(state_subset) %>%
            addProviderTiles(providers$Stamen.TonerLite) %>% 
            setView(lng = selected_city_geocode$longitude,
                    lat = selected_city_geocode$latitude,
                    zoom = 11) %>% 
            addMarkers(~longitude,
                       ~latitude,
                       popup = 
                           sprintf("<h3>%s</h3>
               <p>Última atualização: %s</p>
               <p><b>Últimas 24h:</b></h5>
               <p>Casos<b>: %0.f</b></p>
               <p>Mortes<b>: %0.f</b></p>
               <p5><b>Total:</b></p>
               <p>Casos<b>: %0.f</b></p>
               <p>Mortes<b>: %0.f</b></p>
                       ", 
                                   state_subset$nome,
                                   format.Date(state_subset$date, "%d/%m/%Y"),
                                   state_subset$new_confirmed,
                                   state_subset$new_deaths,
                                   state_subset$last_available_confirmed,
                                   state_subset$last_available_deaths
                           )
            )
        m
    })

})
