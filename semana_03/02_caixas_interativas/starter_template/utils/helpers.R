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
                                 sigma = 3.4, 
                                 n_criteria_days = 15,
                                 pred_n_days = 10) {
  # Estimates the growth from a given city or state in Brazil
  # using the estimation of Instantaneous effective 
  # reproduction number.
  # References:
  #     https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3816335/
  #     https://doi.org/10.1016/j.epidem.2019.100356
  #     SI Updated: https://wwwnc.cdc.gov/eid/article/26/6/20-0357_article
  # Function parameters:
  #     data   - data.frame
  #     mu     - mean serial interval  
  #     sigma  - sd of serial interval 
  #     n_criteria_days - number of days after the incidence peak
  #                       to consider a given region/city is on decay phase
  #     pre_n_days - number of days to be predicted
  
  data_incidence_function_data <- 
    data %>%
    mutate(new_confirmed = ifelse(new_confirmed < 0, 0, new_confirmed)) %>% 
    dplyr::select(date, new_confirmed) %>%
    uncount(new_confirmed)
  
  set.seed(42)
  param     <- gamma_mucv2shapescale(mu, sigma/mu)
  w         <- distcrete('gamma', interval = 1, shape = param$shape, scale = param$scale, w = 0)
  
  data_incidence_function_data$date <- as.Date(data_incidence_function_data$date)
  seq_dates <- data.frame(date = seq.Date(from = as.Date(min(data_incidence_function_data$date)), 
                                          to = as.Date(max(data_incidence_function_data$date)),
                                          by = 'day'))
  
  data_incidence_function_data <- left_join(seq_dates, data_incidence_function_data)
  data_incidence_object        <- incidence(data_incidence_function_data$date)
  data_incidence_peak          <- find_peak(data_incidence_object)
  
  # Select whether a given series of cases is on decay or growth phases.
  criteria <- as.integer(as.Date(max(data$date)) - data_incidence_peak) < n_criteria_days
  
  if (criteria) {
    data_incidence_fit <- incidence::fit(data_incidence_object)  
    growth_R0 <- lm2R0_sample(data_incidence_fit$model, w)
  } else {
    data_incidence_fit <- incidence::fit(data_incidence_object, split = data_incidence_peak)  
    growth_R0 <- lm2R0_sample(data_incidence_fit$after$model, w)
  }
  
  date_range <- 1:length(get_dates(data_incidence_object))
    
  test_pred_growth <- project(data_incidence_object[date_range], 
                              R = growth_R0,
                              si = w, 
                              n_days = pred_n_days + 8,
                              n_sim = 100)
  
  list_of_parameters <- list(test_pred_growth, growth_R0, data_incidence_object, 
                             data_incidence_peak)
  
  list_of_parameters
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