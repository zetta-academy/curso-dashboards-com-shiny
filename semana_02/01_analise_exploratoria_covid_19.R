#########################################################################
# Zetta Health Academy - Curso Dashboards com Shiny
# Analise exploratoria dos dados da COVID-19
# Link: https://github.com/zetta-academy/curso-dashboards-com-shiny
# Autor: Henrique Gomide, Ph.D., Zetta R&D, UFV
#########################################################################


# Objetivos ---------------------------------------------------------------
# 1. Explorar o banco de dados da COVID-19
# 2. Preparar os gráficos para nossa Dashboard:
#    - Gráfico de casos acumulados
#    - Gráfico de mortes acumuladas
#    - Média móvel


# Carregar pacotes e bibliotecas ------------------------------------------
library(tidyverse) # Manipulacao de dados e criacao de graficos
library(slider)    # Estimar media movel
library(plotly)    # Carregar API do plotly para transformar ggplot > plotly


# Carregar banco de dados -------------------------------------------------
# Baixar dados da API Brasil IO
# OBS: Pode demorar um pouco dependendo de sua conexao
covid19 <- read_csv("https://data.brasil.io/dataset/covid19/caso_full.csv.gz") 

class(covid19) # Repare que ele possui varias classes ¯\_(ツ)_/¯


# Parte A -----------------------------------------------------------------
## Inspecionar o banco de dados
## Exercicio 1 - Quantas linhas e colunas (atributos) temos no banco?
## Dica: use a funcao glimpse ou str

glimpse(covid19)
summary(covid19)


## Inspecionar as 1000 primeiras linhas do banco de dados
view(covid19[1:1000, ])


## Qual o city_ibge_code da cidade de SP? 
## Qual coluna possui os casos acumulados?
sao_paulo <- 3550308


## Quais colunas possuem os casos e mortes acumulados?
## last_available_confirmed
## last_available_deaths


## Quais colunas possuem os casos e mortes por dia?
## new_confirmed
## new_deaths


# Validacao dos dados -----------------------------------------------------

# Estrategia: selecionar uma cidade para organizar as analises

sp_data <- 
  covid19 %>% # Operador Pipe (%>%) permite encadeamento de comandos
  filter(city_ibge_code == sao_paulo) # Filtra usando uma comparacao 


# Selecionar apenas as colunas de intesse
sp_data_min <- 
  sp_data %>% 
  select(city_ibge_code, 
         date,
         last_available_confirmed, last_available_deaths,
         new_confirmed, new_deaths)

summary(sp_data_min)


# Ver dados de novos casos e mortes
sp_data_min %>% 
  select(date, new_confirmed, new_deaths) %>% 
  pivot_longer(-date) %>% 
  ggplot(aes(x = date,y  = value)) +
  geom_line() + 
  facet_wrap(~ name, scales = "free")

# Exercício: Como podemos melhorar a visualização acima?



# Parte B -----------------------------------------------------------------
## Preparar os dados para Shiny
## 1. Calcular media deslizante para casos
sp_data_min$mediam_casos <- slider::slide_dbl(sp_data_min$new_confirmed, 
                                              mean, 
                                              .before = 7,
                                              .after = 0)


## Visualizar variaveis
sp_data_min %>% 
  select(date, mediam_casos, new_confirmed) %>% 
  pivot_longer(-date) %>% 
  ggplot(aes(x = date, y = value, color = name)) +
  geom_line()


## Dica: experimente diferentes valores do parametro .before; exemplos: 7, 14,
## 30. Descreva o que acontece com os grafico.


## 2. Preparar codigo do grafico para aplicativo Shiny 

grafico_linha <- 
  sp_data_min %>% 
  select(date, mediam_casos) %>% 
  ggplot(aes(x = date, y = mediam_casos)) +
  geom_line(size = 1) +
  theme_minimal() + 
  scale_y_continuous(labels = scales::comma)+
  scale_x_date(date_breaks = "1 month", 
               date_labels = "%m/%y") +
  xlab("") + ylab("")

ggplotly(grafico_linha)


# Glossario ---------------------------------------------------------------

# dplyr::glimpse - verifica a estrutura do banco de dados
# dplyr::view - usa interface para ver banco de dados
# dplyr::filter - seleciona casos usando operadores logicos
# dplyr::select - seleciona colunas do banco de dados
# summary - estatisticas de um dataframe ou vetor (coluna de um dataframe)