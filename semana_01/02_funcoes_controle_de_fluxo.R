# Zetta Health Academy - Curso Dashboards com Shiny
# URL: https://github.com/zetta-academy/curso-dashboards-com-shiny
# Autora: Ana Flávia Souza, UFV

# Execute a linha abaixo para importar a biblioteca
library(rmarkdown)

# Funções -----------------------------------------------------------------
# Imprime o nome de uma pessoa objeto (character)
# Para construir uma função, utiliza-se "function" e defini-se os parâmetros
# dentro dos parênteses.
# Para ler mais sobre funções, veja
# https://www.tutorialspoint.com/r/r_functions.htm

minha_primeira_funcao <- function(nome = "Ana") {
  paste("Nome:", nome)
}

# Chame a função acima, trocando o input pelo seu nome.
# Dica: para chamar a função, use minha_primeira_funcao().



# EXERCÍCIO 1: Crie uma função que adicione 10 unidades a um valor inputado.
# Dica: lembre-se das {} para indentar o código da função.
soma_dez <- function(numero) {
  numero + 10
}

soma_dez(0)



# Outros exemplos de funções para análise de dados
# Rode as linhas abaixo, uma a uma.
qis <- rnorm(n = 1000, mean =  100, sd = 10)
summary(qis)
hist(qis)
boxplot(qis)


# Controle de fluxo -------------------------------------------------------
# Com os controles de fluxo if, else e else if, podemos criar condições para
# rodar nosso código.

valor <- FALSE       # atribua TRUE ou FALSE para a variável "valor"


if (valor == TRUE) {
  print("Uma verdade: Shiny é uma excelente ferramenta.")
} else {
  print("Uma mentira: aprender Shiny é difícil.")
}


# A função a seguir faz parte do projeto final deste curso. Observe sua
# estrutura e tente entender qual é a sua funcionalidade.
colorize_infovalue <- function(value){
  if (value > 1.2) {
    "danger"
  } else if (value > 0.9) {
    "primary"
  } else {
    "light"
  }
}


# DICA: Em controle de fluxo, os operadores lógicos e relacionais são bastante
# úteis. Para saber mais sobre esses operadores em R, rode a linha abaixo.
# Antes de rodar, lembre-se apenas de definir a pasta "semana00_introdução_ao_r"
# como diretório de trabalho.
# Um arquivo html será criado nesse mesmo diretório e você poderá abri-lo no
# seu browser.
rmarkdown::render("tipos_de_operadores.Rmd")




# EXERCÍCIO 2: Complete o código da função para que: a) se valor_01 for menor
# que o valor_02, a função printe "O valor_01 é o maior"; b) qualquer outro
# resultado, a função printe "O Valor_01 não é o maior". Depois, chame a função,
# atribuindo valores ao valor_01 e ao valor_02.

comparar_valores <- function(valor_01, valor_02) {
  # Seu código aqui

}

# Chamar a função
comparar_valores()




## Glossário ----
summary(object)                        # Retorna estatísticas básicas
rnorm(n = 1E4, mean = 100, sd = 20)    # Cria uma distribuição normal
hist(object)                           # Plota um histograma
boxplot(object)                        # Plota um diagrama de caixas e bigodes
paste(character1, character2)          # Concatena duas ou mais strings
print(object)                          # Printa um objeto