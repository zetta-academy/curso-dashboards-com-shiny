# Funções adicionais para executar o aplicativo Shiny
library(tidyverse)
library(slider)


preProcessCovidData <- function(data) {
    data <- 
      data %>% 
      mutate(date = as.Date(date)) %>% 
      filter(place_type == 'city' & 
               !is.na(city)) %>% 
      arrange(date) %>% 
      mutate(selector = city, ' - ', state, ' (', city_ibge_code, ')') %>%
      group_by(city_ibge_code) %>%
      mutate(confirmed_n = new_confirmed - lag(new_confirmed)) %>%
      mutate(confirmed_n = ifelse(date == min(date), new_confirmed, confirmed_n)) %>% 
      fill(confirmed_n, .direction = 'up') %>% 
      mutate(rolling_avg7d = slider::slide_dbl(confirmed_n, mean, .before = 7, .after = 0)) %>% 
      mutate(confirmed_n = ifelse(confirmed_n < 0, 0, confirmed_n)) %>% 
      ungroup() %>% 
      as_tibble() %>% 
      select(-city, -city_ibge_code, -epidemiological_week,
             -order_for_place)
    
    return(data)
}


fetchDataBrasilIo <- function(use_cached_data = TRUE) {
  # Baixar dados da API do COVID-19 Brasil
  # Fonte: https://github.com/turicas/covid19-br
  
  if (length(list.files("data")) == 0 || use_cached_data == FALSE) {
    dir.create("data", showWarnings = FALSE)
    
    # Baixar dados da API
    covid19 <- read_csv("https://data.brasil.io/dataset/covid19/caso_full.csv.gz") 
    
    # Preparar banco de dados
    covid19 <- preProcessCovidData(covid19)
    
    # Escrever banco de dados 
    write_csv(covid19, 
              'data/covid19.gz')
    
    write_lines(unique(covid19$selector), 
                path = 'data/city_selector.gz')
    
    cat('Data were downloaded to the webapp folder')
    return(covid19)
    
  } else {
    covid19 <- read_csv("data/covid19.gz") 
    return(covid19)
  }
}


