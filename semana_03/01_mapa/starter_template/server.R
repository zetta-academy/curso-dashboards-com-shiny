# Zetta Health Academy - Curso Dashboards com Shiny
# URL: https://github.com/zetta-academy/curso-dashboards-com-shiny
# Autor: Henrique Gomide, Ph.D.
#
# Esta e a logica do aplicativo Shiny (onde a magica realmente acontece) 
# Para executar a aplicacao: clique em 'Run App' no canto superior direito deste
# quadrante 
#
# Recomendamos que busque mais informacoes sobre o shiny neste link:
#    http://shiny.rstudio.com/

library(shiny)
library(slider)
library(plotly)

source("utils/helpers.R") # Carregar funcoes uteis

# Abrir banco de dados
covid19 <- fetch_data_brasil_io(use_cached_data = TRUE) 


# Define a logica da aplicacao 
shinyServer(function(input, output) {
    
    output$cityNameOuput <- renderText({
        codigo_da_cidade <- get_city_code(input$city)
        paste("O codigo da cidade e :", codigo_da_cidade)
        
    })

    output$graficoMediaMovel <- renderPlotly({
        # O que voce precisara implementar, em linhas gerais:
        #     1. Usar o codigo da funcao para escolher os dados de determinada cidade
        #     2. Estimar a media movel usando uma janela temporal
        #     3. Retornar um objeto ggplotly com seu grafico criado
        #     DESAFIO. Crie um seletor para o usuario escolher
        #              entre a media movel de 7, 14, 30 dias
        codigo_da_cidade <- get_city_code(input$city)
        
        # Editar a partir desta linha

        
    })

})
