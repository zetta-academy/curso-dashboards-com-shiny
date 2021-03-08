library(shiny)
library(shinydashboard)
library(ggplot2)
library(plotly)


# Define a interface gráfica para aplicação Shiny
# Documentação para consulta: 
#   Shinydashboards - https://rstudio.github.io/shinydashboard/index.html
#   Shiny - https://shiny.rstudio.com/articles/layout-guide.html
ui <- dashboardPage(
    skin = "black",
    dashboardHeader(
        title = "Zetta Health Analytics - Dashboards com Shiny"
    ),
    dashboardSidebar(
        sliderInput("bins",
                    "Number of bins:",
                    min = 1,
                    max = 50,
                    value = 30)
    ),
    dashboardBody(
        tags$head(tags$link(rel = "preconnect",
                            href = "https://fonts.gstatic.com")
                  ),
        tags$head(tags$link(rel = "stylesheet",
                            href = "https://fonts.googleapis.com/css2?family=Raleway:wght@500&display=swap")
                  ),
        tags$head(tags$link(rel = "stylesheet", 
                           type = "text/css", 
                           href = "custom.css")
        ),
        # Adiciona linha com caixas
        fluidRow(
            valueBox(width = 4, 20, "Caixa 1", icon("credit-card")),
            valueBox(width = 4, 20, "Caixa 2", icon("list")),
            valueBox(width = 4, 20, "Caixa 3", icon("thumbs-up"))
        ),
        # Adiciona linha com gráfico
        fluidRow(
            box(title = "Histograma",
             width = 12,   
                 plotlyOutput("distPlot")
            )
        )
    )
)


# Define a lógica do servidor
# Não é necessário editar as linhas abaixo 
server <- function(input, output) {

    output$distPlot <- renderPlotly({
        # Cria histograma 
        ggplotly(
            ggplot(faithful, aes(x = waiting)) + 
                geom_histogram(bins = input$bins) +
                ylab("Frequência") +
                xlab("Tempo para erupção") + 
                theme_minimal()
        )
    })
}

# Executar a aplicação 
shinyApp(ui = ui, server = server)
