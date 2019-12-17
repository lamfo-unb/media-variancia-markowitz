---
title: "Markowitz - O problema da média variância"
author: "Neuremberg"
date: "16 de dezembro de 2019"
output: 
  html_document:
    keep_md: true
---



## Usando o R

Para ilustrar a discussão teórica feita até aqui, vamos usar o R para calcular uma fronteira eficiente para um conjunto de ativos.

###  Obtendo e processando dados

Inicialmente vamos carregar o pacote necessários:


```r
library(ggplot2)
library(magrittr)
library(quantmod)
library(xts)
library(tseries)
```

Caso não possua esses pacotes instalados você pode usar `install.packages('nome_pacote')` para instalá-los e depois carregue eles usando os comandos acima.

Usaremos o pacote `quantmod` e `xts` para obter os dados de interesse e tratar-los para o objetivo que desejamos. Assim, para o exercício, vamos obter o dados para as seguintes ativos:

* ITSA4 - Itaú SA Investimentos;
* VVAR3 - Via Varejo SA, controladora das empresas Casas Bahias e Ponto Frio;
* NATU3 - Natura;
* PETR4 - Petrobras;
* ABEV3 - Ambev SA.

Usaremos as funções do pacote `quantmod` para obter os preços diárias das ações entre outubro de 2016 e dezembro de 2019. Antes desse período, os dados do índice Bovespa apresenta muitos valores perdidos.


```r
# Definindo parâmetros
simbolos <- c("ITSA4.SA", "VVAR3.SA", "FNOR11.SA", "PETR4.SA", "BOVV11.SA")

startdate <-  '2016-10-27' # Sys.Date() - 730
enddate <- '2019-12-15' # Sys.Date()

# Fazendo download
ativos <- new.env()

getSymbols(Symbols = simbolos, env = ativos, src = 'yahoo',
           from = startdate, to = enddate, auto.assign = TRUE)
ativos <- as.list(ativos)
```

Se tudo tiver corrido corretamente os dados das ações foram baixados em carregados no *environment* `ativos` que posteriormente foi transformando em uma lista. Usaremos lista frequentemente nesse exercício, elas simplicam bastante a transformação de dados ao permitir que uma operação seja realizada sobre todos os seu elementos usando a função `lappy()`. 

Agora que temos os dados, vamos realizar um processamento de modo a obter o retorno mensais dessas séries, mas antes disso vamos que criar algumas funções para nos auxiliar nisso:


```r
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
```

Na lista `ativos` estão os dados de transações de cada ativo na bolsa em objetos `xts`. Em cada objeto `xts` estão guardados informações como o menor preço alcançado pela ação no dia, o maior preço alcançado, o preço do ativo na abertura do pregão, o preço de fechamento e outras informações. Para nosso exercício usaremos o preço de fechamento do ativos e partir deles calcularemos o retorno mensal.


```r
#Obtendo apenas os preços de fechamento
ativos <- lapply(X = ativos, FUN = get_preco_fechamento)

# calculando retornos mensais
retornos_men <- lapply(ativos, quantmod::monthlyReturn)

# Juntando ativos em um objeto xts
carteira <- list_to_xts(retornos_men)

# Transformando objeto xts em uma matriz e retirando dados perdidos
carteira <-  as.matrix(carteira)
carteira <- na.omit(carteira)
```

Aplicando a função `get_preco_fechamento()` por meio da função `lapply()` obtemos uma lista com o preço de fechamento de cada ativo, procedimento semelhante foi feito para calcular o retorno mensal de cada ativo. Ao final, a matriz `carteira` representa a carteira contendo os retornos dos ativos. 



<!-- ### Explorando as séries -->

<!-- * Visualizar evolução do preços -->
<!-- * Visualizar evolução dos retorno? -->

<!-- ### Carteira ótima -->

<!-- * Mostrar como usar a função `portfolio.optm()` do pacote `tseries` -->

### Calculando fronteira eficiente

O pacote `tseries` possui uma função chamada `portfolio.optim()`. Dado um conjunto de ativos e um retorno esperado para a carteira, ela calcula a carteira de menor variância. Vamos usar essa função para calcular a fronteira eficiente para o 5 ativos escolhidos.

Para facilitar esse trabalho vamos criar algumas funções:


```r
carteira_otima <- function(ativos, retorno_desejado, shorts = FALSE){
  ## Calcula carteira ótima
  
  s <- tseries::portfolio.optim(
    x = ativos,
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
  ## Obtém o retorno da carteira ótima
  ## res: list
  
  sapply(res, `[[`, i = 'retorno')
}

get_risco <- function(res){
  ## Obtém o risco da carteira ótima
  ## res: list
  
  sapply(res, `[[`, i = 'risco')
}
```

Vamos calcular o retorno esperados para o ativos e seus respectivos riscos e guardar tais informações em um `data.frame`. Após isso, vamos gerar um vetor de retornos desejados para as carteira ótimas a fim de gerar a fronteira eficiente.



```r
retornos_esperados <- apply(carteira, MARGIN = 2, mean)
riscos <- apply(carteira, MARGIN = 2, sd)

ativos <- data.frame(
  acao = names(retornos_esperados),
  risco = riscos,
  retorno = retornos_esperados,
  row.names = NULL
)

ativos
```

```
##    acao      risco     retorno
## 1 VVAR3 0.18831968 0.029281693
## 2 ABEV3 0.05423274 0.008092459
## 3 NATU3 0.09338029 0.011617998
## 4 PETR4 0.13950733 0.010620085
## 5 ITSA4 0.07567392 0.010554902
```

De modo geral, os ativos com maior retorno possuem o maior risco também. A Via Varejo *VVAR3* apresenta o maior retorno, 2,9%, e o maior risco, 18,8%; já a Ambev (*ABEV3*) apresenta o menor retorno, 0,8%, com o menor risco 5,4%. Note que estamos estimando o retorno esperado dos ativos como sendo o média do retorno histórico, entretanto, essa é uma abordagem ingênua que implica em uma série de problemas como: não há garantias do que o que ocorreu no passado ocorrerá no futuro; dependendo do períodos observado, a média do retorno histórico é diferente.

A função `carteira_otima()` toma como argumentos um conjunto de ativos e um retorno desejado e retorna a carteira com menor risco que possui o retorno igual ao retorno desejado. A fronteira eficiente é justamente o conjunto de carteiras com menor risco possível ao valor de retorno dado.

Portanto, para gerar a fronteira eficiente será necessário gerar esse conjunto de carteira ótimas. Para tanto, é necessário gerar um retorno desejado para cada carteira ótima. A seguir serão gerando 50 retornos desejados para gerar 50 carteiras ótimas e construir a fronteira eficiente.


```r
retorno_min <- 0.5*min(retornos_esperados)
retorno_max <- 1.5*max(retornos_esperados)

retornos_seq <- seq(retorno_min, retorno_max, length.out = 50)
```

O menor retorno esperado tem a metade do retorno do ativo com menor retorno e o maior tem a metade a mais que do retorno esperado do ativo de maior rendimento. Assim, foram gerados 50 retornos desejados igualmente espaçados, a seguir calculamos as carteiras da fronteira.


```r
# Calculando carteiras eficientes
fronteira <- lapply(
  X = retornos_seq,
  FUN = carteira_otima,
  ativos = carteira,
  shorts = TRUE
)

# Guardando dados de retorno e risco em um data.frame
dados_plot <- data.frame(
  retorno = get_retorno(fronteira),
  risco = get_risco(fronteira)
)
```

O `data.frame` `dados_plot` contêm o dados de risco e retorno das carteiras ótimas. Com eles é possível plotar a fronteira eficiente, como poder ser visto no gráfico a seguir:


```r
# Plotando fronteira eficiente
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
```

![](post-blog_files/figure-html/fronteira_plot-1.png)<!-- -->

Além da fronteira foi plotado os cinco ativos escolhidos. Com esse gráfico é fácil constatar que podemos obter o mesmo retorno de *VVAR3*, que é o ativo de maior retorno, com um risco menor que esse ativos apenas fazendo uma combinação. Ou alternativamente, podemos obter um retorno maior *VVAR3* com mesmo nível de risco dele. Tais resultados só são possíveis devido aos efeitos da diversificação.
