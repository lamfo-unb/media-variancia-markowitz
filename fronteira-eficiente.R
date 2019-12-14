
# Simulando a variância de carteiros com n pesos iguais
# Ambiente----------------------------------------------------------------------
rm(list = ls())
library(ggplot2)
library(magrittr)
library(tseries)
#library(quantmod)

# Carregando dados--------------------------------------------------------------
dados <- read.csv2('dados/retornos-diarios.csv')

ativos <- c("ABEV3", "ITSA4", "VALE3", "LAME4", "PETR4")
carteira  <- dados[, ativos]
carteira <- as.matrix(carteira)

# simbolos <- c("OIBR3.SA", "ABEV3.SA", " ITSA4.SA", " AZUL4.SA", " LAME4.SA",
#               "PETR3.SA")
# # Data inicio e fim
# startdate <-  Sys.Date() - 730
# enddate <- Sys.Date()
# 
# # Fazendo download
# env_simb <- new.env()
# getSymbols(Symbols = simbolos, env = env_simb, src = 'yahoo',
#            from = startdate, to = enddate)


# Processando dados-------------------------------------------------------------

retornos_esperados <- apply(carteira, MARGIN = 2, mean)
riscos <- apply(carteira, MARGIN = 2, sd)

ativos <- data.frame(
  acao = names(retornos_esperados),
  risco = riscos,
  retorno = retornos_esperados
)

retorno_min <- 0.5*min(retornos_esperados)
retorno_max <- 1.5*max(retornos_esperados)

retornos_seq <- seq(retorno_min, retorno_max, length.out = 50)

# Funções-----------------------------------------------------------------------

carteira_otima <- function(ativos, retorno_esperado, shorts = FALSE){
  
  s <- tseries::portfolio.optim(
    x = ativos,
    pm = retorno_esperado,
    shorts = shorts
  )
  
  res <- list(
    pesos = s[['pw']],
    retorno = s[['pm']],
    risco = s[['ps']]
  )
  
  return(res)
}


get_retorno <- function(res){
  
  sapply(res, `[[`, i = 'retorno')
}

get_risco <- function(res){
  
  sapply(res, `[[`, i = 'risco')
}


# Gráficos----------------------------------------------------------------------

fronteira <- lapply(
  X = retornos_seq,
  FUN = carteira_otima,
  ativos = carteira,
  shorts = TRUE
)

dados_plot <- data.frame(
  retorno = get_retorno(fronteira),
  risco = get_risco(fronteira)
)

dados_plot %>% 
  ggplot(aes(x = retorno, y = risco, color = '#E7B800'))+
  geom_point()+
  geom_line(size = 1)+
  geom_point(data = ativos, aes(x = retorno, y = risco, color = acao))+
  geom_text(data = ativos, aes(x = retorno, y = risco, label = acao, color = acao))+
  coord_flip()+
  labs(
    x = 'Retorno',
    y = 'Risco',
    title = 'Fronteira Eficiente',
    color = ''
  )+
  theme(legend.position = 'none')

