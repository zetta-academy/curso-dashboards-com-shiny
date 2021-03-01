# Zetta Health Academy - Curso Dashboards com Shiny
# URL: https://github.com/zetta-academy/curso-dashboards-com-shiny
# Autor: Henrique Gomide, Ph.D.
#
# Esta e a interface grafica do aplicativo Shiny (o que vai aparecer na tela) 
# Para executar a aplicacao: clique em 'Run App' no canto superior direito deste
# quadrante 
#
# Recomendamos que busque mais informacoes sobre o shiny neste link:
#    http://shiny.rstudio.com/

# Você precisará instalar este pacote
# Documentação https://rstudio.github.io/shinydashboard/structure.html 
library(shinydashboard) # Você precisará instalar este pacote

library(shiny)


# Carrega a lista de cidades
city_options <- read_lines("data/city_selector.gz")


#  Definir a interface grafica da aplicacao shiny 
shinyUI <- dashboardPage(
    dashboardHeader(title = "Dashboards com Shiny"),
    dashboardSidebar(
    ),
    dashboardBody(
        fluidRow(
            box(
                title = "Cidade: ",
                selectInput("city",
                            label = "Selecione uma cidade", 
                            choices = city_options,
                            selected = city_options[0]),
            )
        ),
        fluidRow(
            infoBoxOutput("numeroCasosAcumulados"),
            infoBoxOutput("numeroCasosUltimoDia"),
            valueBoxOutput("numeroReproEfetivo")
            
        )
    )
)