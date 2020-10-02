# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(bs4Dash)
library(plotly)

select_city_options <- readLines('data/city_selector.gz')

# Define UI for application that draws a histogram

bs4DashPage(
    fluidPage(
        # Titulo da pagina
        titlePanel('COVID 19 AGORA'),
        fluidRow(
            column(12,
                   # Controladores
                   selectInput("choose_city", 
                               "Selecione uma cidade",
                               choices = select_city_options)
            )
        ),
        fluidRow(
            column(12,
                   h2('Evolução por dia, total de casos e óbitos por COVID-19'),
                   # Casos e mortes acumulados
                   plotlyOutput("distPlot")
            )
        ),
        fluidRow(
            # Gráfico 2
        ),
        fluidRow(
            # Mapa
        ),
        fluidRow(
            # Tabela
        )
    ))
