---
title: "Risco e diversificação"
author: "Sarah"
date: "8 de janeiro de 2020"
output: 
  html_document:
    keep_md: true
---

<!-- ```{r setup, include=FALSE} -->
<!-- knitr::opts_chunk$set(echo = TRUE) -->
<!-- ``` -->

### Tipos de Risco

O risco, pode ser dividido em dois tipos: idiossincrático, também conhecido como risco não sistemático, e sistemático.

O risco idiossincrático está associado a variância específica do ativo mensurado, é uma característica única do ativo. No caso, por exemplo, de um seguro para casas, assaltos são riscos idiossincráticos, pois dependendo da vizinhança, segurança interna ou até mesmo da aparência, cada casa possui uma chance de ser assaltada ou não, e, não necessariamente, caso uma casa seja assaltada as outras serão também. Esse risco não será tão relevante para o modelo apresentado mais a frente, isso ficará mais claro a seguir.

Já o risco sistemático é aquele ao qual estão sujeitos todos os ativos negociados, isso pode incluir não só ativos que estão listados em bolsas, como também os negociados em mercados de balcão, moedas, etc. Voltando ao exemplo do seguro, o risco sistemático seria a chance de haver um desastre natural que atingisse todas as casas, independentemente de qualquer característica individual de cada casa. 

### Diversificação

Para entender a diversificação é preciso que esteja clara a distinção entre os tipos de risco. O risco não sistemático então é aquele que afetará somente um ou alguns ativos. No caso das ações de uma empresa seu risco específico está relacionado às decisões de investimentos tomadas pelo gestor, investimentos com $VPL$ positivo impactam positivamente o valor de uma ação, porém a ocorrência de greves ou fraudes terá impacto negativo.

Já como risco sistemático podemos citar eventos macroeconômicos como a inflação que afeta oferta e demanda de todo um país, é em diferentes níveis para cada tipo de bem, serviço ou setor, mas de maneira geral toda a economia é afetada.

Dadas tais diferenças é possível perceber que em uma carteira com vários ativos, apesar de todos estarem sujeitos ao risco sistemático, cada um deles terá também seu risco específico e enquanto alguns sofrem valorização outros terão queda no preço, e assim é feita a compensação de ganhos e perdas, por isso é importante que uma carteira possua um bom número de ativos e que estes sejam escolhidos de maneira que os riscos não sistemáticos tenham pouca relação entre si.

Podemos voltar então ao exemplo de uma companhia de seguros para exemplificar como funciona a diversificação. Digamos que existem apenas dois riscos envolvendo as casas asseguradas de uma cidade: desastres naturais e roubos. Não é possível a seguradora evitar que ocorram desastres ou que as casas não sejam atingidas por eles, esse risco também pode ser maior ou menor dependendo da época do ano. Porém, os roubos não atingem todas as casas ao mesmo tempo e as ocorrências podem ser maiores a depender de bairro, aparência das casas, etc. Nesse caso, seria prudente que a seguradora tivesse imóveis assegurados dos mais diferentes tipos e também em lugares diferentes. O risco de desastres não é eliminado por diversificação, porém o risco de perdas devido a assaltos diminui quanto maior for a diversificação.

A correlação é a medida da estatística utilizada para medir se dois ativos possuem flutuações muito ou pouco parecidas, é, no cálculo, o que fará o risco aumentar ou diminuir ao montar uma carteira de investimentos. Pode variar de -1, que é quando os ativos possuem correlação perfeitamente negativa, a 1, ativos com correlação perfeitamente positiva.  Quanto mais próxima de 1, maior o risco da carteira, pois neste caso, os ativos se comportam de maneira muito parecida, e quanto mais próxima de -1, menor o desvio padrão da carteira. 
