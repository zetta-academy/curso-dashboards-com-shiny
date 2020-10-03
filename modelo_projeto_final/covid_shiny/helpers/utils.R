# Funções adicionais para executar o aplicativo Shiny

library(tidyverse)  # Data manipulation
library(slider)     # Rolling average
library(leaflet)
library(htmltools)


pre_process_covid_data <- function(data){
    data <- 
      data %>% 
      mutate(date = as.Date(date)) %>% 
      filter(place_type == "city" & 
               !is.na(city)) %>% 
      arrange(date) %>% 
      mutate(selector = paste0(city, " - ", state, 
                               " (", city_ibge_code, ")")) %>%
      group_by(city_ibge_code) %>%
      mutate(rolling_avg7d = slider::slide_dbl(new_confirmed,
                                               mean,
                                               .before = 7,
                                               .after = 0)) %>% 
      mutate(confirmed_n = ifelse(new_confirmed < 0, 0, new_confirmed)) %>% 
      ungroup() %>% 
      as_tibble() %>% 
      select(-city, -epidemiological_week, -order_for_place)
    
    return(data)
}



fetch_data_brasil_io <- function(use_cached_data = TRUE) {
  # Baixar dados da API do COVID-19 Brasil
  # Fonte: https://github.com/turicas/covid19-br
  
  if (length(list.files("data")) == 0 || use_cached_data == FALSE) {
    dir.create("data", showWarnings = FALSE)
    
    # Baixar dados da API
    covid19 <- read_csv("https://data.brasil.io/dataset/covid19/caso_full.csv.gz") 
    
    # Preparar banco de dados
    covid19 <- pre_process_covid_data(covid19)
    
    # Escrever banco de dados 
    write_csv(covid19, 
              "data/covid19.gz")
    
    write_lines(unique(covid19$selector), 
                path = "data/city_selector.gz")
    
    cat("Dados foram baixados para seu computador")
    return(covid19)
    
  } else {
    covid19 <- read_csv("data/covid19.gz") 
    return(covid19)
  }
}

