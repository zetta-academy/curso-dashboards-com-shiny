# Zetta Health Academy - Curso Dashboards com Shiny
# URL: https://github.com/zetta-academy/curso-dashboards-com-shiny
# Direitos reservados
# Autor: Henrique Gomide, Ph.D.

# IMPORTANTE - Lembre-se de configurar seu diretório de trabalho (setwd())
# Este arquivo contem a logica da aplicacao web. Voce pode executar a
# a aplicacao ao clicar em 'Run App' acima.


library(shiny)
library(bs4Dash)
library(plotly)
library(leaflet)
library(fresh)


# Filtro de opções das cidades
filtro_opcoes_cidades <- readLines("data/city_selector.gz", 
                                   encoding = "utf-8")


# Customizar tema para a dashboard
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


# Define a interface do usuário da Dashboard
bs4DashPage(
  # Inserir tag folha de estilo (CSS) dentro de <head>
  tags$head(
    tags$link(rel = "stylesheet",
              type = "text/css",
              href = "zetta.css"),
    tags$link(rel = "stylesheet",
              href = "https://fonts.googleapis.com/css2?family=Open+Sans:wght@600&display=swap")
  ),
  loading_background = "#000",   # Cor de fundo para página de carregamento
  enable_preloader = TRUE,       # Barra de carregamento
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
               # Cria seletor para escolher nome das cidades
               selectInput(inputId = "escolher_cidade", 
                           label = "Selecione uma cidade",
                           choices = filtro_opcoes_cidades)
      )
    ),
    fluidRow(
      box(title = h1(textOutput("nome_cidade")), # Retorna nome da cidade 
          width = 12,                            # Tamanho da página
          collapsible = FALSE,
          overflow = TRUE,
          # Cria primeira linha com caixas seguindo padrão Bootstrap
          fluidRow(
            bs4ValueBoxOutput("casos_ultimas_24h", width = 3), # Casos últimas 24h
            bs4ValueBoxOutput("casos_total", width = 3),       # Total de casos
            bs4ValueBoxOutput("mortes", width = 3),            # N mortes
            bs4ValueBoxOutput("n_reproducao", width = 3),      # R_efetivo
          )
      )
    ),
    bs4TabItems(
      bs4TabItem(
        tabName = "item1",
        # Cria linha com mapa
        fluidRow(
          bs4Box(width = 12,
                 height = "750px",
                 title = "Mapa",
                 # Insere mapa usando biblioteca Leaflet
                 leafletOutput("map",
                               width = "100%",
                               height = "600px")
          )
        )
      ),
      bs4TabItem(
        # Cria linha com gráficos 
        tabName = "item2",
        fluidRow(
          bs4Box(
            title = "",
            width = 12,
            bs4TabCard(
              id = "graficos_casos",
              title = "",
              width = 12,
              closable = FALSE,
              collapsible = FALSE,
              # Cria gráfico de média móvel
              bs4TabPanel(
                tabName = "Média Móvel",
                h1("Média Móvel"),
                plotlyOutput("mediaMovel")
              ),
              # Cria gráfico de casos acumulados
              bs4TabPanel(
                tabName = "Casos",
                h1("Casos Acumulados"),
                plotlyOutput("casosAcumulados")
              ),
              # Cria gráfico de óbitos
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
