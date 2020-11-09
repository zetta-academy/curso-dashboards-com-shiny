# IMPORTANTE - Lembre-se de configurar seu diretório de trabalho (setwd())
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
library(leaflet)
library(fresh)

# Filtro de opções das cidades
filtro_opcoes_cidades <- readLines("data/city_selector.gz", 
                                   encoding = "utf-8")


# Definir tema
zetta_theme <- create_theme(
  bs4dash_vars(
    navbar_light_color = "#bec5cb",
    navbar_light_active_color = "#f5ed2e",
    navbar_light_hover_color = "#333"
  ),
  bs4dash_yiq(
    contrasted_threshold = 10,
    text_dark = "#000", 
    text_light = "#999"
  ),
  bs4dash_layout(
    main_bg = "#fff"
  ),
  bs4dash_sidebar_light(
    bg = "#fff", 
    color = "#01a8cc",
    hover_color = "#01a8cc",
    submenu_bg = "#272c30", 
    submenu_color = "#FFF", 
    submenu_hover_color = "#FFF"
  ),
  bs4dash_status(
    primary = "#01a8cc", danger = "#bf40bf", light = "#00ff00"
  ),
  bs4dash_color(
    gray_900 = "#333"
  )
)


# Definir a interface do usuário da Dashboard
bs4DashPage(
  tags$head(
    tags$link(rel = "stylesheet",
              type = "text/css",
              href = "zetta.css"),
    tags$link(rel = "stylesheet",
              href = "https://fonts.googleapis.com/css2?family=Open+Sans:wght@600&display=swap")
  ),
  loading_background = "#000",
  enable_preloader = TRUE, # Barra de carregamento
  sidebar_mini = TRUE,
  sidebar_collapsed = TRUE,
  bs4DashSidebar(
    skin = "light",
    status = "primary",
    title = "Zetta Academy",
    src = "zettahealth.png",
    elevation = 2,
    opacity = 0.8,
    bs4SidebarMenu(
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
    use_theme(zetta_theme),
    fluidRow(
      tags$div(id = "input-selector",
               br(),
               selectInput(inputId = "escolher_cidade", 
                           label = "Selecione uma cidade",
                           choices = filtro_opcoes_cidades)

      )
    ),
    fluidRow(
      box(title = h1(textOutput("nome_cidade")), 
          width = 12,
          collapsible = FALSE,
          overflow = TRUE,
          fluidRow(
            bs4ValueBoxOutput("casos_ultimas_24h", width = 3),
            bs4ValueBoxOutput("casos_total", width = 3),
            bs4ValueBoxOutput("mortes", width = 3),
            bs4ValueBoxOutput("n_reproducao", width = 3),
          )
      )
    ),
    bs4TabItems(
      bs4TabItem(
        tabName = "item1",
        fluidRow(
          bs4Box(width = 12,
                 height = "750px",
                 title = "Mapa",
                 leafletOutput("map",
                               width = "100%",
                               height = "600px")
          )
        )
      ),
      bs4TabItem(
        tabName = "item2",
        fluidRow(
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
                tabName = "Média Móvel",
                h1("Média Móvel"),
                plotlyOutput("mediaMovel")
              ),
              bs4TabPanel(
                tabName = "Casos",
                h1("Casos Acumulados"),
                plotlyOutput("casosAcumulados")
              ),
              bs4TabPanel(
                tabName = "Óbitos",
                h1("Óbitos"),
                plotlyOutput("obitos")
              )
            )
          )
        )
      )
    )
  ),
  bs4DashFooter("Zetta Academy", 
                copyrights = "©",
                right_text = "2021"),
)
