# Desafio:
# Crie uma aplicação Shiny que receba um texto como input e 
# retorne este texto como output.

library(shiny)


ui <- fluidPage(
  textInput("nameInput", 
            label = "Escreva seu nome:"),
  textOutput("nameOutput")
)


server <- function(input, output, session) {
  # Codigo do servidor
  output$nameOutput <- renderText({
    input$nameInput
  })
}


shinyApp(ui = ui, server = server)