# Zetta Health Academy - Curso Dashboards com Shiny
# URL: https://github.com/zetta-academy/curso-dashboards-com-shiny
# Autor: Henrique Gomide, Ph.D., UFV


# 01. Tipos de dados ----
# Saiba quais os tipos de dados mais uteis para começar a programar em R
# Alguns tipos de dados foram omitidos, para uma lista extensa, consulte:
# https://www.tutorialspoint.com/r/r_data_types.htm 

## Numerico
a <- 1  

## Inteiro
b <- 1L 

## Caracter
caracter <- "Eu preciso aprender R"

## Logico (logical)
logico <- TRUE

## Vetor
vetor <- c(1, 2, 3)
vetor <- c(1:3)

## Matriz
matriz <- matrix(1:6, nrow = 2, ncol = 3)

## Lista
lista <- list("1", TRUE, 12L, minha_matriz)

## Fator
cores <- c("vermelho", "verde", "azul", "azul", "vermelho")
cores_factor <- factor(cores)


## Data frame (*tibble)
zetta_academy <- data.frame(nomes = c("Ana", "Gabriel", "Janilson"), 
                            cargo = c("Cientista de Dados", 
                                      "Cientista de Dados", 
                                      "Engenheiro de Dados"), 
                            qi = c(200, 200, 200))


# Verificar tipo/classe dos objetos
# class(), is.__()
is.numeric(a); is.integer(b); is.character(character) # 
is.logical(logico); is.matrix(minha_matriz)



## Exercícios:
## Qual o tipo de dados/classe de cada uma dos objetos abaixo:

obj <- 1
obj_2 <- list(1:20, rep("nome", 20))
obj_3 <- c(99:101)
obj_4 <- 20L
obj_5 <- TRUE
obj_6 <- data.frame(letters = c("a", "b"), numbers = c(1, 2))



## 02. Acessar elementos de matrizes e data.frames (tibbles) ---- 
## Observação: ao contrário da maioria das linguagens de programação
## R o primeiro índice é '1'.
matriz
matriz[, 1]      # Seleciona coluna 1
matriz[, c(1:2)] # Seleciona colunas 1 e 2

# Metodo 1
zetta_academy$qi # Recomendado

# Metodo 2
zetta_academy[, "qi"]


## 03. Converter variavel
# as.numeric(a); as.integer(b); ...
zetta_academy$nomes <- factor(dream_team$nomes)
names(zetta_academy)


# Glossario de funçoes ----

length(object) # Numero de elementos ou componentes
str(object)    # Estrutura de um objeto
class(object)  # Classe ou tipo de objeto
names(object)  # Nomes

c(object,object,...)       # Combinar objetos em vetores
cbind(object, object, ...) # Combinar objetos em colunas 
rbind(object, object, ...) # Combinar objetos em linhas 

object     # Imprime objeto 
ls()       # Lista objetos
rm(object) # Deleta objeto 


# Onde estudar ----
# https://www.codecademy.com/learn/learn-r


# Fontes -----
# https://www.statmethods.net/input/datatypes.html