# Desafio:
# Crie uma aplicação Shiny que receba um texto como input e 
# retorne este texto como output.

library(shiny)


ui <- fluidPage(
  # Dica: use textInput e textOuput
  # Cola: https://raw.githubusercontent.com/rstudio/cheatsheets/master/shiny.pdf 
  # Edite as linhas abaixo
  title = "Minha aplicação Shiny",
  h1("Desafio 1"),
  p("Crie uma aplicação Shiny que receba um texto como input e 
retorne este texto como output."),
)


server <- function(input, output, session) {
  # Codigo do servidor
  output$nameOutput <- renderText({
    # Edite as linhas abaixo #
    # Seu código aqui:
    
  })
}

shinyApp(ui = ui, server = server)