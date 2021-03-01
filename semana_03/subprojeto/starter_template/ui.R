###############################################################################
# Zetta Health Academy - Curso Dashboards com Shiny
# PROJETO 2 - Caixas interativas e Mapas
###############################################################################
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
            # Exercício 1:
            # Melhoria de Interface do Usuário
            # Insira a data da última observação válida como cabeçalho (h1)
            # Seu código aqui:
            
            
            
            
            # Fim do exercício 1
            infoBoxOutput("numeroCasosAcumulados"),
            infoBoxOutput("numeroCasosUltimoDia"),
            valueBoxOutput("numeroReproEfetivo")
            
        ),
        fluidRow(
            # Exercício 2:
            # Adicione o mapa feito na primeira parte da aula. 
            # Especificações:
            # 1. O mapa deve estar centralizado na cidade escolhida pelo selectInput
            # 2. O mapa deve conter indicadores sobre COVID usando marcadores e 
            #    polígonos que separam as cidades
            # 3. Seu código abaixo:
            
            # Fim do exercício 2
        ),
        fluidRow(
            # Desafio (Difícil):
            # Adicione um gráfico de linhas com variações do R efetivo ao longo
            # do tempo para o município.
            # Seu código abaixo:
            
            
            # Fim do desafio
        )
    )
)