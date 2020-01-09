
# Simulando a variância de carteiros com n pesos iguais
# Ambiente----------------------------------------------------------------------
rm(list = ls())
library(ggplot2)
library(magrittr)
library(tseries)
#library(quantmod)

# Funções-----------------------------------------------------------------------

read_data <- function(path_arquivo){
  ## path_arquivo: character(1)
  
  dados <- read.csv2(file = path_arquivo)
  carteira <- dados[,-1]
  carteira <- as.matrix(carteira)
  carteira <- na.omit(carteira)
  
  return(carteira)
}

retornos_esperados_ativos <- function(carteira){
  ## carteira: matrix
  
  apply(X = carteira, MARGIN = 2, FUN = mean)
}

riscos_ativos <- function(carteira){
  ## carteira: matrix
  
  apply(X = carteira, MARGIN = 2, FUN = stats::sd)
}

simular_retornos_desejados <- function(retornos_ativos, num_retornos = 50){
  ## retornos_ativos: numeric(n)
  
  retorno_min <- 0.5*min(retornos_ativos)
  retorno_max <- 1.5*max(retornos_ativos)
  
  seq(retorno_min, retorno_max, length.out = num_retornos)
}

carteira_otima <- function(retornos_ativos, retorno_desejado, shorts = FALSE){
  ## retornos_ativos: matrix, retorno_desejado: numeric(1), short: logic(1)
  
  s <- tseries::portfolio.optim(
    x = retornos_ativos,
    pm = retorno_desejado,
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
  ## res: list
  
  sapply(res, `[[`, i = 'retorno')
}

get_risco <- function(res){
  ## res: list
  
  sapply(res, `[[`, i = 'risco')
}

# Carregando dados--------------------------------------------------------------

carteira <- read_data('dados/retornos-mensais.csv')

# Processando dados-------------------------------------------------------------

# Risco e retornos esperados dos ativos
retornos_esperados <- retornos_esperados_ativos(carteira)
riscos <- riscos_ativos(carteira)

ativos <- data.frame(
  acao = names(retornos_esperados),
  risco = riscos,
  retorno = retornos_esperados
)

retornos_seq <- simular_retornos_desejados(retornos_esperados)

# Calculando fronteiras---------------------------------------------------------

# Fronteira com todos os ativos
fronteira <- lapply(
  X = retornos_seq,
  FUN = carteira_otima,
  retornos_ativos = carteira,
  shorts = TRUE
)

# Fronteira sem NATU3
nomes_ativ <- c("ABEV3", "PETR4", "ITSA4")
fronteira2 <- lapply(
  X = retornos_seq,
  FUN = carteira_otima,
  retornos_ativos = carteira[, nomes_ativ],
  shorts = TRUE
)

# Criando data frame
dados_plot <- data.frame(
  retorno = get_retorno(fronteira),
  risco = get_risco(fronteira),
  retorno2 = get_retorno(fronteira2),
  risco2 = get_risco(fronteira2)
)

# Gráficos----------------------------------------------------------------------

# Plotando as fronteiras eficientes 
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
