# Funções adicionais para executar o aplicativo Shiny

library(tidyverse)  # Data manipulation
library(slider)     # Rolling average

library(distcrete)
library(epitrix)
library(incidence)
library(projections)
library(EpiEstim)

# Preparar os dados
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


# Baixar os dados de COVID do Brasil IO
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
  #     SI: https://www.nejm.org/doi/full/10.1056/NEJMoa2001316
  #     SI Updated: https://wwwnc.cdc.gov/eid/article/26/6/20-0357_article
  # Function parameters:
  #     data   - data frame from wcota/covid19br repo
  #     mu     - mean serial interval  
  #     sigma  - sd of serial interval 
  #     n_criteria_days - number of days after the incidence peak
  #                       to consider a given region/city is on decay phase
  #     pre_n_days - number of days to be predicted
  
  data_incidence_function_data <- 
    data %>%
    dplyr::select(date, confirmed_n) %>%
    uncount(confirmed_n)
  
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
  
  return(list_of_parameters)
}


# Prever novos casos de COVID-19
predict_covid19_cases <- function(data_original) {
  
  data <- data_original
  data$date_f <- as.Date(data$DataBanco, format = '%Y-%m-%d')
  data$CasosNovos <- as.numeric(data$CasosNovos)
  
  data <- 
    data %>% 
    dplyr::select(UF, date_f, CasosNovos) %>% 
    ungroup()
  names(data) <- c("state", "date", "newCases")
  
  
  state_vector <- unique(data$state)
  list_of_results <- list()
  
  for (i in 1:length(state_vector)) {
    
    tryCatch({
      temp <- get_growth_estimates(data, state_vector[i], pred_n_days = 22)
      
      test_pred_growth      <- temp[[1]]
      growth_R0             <- temp[[2]]
      data_incidence_object <- temp[[3]]
      
      test_pred_growth_median_counts <- test_pred_growth %>% 
        as.data.frame() %>% 
        pivot_longer(-dates, names_to = "simulation", values_to = "incidence") %>% 
        group_by(dates) %>% summarise(incident_cases = as.integer(median(incidence))) %>% 
        mutate(data_type = "Projetado")
      
      final_df <- 
        test_pred_growth_median_counts %>% 
        bind_rows(tibble(dates = get_dates(data_incidence_object), 
                         incident_cases = get_counts(data_incidence_object), data_type = "observado")) 

      
      list_of_results[[i]] <- data.frame(state_vector = state_vector[i], 
                                         r_effective_median = median(growth_R0), 
                                         final_df)
      
    }, 
    error = function(e){})
  }
  
  df <- bind_rows(list_of_results)
  df <- 
    df %>% 
    filter(dates >= Sys.Date() & 
             dates <= Sys.Date() + 16)
  
  return(df)
}


# Estimar numero de reproducao instantaneo
estimate_effective_R <- function(data) {
  # Estimates R effective in state level and Brazil
  # of COVID-19 Cases.
  # Data must follow the following convention:
  #   colnames: "UF", "DataBanco", "CasosNovos" 
  list_of_r_estimates <- list()
  
  # Preprocess data
  data$date_f <- as.Date(data$DataBanco, format = '%Y-%m-%d')
  data$CasosNovos <- as.numeric(data$CasosNovos)
  
  data$CasosNovos <- ifelse(data$CasosNovos <= 0, 0, data$CasosNovos)
  
  data <- 
    data %>% 
    dplyr::select(UF, date_f, CasosNovos) %>% 
    ungroup()
  names(data) <- c("state", "date", "newCases")
  
  br <- 
    data %>% 
    group_by(date) %>%  
    summarize(newCases = sum(newCases))
  br$state <- "BR"
  br <- br[, c(3, 1, 2)]
  data <- rbind(data, br)
  
  state_vector <- unique(data$state)
  
  for (i in 1:length(state_vector)) {
    
    data_incidence_function_data <- 
      data %>%
      dplyr::filter(`state` == state_vector[i]) %>%
      dplyr::select(`date`, `newCases`) %>%
      uncount(newCases)
    
    data_incidence_function_data$date <- as.Date(data_incidence_function_data$date)
    seq_dates <- data.frame(date = seq.Date(from = as.Date(min(data_incidence_function_data$date)), 
                                            to = as.Date(max(data_incidence_function_data$date)),
                                            by = 'day'))
    
    data_incidence_function_data <- left_join(seq_dates, data_incidence_function_data, by = "date")
    data_incidence_object        <- incidence(data_incidence_function_data$date)
    
    data_res_parametric_si <-  estimate_R(data_incidence_object, 
                                          method = "parametric_si",
                                          config = make_config(
                                            list(mean_si = 7.5, std_si = 3.4)
                                          ))
    # Combine R effective and dates
    data_r_effective <- data_res_parametric_si$R
    data_dates <- data.frame(date = data_incidence_object$dates[8:length(data_incidence_object$dates)])
    
    # Create data frame
    data_r_effective <- bind_cols(data_dates, data_r_effective)
    data_r_effective$UF <- state_vector[i]
    
    list_of_r_estimates[[i]] <- data_r_effective
    
  }
  
  data_r_effective <- bind_rows(list_of_r_estimates)
  
  return(data_r_effective)
}


# Colorir infovalues
colorize_infovalue <- function(value){
  if (value > 1.2) {
    return("danger")
  } else if (value > 0.9) {
    return("primary")
  } else {
    return("light")
  }
}

