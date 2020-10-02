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

# Definir a interface do usuário da Dashboard

bs4DashPage(
    title = 'COVID 19 AGORA',
    bs4DashNavbar(
        skin = 'dark',
        compact = TRUE
    ),
    bs4DashBody(
        # Titulo da pagina
        fluidRow(
            column(12,
                   # Controladores / filtros 
                   selectInput(inputId = "escolher_cidade", 
                               label = "Selecione uma cidade",
                               choices = select_city_options)
            )
        ),# aqui nessa parte é necessario mencionar um pouco de bootstrap, visto que não são todos com esse conhecimento
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
    ),
    bs4DashFooter(),
)
