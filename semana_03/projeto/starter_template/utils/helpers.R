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