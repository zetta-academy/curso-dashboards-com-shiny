#########################################################################
# Zetta Health Academy - Curso Dashboards com Shiny
# R Efetivo 
# Autor: Henrique Gomide, Ph.D., Zetta R&D, UFV
#########################################################################


# Objetivos ---------------------------------------------------------------
# 1. Criar intuição sobre o indicador R Efetivo, usando para monitoramento
#    da COVID-19. 

# Carregar pacotes e bibliotecas ------------------------------------------

library(tidyverse)
library(distcrete)
library(epitrix)
library(incidence)
library(projections)
library(EpiEstim)
library(plotly)

# A Análise abaixo é baseada no conjunto de pacote produzido pelo
# consórcio de pesquisadores em epidemiologia RECON (https://www.repidemicsconsortium.org/).

# Para saber mais, leia:
# Cori, A., Ferguson, N.M., Fraser, C., Cauchemez, S., 2013. A New Framework and Software to Estimate Time-Varying Reproduction Numbers During Epidemics. Am J Epidemiol 178, 1505–1512. https://doi.org/10.1093/aje/kwt133


# Parâmetros usados para estimar Número de Reprodução
# [Média e DP do intervalo serial, tempo estimado em dias para o contágio de uma
# pessoa doente]
mu <- 7.5
sigma <- 3.4
pred_n_days <- 10

# Carregar banco de dados -------------------------------------------------
# Baixar dados da API Brasil IO
# OBS: Pode demorar um pouco dependendo de sua conexao
if (!"covid19" %in% ls()){
  covid19 <- fetch_data_brasil_io(use_cached_data = TRUE)   
}


# Análise exploratória ----------------------------------------------------
# Encontrar código de SP, cidade
View(covid19[sample(nrow(covid19), 10E4, replace = FALSE), 
                   c("city", "city_ibge_code")])


# Código de Salvador; São Paulo e RJ
cidade_salvador <- 2927408
cidade_sp <- 3550308
cidade_rj <- 3304557 
cidades <- c(cidade_salvador, cidade_sp, cidade_rj)


# Transformar dados no formato incidência
data_incidence_function_data <- 
  covid19 %>%
  filter(city_ibge_code == cidade_sp) %>% 
  select(date, new_deaths) %>% 
  uncount(new_deaths)
  
data_incidence_object <- incidence(data_incidence_function_data$date)


# Estimar R Efetivo usando o Pacote EpiEstim
t_start <- seq(2, nrow(data_incidence_object$counts) - 8)
t_end <- t_start + 8
effective_r <- estimate_R(data_incidence_object, method = "parametric_si", 
                          config = make_config(list(mean_si = mu, std_si = sigma,
                                                    t_start = t_start, 
                                                    t_end = t_end)))

# Criar gráfico plotly do R Efetivo
r_effective_chart <- 
effective_r$R %>% 
  ggplot(aes(x = data_incidence_object$dates[10:length(data_incidence_object$dates)], 
             y = `Mean(R)`)) + 
  geom_ribbon(aes(ymin = `Mean(R)` - 2*`Std(R)`,
                  ymax = `Mean(R)` + 2*`Std(R)`), 
              fill = "grey60") + 
  geom_line(size = 1.2) + 
  scale_y_sqrt() + 
  geom_hline(yintercept = 1, linetype = "dashed", color = "navy") +
  xlab("") + ylab("") +
  labs(title = "Estimativa do Número de Reprodução Efetivo São Paulo") +
  theme_minimal(base_size = 18)
ggplotly(r_effective_chart)


