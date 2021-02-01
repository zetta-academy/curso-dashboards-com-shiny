# Zetta Health Academy - Curso Dashboards com Shiny
# URL: https://github.com/zetta-academy/curso-dashboards-com-shiny
# Autor: Henrique Gomide, Ph.D., UFV


# Funcoes -----------------------------------------------------------------
# Escrever sua primeira funçao 

# Imprime o nome de uma pessoa objeto (character)
minha_primeira_funcao <- function(nome = "Ana") {
  paste("Nome:", nome)
}


# Outros exemplos de funçoes para analise de dados
qis <- rnorm(1000, 100, 10)
summary(qis)
hist(qis)
boxplot(qis)


## Glossario ----
summary(object)                        # Retorna estatísticas básicas 
rnorm(n = 1E4, mean = 100, sd = 20)    # Cria uma distribuição normal
hist(object)                           # Plota um histograma 
boxplot(object)                        # Plota um diagrama de caixas e bigodes
