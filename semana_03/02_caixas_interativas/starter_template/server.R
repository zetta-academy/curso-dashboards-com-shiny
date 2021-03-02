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
library(shinydashboard) # Você precisará instalar este pacote

library(tidyverse)
library(slider)
library(distcrete)
library(epitrix)
library(incidence)
library(projections)
library(EpiEstim)

source("./utils/helpers.R") # Carregar funcoes uteis

# Abrir banco de dados
if (!"covid19" %in% ls()){
  covid19 <- fetch_data_brasil_io(use_cached_data = TRUE)   
}


# Define a logica da aplicacao 
shinyServer(function(input, output) {
    
    output$numeroCasosAcumulados <- renderInfoBox({
        codigo_da_cidade <- get_city_code(input$city)
        
        casos_acumulados <- 
            covid19 %>% 
            filter(is_last, city_ibge_code == codigo_da_cidade) %>% 
            select(last_available_confirmed)
        
        infoBox("Casos acumulados", 
                formatC(casos_acumulados$last_available_confirmed,
                        digits = 12,
                        big.mark = ".",
                        decimal.mark = ",")
                )
    })
    
    output$numeroCasosUltimoDia <- renderInfoBox({
        codigo_da_cidade <- get_city_code(input$city)
        
        casos_ultimo_dia <- 
            covid19 %>% 
            filter(is_last, city_ibge_code == codigo_da_cidade) %>% 
            select(new_confirmed)
        
        infoBox("Casos na ultima observaçao: ", 
                formatC(casos_ultimo_dia$new_confirmed,
                        digits = 12,
                        big.mark = ".",
                        decimal.mark = ",")
        )
    })
    
    output$numeroReproEfetivo <- renderValueBox({
        codigo_da_cidade <- get_city_code(input$city)
        
        data_cidade <- 
            covid19 %>% 
            filter(city_ibge_code == codigo_da_cidade) %>% 
            select(new_confirmed, date, city_ibge_code) 
        
        r_eff <-get_growth_estimates(data_cidade)
        mean_reff <- mean(r_eff[[2]])
        
        valueBox(
            value = formatC(mean_reff,
                    digits = 3,
                    big.mark = ".",
                    decimal.mark = ","),
            subtitle = "Número de Reprodução Efetivo",
            icon = icon("registered"),
            color = colorize_info(mean_reff)
        )
    })
})
