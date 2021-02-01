# Zetta Health Academy - Curso Dashboards com Shiny
# URL: https://github.com/zetta-academy/curso-dashboards-com-shiny
# Autor: Henrique Gomide, Ph.D., UFV

# Estatística básica com R (tidyverse)
library(tidyverse)

# Funcoes - Baixar dados da API do COVID-19 Brasil
# use_cached_data (logical): tenta usar dados já baixados
# para evitar consulta desnecesssária a API 
fetch_data_brasil_io <- function(use_cached_data = TRUE) {
  
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
    covid19
    
  } else {
    covid19 <- read_csv("data/covid19.gz") 
    covid19
  }
}


# Processar os dados da API
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


# Abrir banco de dados
covid19 <- fetch_data_brasil_io(use_cached_data = TRUE)



# Para todos os munícipios brasileiros, qual a cidade com maior número de óbitos
# na última data disponível
covid19 %>% # Hotkey (ctrl + shift + m)
  filter(is_last) %>%  # filter
  arrange(desc(new_deaths)) %>% 
  head() %>%  
  view()


# Quantidade de mortes por UF
covid19 %>% 
  group_by(state, date) %>% 
  summarise(deaths = sum(new_deaths)) %>% 
  ggplot(aes(x = date, y = deaths)) + 
  geom_line() + 
  facet_wrap( ~ state)
  