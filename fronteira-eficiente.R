
# Simulando a variância de carteiros com n pesos iguais
# Ambiente----------------------------------------------------------------------
rm(list = ls())
library(ggplot2)
library(magrittr)
library(tseries)
#library(quantmod)

# Carregando dados--------------------------------------------------------------
dados <- read.csv2('dados/retornos-mensais.csv')

carteira  <- dados[,-1]
carteira <- as.matrix(carteira)
carteira <- na.omit(carteira)


# Processando dados-------------------------------------------------------------

# Risco e retornos esperados dos ativos
retornos_esperados <- apply(carteira, MARGIN = 2, mean)
riscos <- apply(carteira, MARGIN = 2, sd)

ativos <- data.frame(
  acao = names(retornos_esperados),
  risco = riscos,
  retorno = retornos_esperados
)

# Retornos desejados
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

# primeira fronteira
fronteira <- lapply(
  X = retornos_seq,
  FUN = carteira_otima,
  ativos = carteira,
  shorts = TRUE
)

# Fronteira sem NATU3
nomes_ativ <- c("ABEV3", "PETR4", "ITSA4")

fronteira2 <- lapply(
  X = retornos_seq,
  FUN = carteira_otima,
  ativos = carteira[, nomes_ativ],
  shorts = TRUE
)

# Criando data frame
dados_plot <- data.frame(
  retorno = get_retorno(fronteira),
  risco = get_risco(fronteira),
  retorno2 = get_retorno(fronteira2),
  risco2 = get_risco(fronteira2)
)

# 
dados_plot %>% 
  ggplot(aes(x = retorno, y = risco, color = '#E7B800'))+
  geom_line(size = 1)+
  geom_line(size = 1, aes(y = risco2), color = '#5F9EA0')+
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

cor(carteira)
