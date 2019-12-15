# == download e preparação dos dados == #

# Ambiente----------------------------------------------------------------------
rm(list = ls())
library(quantmod)
library(xts)

# Download----------------------------------------------------------------------

# Definindo parâmetros
simbolos <- c("ITSA4.SA", "VVAR3.SA", "FNOR11.SA", "PETR4.SA", "BOVV11.SA")

startdate <-  '2016-10-27' # Sys.Date() - 730
enddate <- '2019-12-15' # Sys.Date()

# Fazendo download
ativos <- new.env()

getSymbols(Symbols = simbolos, env = ativos, src = 'yahoo',
           from = startdate, to = enddate, auto.assign = TRUE)
ativos <- as.list(ativos)

# Funções-----------------------------------------------------------------------

get_preco_fechamento <- function(x){
  ## Obtem preço de fechamento
  
  x[, base::grepl(pattern = '\\.Close$', x = dimnames(x)[[2]])]
  
}

list_to_xts <- function(list_xts){
  ## Transforma uma lista de objetos xts em um objeto xts
  
  nomes <- names(list_xts)
  res <- do.call(cbind.xts, list_xts)
  dimnames(res)[[2]] <- nomes
  
  return(res)
}

xts_to_data.frame <- function(x){
  ## Transforma objeto xts em data.frame
  
  df <- as.data.frame(x)
  df <- data.frame(
    periodo = row.names(df),
    df
  )
  
  row.names(df) <- NULL
  
  return(df)
  
}

retornos_esperados <- function(x, na.rm = FALSE){
  ## Estima retorno esperado de cada ativo
  
  stopifnot(is.matrix(x))
  
  apply(X = x, MARGIN = 2, mean, na.rm = na.rm)
  
}

# Processamento-----------------------------------------------------------------

# Obtendo apenas os preços de fechamento
ativos <- lapply(X = ativos, FUN = get_preco_fechamento)

# calculando retornos mensais
retornos_men <- lapply(ativos, quantmod::monthlyReturn, USE.NAMES = TRUE)

# Juntando ativos em um objeto xts
retornos_mensais <- list_to_xts(retornos_men)

# Estimando retorno esperado
teste <- as.matrix(retornos_mensais)
retornos_esperados(teste, na.rm = TRUE)

# Calculando matriz de covariância
teste <- na.omit(teste)
cov(teste)

# Juntando em um objeto xts
retornos <- xts_to_data.frame(retornos_mensais)
write.csv2(retornos, file = 'dados/retornos-mensais.csv', na = '',
           row.names = FALSE)
