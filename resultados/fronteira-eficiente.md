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

### Obtendo dados

Inicialmente vamos carregar o pacote necessários:


```r
library(ggplot2)
library(magrittr)
library(quantmod)
library(xts)
library(tseries)
library(ggplot2)
```


Caso não possua esses pacotes instalados você pode usar `install.packages('nome_pacote')` para instalá-los e depois carregue eles usando os comandos acima. Além dos listados acima, será necessário que os pacotes `tidyr` e `dplyr` estejam instalados, entretanto, não é necessário carrega-los.

Usaremos o pacote `quantmod` e `xts` para obter os dados de interesse e tratar-los para o objetivo que desejamos. Assim, para o exercício, vamos obter o dados para as seguintes ativos:

* ITSA4 - Itaú SA Investimentos;
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

Se tudo tiver corrido corretamente os dados das ações foram baixados em carregados no *environment* `ativos` que posteriormente foi transformando em uma lista. Usaremos lista frequentemente nesse exercício, elas simplificam bastante a transformação de dados ao permitir que uma operação seja realizada sobre todos os seu elementos usando a função `lappy()`. 

### Processando os dados

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
```

Na lista `ativos` estão os dados de transações de cada ativo na bolsa em objetos `xts`. Em cada objeto `xts` estão guardados informações como o menor preço alcançado pela ação no dia, o maior preço alcançado, o preço do ativo na abertura do pregão, o preço de fechamento e outras informações. Para nosso exercício, usaremos o preços de fechamento dos ativos e partir deles calcularemos os retornos mensais, por isso, precisamos da função `get_preco_fechamento()`.

Já a função `list_to_xts()` recebe uma lista de objetos `xts` e a transforma em apenas um objeto `xts` e, por fim, a função `xts_to_data.frame` transforma um objeto `xts` em um `data.frame` mantendo o período dos dados como uma coluna do `data.frame` resultante. A seguir, vamos calcular os retornos mensais dos ativos:


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

### Explorando dados


Antes de prosseguirmos, vamos dar uma olhada na evolução dos preços de fechamento dos ativos. Para isso, usaremos as seguintes funções:


```r
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
```

Os dados dos ativos estão organizados de forma que cada coluna representa uma ativo diferente, nesse caso, diz-se que os dados estão num formato `wide`. Entretanto, o `ggplot2` foi construído para seguir uma lógica em que os dados estão no formato `long`, também chamado de `tidy`. Nesse caso, os dados sobre os ativos são organizados em duas colunas: uma conterá o nome do ativo e outra o preço da ação correspondente respeitando o período da observação. A função `precos_tidy()` faz justamente essa transformação.

A função `plot_precos()` toma o preços no formato `long` e cria um gráfico usando as funções do `ggplot2`. A seguir, plotamos a evolução dos preços de fechamento das ações e calcular as correlações entres o preços.


```r
precos_ <- precos_tidy(precos, 'periodo')

plot_precos(precos_, 'periodo')
```

<img src="fronteira-eficiente_files/figure-html/explorando_precos-1.png" style="display: block; margin: auto;" />

```r
# calculando correlação entre os preços
m <- as.matrix(precos[, -1])
m <- na.omit(m)
cor(m)
```

```
##            ABEV3      NATU3      PETR4     ITSA4
## ABEV3  1.0000000 -0.3243479 -0.2361517 0.4825303
## NATU3 -0.3243479  1.0000000  0.7464562 0.2422055
## PETR4 -0.2361517  0.7464562  1.0000000 0.5854143
## ITSA4  0.4825303  0.2422055  0.5854143 1.0000000
```

Na tabela acima, cada célula representa a correlação entre os preços do ativo da linha com o ativo da coluna. Chama a atenção a alta correlação existente entre preços das ações da Petrobras, *PETR4*, e  da Natura *NATU3*, que alcança o valor de 74,65%. Isso é um pouco curioso, já que essas empresas são de setores diferentes. Tal relação fica mais clara no gráfico a seguir:


```r
plot_precos(precos_, 'periodo', filter = c('PETR4', 'NATU3'))
```

<img src="fronteira-eficiente_files/figure-html/grafico_petr4_natu3-1.png" style="display: block; margin: auto;" />

Os dois ativos apresentam a tendência de queda entre 2013 e meados de 2016, após esse período passa a ter uma tendência ascendente. Talvez a mudança de governo ocorrido em 2016 tenha sido um motivo relevante para esse comportamento. A apesar de tudo isso, a mesma relação não se mantém quando calculamos a correlação entre os retornos. Quando fazemos esse cálculo, percebemos que a maior correlação ocorre entre *PETR4* e *ITSA4* como pode ser visto abaixo:


```r
# Correlação entre os retornos
cor(carteira)
```

```
##            ABEV3     NATU3      PETR4     ITSA4
## ABEV3 1.00000000 0.1066042 0.06589754 0.3241655
## NATU3 0.10660416 1.0000000 0.30124177 0.2985749
## PETR4 0.06589754 0.3012418 1.00000000 0.6686894
## ITSA4 0.32416546 0.2985749 0.66868936 1.0000000
```


### Calculando fronteira eficiente

O pacote `tseries` possui uma função chamada `portfolio.optim()`. Dado um conjunto de ativos e um retorno esperado para a carteira, ela calcula a carteira de menor variância e retorna uma lista com os pesos de cada ativo na carteira ótima, o risco e o retorno esperado. Vamos usar essa função para calcular a fronteira eficiente para o 4 ativos escolhidos.

Para facilitar esse trabalho, vamos criar algumas funções:


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
##    acao      risco    retorno
## 1 ABEV3 0.05395006 0.00815532
## 2 NATU3 0.09332690 0.01254119
## 3 PETR4 0.13895500 0.01134941
## 4 ITSA4 0.07556379 0.01122900
```

Note que estamos estimando o retorno esperado dos ativos como sendo o média do retorno histórico, entretanto, essa é uma abordagem ingênua que implica em uma série de problemas como: não há garantias do que o que ocorreu no passado ocorrerá no futuro; dependendo do períodos observado, a média do retorno histórico é diferente.

As ações da *ABEV3* a presentaram o menor retorno esperado, 0,8%, e o menor risco 5,4%. Já *NATU3* apresenta o maior retorno esperado, 1,25%, entretanto, não apresenta o maior risco. Nesse caso, a máxima de que um maior risco implica em uma maior retorno nem sempre é válida quando estamos avaliando ativos individuais. Esse fato pode ser explicado pela distinção entre risco diversificável - indissiocrático - e não diversificável - risco sistêmico.

Para calcular a fronteira usaremos a função `carteira_otima()`. Ela toma como argumentos um conjunto de ativos e um retorno desejado e retorna a carteira com menor risco que possui o retorno igual ao retorno desejado. A fronteira eficiente é justamente o conjunto de carteiras com menor risco possível ao valor de retorno dado.

Portanto, para gerar a fronteira eficiente será necessário gerar esse conjunto de carteira ótimas. Para tanto, é necessário gerar um retorno desejado para cada carteira ótima. A seguir serão gerando 50 retornos desejados para gerar 50 carteiras ótimas e construir a fronteira eficiente.


```r
retorno_min <- 0.5*min(retornos_esperados)
retorno_max <- 1.5*max(retornos_esperados)

retornos_seq <- seq(retorno_min, retorno_max, length.out = 50)
```

O menor retorno esperado tem a metade do retorno do ativo com menor retorno e o maior tem a metade a mais que do retorno esperado do ativo de maior rendimento. Assim, foram gerados 50 retornos desejados igualmente espaçados, a seguir calculamos as carteiras da fronteira.


```r
# Primeira com todos os ativos
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
```

O `data.frame` `dados_plot` contêm o dados de risco e retorno das carteiras ótimas. Com eles é possível plotar a fronteira eficiente, como poder ser visto no gráfico a seguir:


```r
# Plotando fronteira eficiente
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
```

<img src="fronteira-eficiente_files/figure-html/fronteira_plot-1.png" style="display: block; margin: auto;" />

A fronteira mais escura foi construída a partir dos ativos *ABEV3*, *PETR4* e *ITSA4*, já a fronteira laranja foi construída com os mesmo ativos mais o ativo *NATU3*. A nova fronteira ficou mais à esquerda que a anterior, portanto, é possível obter o mesmo retorno com uma risco menor por meio dessa nova nova fronteira eficiente. Tais resultados são possíveis devido aos efeitos da diversificação: ao aumentar a quantidade de ativos na carteira, o risco cai mais que os retornos ponderados dos ativos.

