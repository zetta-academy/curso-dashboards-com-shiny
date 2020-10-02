#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(readr)
library(ggplot2)
library(plotly)
library(scales)

source("helpers/utils.R")

covid19 <- fetchDataBrasilIo(use_cached_data = TRUE)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$distPlot <- renderPlotly({

        # Criar banco de dados com cidade
        city_selector    <- input$choose_city
        city_data <- 
            covid19 %>% 
            filter(selector == city_selector) %>% 
            select(date, last_available_confirmed, last_available_deaths, 
                   rolling_avg7d) %>% 
            gather("tipo", "indicador", -date)
        
        # Criar gráfico de linhas com acumulo de casos e mortes
        ggchart_01 <- city_data %>% 
            ggplot(aes(x = date, y = indicador, colour = tipo)) +
            geom_line(size = 1) + 
            theme_minimal(base_size = 20) + 
            xlab('') + 
            ylab('') +
            theme(legend.position = "top") +
            scale_y_continuous(labels = scales::comma) +
            scale_x_date(date_breaks = "1 month", 
                         date_labels = "%m/%y")
        
        ggplotly(ggchart_01)
        
    })

})
