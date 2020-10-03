
# Esta é a interface grafica (frontend) da aplicacao Shiny. Voce pode
# executar esta aplicacao ao clicar em "Run App" acima.
#
# Saiba mais sobre construir aplicacoes shiny em:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(bs4Dash)
library(plotly)

filtro_opcoes_cidades <- readLines("data/city_selector.gz")

# Definir a interface do usuário da Dashboard

bs4DashPage(
  loading_background = "#000000",
  enable_preloader = TRUE, # Barra de carregamento
  sidebar_mini = TRUE,
  sidebar_collapsed = TRUE,
  bs4DashSidebar(
    skin = "light",
    status = "primary",
    title = "Zetta",
    elevation = 3,
    opacity = 0.8,
    bs4SidebarMenu(
      bs4SidebarHeader("Header 1"),
      bs4SidebarMenuItem(
        "Mapa Região",
        tabName = "item1",
        icon = "map-marker"
      ),
      bs4SidebarMenuItem(
        "Estatísticas",
        tabName = "item2",
        icon = "id-card"
      )
    )
  ),
  bs4DashNavbar(
    skin = "light",
    status = "white",
    compact = TRUE,
    border = FALSE
  ),
  bs4DashBody(
    fluidRow(
      br(),
      selectInput(inputId = "escolher_cidade", 
                  label = "Selecione uma cidade",
                  choices = filtro_opcoes_cidades)
    ),
    fluidRow(
      box(title = h1("São Paulo"), 
          width = 12,
          collapsible = FALSE,
          overflow = TRUE,
          fluidRow(
            bs4ValueBox(
              value = h1(3),
              subtitle = "Casos na últimas 24h",
              elevation = 1,
              status = "white",
              icon = "user-friends",
              footer = ""
            ),
            bs4ValueBox(
              value = h1(3),
              subtitle = "Total de casos",
              elevation = 1,
              status = "white",
              icon = "users",
              footer = ""
            ),
            bs4ValueBox(
              value = h1(3),
              subtitle = "Total de mortes",
              elevation = 1,
              status = "white",
              footer = ""
            ),
            bs4ValueBox(
              value = h1(3),
              subtitle = "Número de reprodução",
              elevation = 1,
              status = "primary",
              icon = "registered",
              footer = ""
            )
          )
      )
    ),
    bs4TabItems(
      bs4TabItem(
        tabName = "item1",
        fluidRow(
          bs4Box(width = 12,
                 title = "Mapa",
                 leafletOutput("map")
          )
        ),
        bs4Box(
          title = "Número de casos e mortes",
          width = 12,
          bs4TabCard(
            id = "graficos_casos",
            title = "",
            width = 12,
            closable = FALSE,
            collapsible = FALSE,
            bs4TabPanel(
              tabName = "Casos",
              h1("Casos Acumulados"),
              plotlyOutput("casosAcumulados")
            ),
            bs4TabPanel(
              tabName = "Média Móvel",
              h1("Média Móvel"),
              plotlyOutput("mediaMovel")
            ),
            bs4TabPanel(
              tabName = "Óbitos",
              h1("Óbitos"),
              plotlyOutput("obitos")
            )
          )
        )
      ),
      bs4TabItem(
        tabName = "item2",
      )
    )
  ),
  bs4DashFooter("Zetta Health Analytics", 
                copyrights = "©",
                right_text = "2021"),
)
