# Zetta Health Academy - Curso Dashboards com Shiny
# URL: https://github.com/zetta-academy/curso-dashboards-com-shiny
# Autor: Gabriel Kakizaki, Zetta, UFV 


# Estatística básica com R (tidyverse) ------------------------------------

# Tidyverse é uma biblioteca para o R que busca facilitar a análise de dados.
# Vamos ver como utilizar algumas de suas principais funções
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


# O código abaixo está comentado para explicar como funcionam as funções dos
# pacotes do Tidyverse
# Processar os dados da API
pre_process_covid_data <- function(data) {
    data <-
      # Temos o novo operador "%>%", chamado de "pipe". Ele serve para passar
      # os dados por várias funções
      data %>%
      # A função "mutate" é útil para mudar os dados apenas de algumas colunas
      mutate(date = as.Date(date)) %>%
      # "filter" serve para filtrar as linhas do dataset com base em algum tipo
      # de condição. No caso estamos verificando se o tipo de lugar é uma
      # cidade, e se o campo da cidade não está vazio.
      filter(place_type == "city" &
               !is.na(city)) %>%
      # "arrange" serve para ordenar os dados com base em alguma coluna
      arrange(date) %>%
      mutate(selector = paste0(city, " - ", state,
                               " (", city_ibge_code, ")")) %>%
      # "group_by" deve ser familiar se você já trabalhou com pandas ou SQL. Ela
      # funciona agrupando o dataset com base nos valores de uma coluna. Por
      # exemplo, você pode agrupar por cidade e aplicar a soma no número de
      # casos.
      group_by(city_ibge_code) %>%
      mutate(rolling_avg7d = slider::slide_dbl(new_confirmed,
                                               mean,
                                               .before = 7,
                                               .after = 0)) %>%
      mutate(confirmed_n = ifelse(new_confirmed < 0, 0, new_confirmed)) %>%
      ungroup() %>%
      as_tibble() %>%
      # Use "select" para selecionar apenas as colunas especificadas. Para
      # remover em vez de selecionar, só utilizar o sinal de "-"
      select(-city, -epidemiological_week, -order_for_place)

    return(data)
}


# Abrir banco de dados
covid19 <- fetch_data_brasil_io(use_cached_data = TRUE)

# Selecionar a capital SP
city_name <- "São Paulo - SP"

# Ler arquivo com códigos das cidades
cities_with_codes <- readLines("data/city_selector.gz", encoding = "utf-8")



# Exercícios --------------------------------------------------------------
# 01 - Tente identificar o que as linhas abaixo fazem.
# Dica: Use a documentação do R (Estes comandos são uteis: ?nome_funcao; e.g., 
#       ?grep)
city_string <- cities_with_codes[grep(city_name, cities_with_codes)[[1]]]
city_code <- as.integer(str_extract(city_string, "\\d+"))


# 02 - O que os comandos das linhas  100-103 fazem?
# Desafio: Melhore a qualidade da imagem. Procure a 
#          cola (cheatsheet) em Help > Cheatsheets > Data Visualization...
#          Não se esqueça de postar seu desafio no Discord da Zetta. 
covid19 %>%
  filter(city_ibge_code == city_code) %>%
  ggplot(aes(date, new_confirmed)) +
    geom_line()


# 03 - O que os comandos abaixo fazem?
covid19 %>%
  group_by(city_ibge_code) %>%
  mutate(cases_per_100k = sum(confirmed_n)) %>%
  select(cases_per_100k)

