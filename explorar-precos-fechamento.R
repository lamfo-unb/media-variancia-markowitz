## == Visualizando preços de fechamento == ##

# Ambiente----------------------------------------------------------------------
rm(list = ls())
library(ggplot2)

# Dados-------------------------------------------------------------------------
precos <- read.csv2(file = 'dados/precos-fechamento.csv', stringsAsFactors = F)

# Funções-----------------------------------------------------------------------

precos_tidy <- function(data, periodo){
  ## Transforma os precos para o formato long
  
  cols <- base::setdiff(names(data), periodo)
  res <- tidyr::gather(data, key = 'ativo', value = 'precos', cols)
  
  res[, periodo] <- as.Date(as.character(res[[periodo]]))
  class(res) <- c('carteira', class(res))
  
  return(res)
  
}

plot_precos <- function(data, periodo, filter = NULL){
  ## Plota a evolução dos preços
  
  # Validação
  stopifnot('carteira' %in% class(data))
  
  # Quotando variável
  periodo <- dplyr::sym(periodo)
  
  # Filtrando ativos
  if(!is.null(filter)){
    data <- dplyr::filter(data, ativo %in% filter)
  }
  
  ggplot(data, aes(x = !!periodo, y = precos, color = ativo))+
    geom_line()+
    labs(
      x = '',
      y = 'Preço de fechamento',
      color = 'Ativo',
      title = 'Evolução dos ativos'
    )
}

# Explorando resultados---------------------------------------------------------

df_ <- precos_tidy(precos, 'periodo')

plot_precos(df_, 'periodo', filter = c('ABEV3', 'NATU3', 'PETR4'))


df_ %>% 
  ggplot(aes(x = precos))+
  facet_wrap(~ativo)+
  geom_histogram()

plot_precos(df_, 'periodo', c('ABEV3', 'ITSA4', 'PETR4', 'NATU3'))

m <- as.matrix(precos[, -1])
m <- na.omit(m)

cor(m)

