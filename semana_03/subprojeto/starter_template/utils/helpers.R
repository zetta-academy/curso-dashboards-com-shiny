# Nao e necessario editar este arquivo
# Hackeie com cuidado 


# Retorna o codigo de uma cidade (integer)
#     Parametros: city_option (character)
#     Exemplo: get_city_code("São Paulo - SP (3550308)")
get_city_code <- function(city_option){
    city_code <- as.integer(str_extract(city_option, "\\d+"))
    city_code
}


# Baixar os dados de COVID do Brasil IO
fetch_data_brasil_io <- function(use_cached_data = TRUE) {
  # Baixar dados da API do COVID-19 Brasil
  # Fonte: https://github.com/turicas/covid19-br
  # Parametros: use_cached_data usa os dados baixados no seu computador
  #             caso seja a primeira vez que executa a funcao, ela baixara
  #             os dados. Use use_cached_data = FALSE para atualizar seu banco
  #             de dados
  
  if (!any(grepl("covid19.gz", list.files("data/")))) {
    dir.create("data", showWarnings = FALSE)
    covid19 <- read_csv("https://data.brasil.io/dataset/covid19/caso_full.csv.gz") 
    write_csv(covid19, 
              "data/covid19.gz")
    covid19
    
  } else {
    if (use_cached_data) {
      covid19 <- read_csv("data/covid19.gz") 
      covid19
    } else {
      covid19 <- read_csv("https://data.brasil.io/dataset/covid19/caso_full.csv.gz") 
      write_csv(covid19, 
                "data/covid19.gz")
      covid19
    }
  }
}


# Estima o R Efetivo para uma data série histórica
# 
# Prever novos casos de COVID-19
get_growth_estimates <- function(data, 
                                 mu = 7.95, 
                                 sigma = 3.4) {
  # Estimates the growth from a given city or state in Brazil
  # using the estimation of Instantaneous effective 
  # reproduction number.
  # References:
  #     https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3816335/
  #     https://doi.org/10.1016/j.epidem.2019.100356
  #     SI Updated: https://wwwnc.cdc.gov/eid/article/26/6/20-0357_article
  # Function parameters:
  #     data   - data.frame
  
  data_incidence_function_data <- 
    data %>% 
    select(date, new_confirmed) %>% 
    uncount(new_confirmed)
  
  
  data_incidence_object <- incidence(data_incidence_function_data$date)
  
  t_start <- seq(2, nrow(data_incidence_object$counts) - 8)
  t_end <- t_start + 8
  effective_r <- estimate_R(data_incidence_object, method = "parametric_si", 
                          config = make_config(list(mean_si = mu, std_si = sigma,
                                                    t_start = t_start, 
                                                    t_end = t_end)))
  
  effective_r
  
}

# Retorna a cor da caixa de acordo (character) com valor numerico (R efetivo)
colorize_info <- function(value) {
  if (value > 1.2) {
    "red"
  } else if (value > 0.9) {
    "yellow"
  } else {
    "blue"
  }
}
