---
title: "Fronteira eficiente"
author: "Alícia"
date: "8 de janeiro de 2020"
output: 
  html_document:
    keep_md: true
---



## Escolha de uma carteira

Não existe uma carteira que seja a melhor para todos investidores. Isso ocorre por que investidor têm preferências diferentes de combinação de risco e retorno, e tais preferências variam de acordo com fatores como idade, renda, estado civil e perspectivas futuras. Isto é, esses fatores podem tornar o agente mais ou menos avesso ao risco. Nesse contexto, a seleção de carteira consiste encontrar a carteira que melhor satisfaça a preferência do investidor dentre N carteiras diferentes.

### Princípio da dominância

A diversificação permite a criação de diversas combinações de risco e retorno, e nem todas as carteiras diversificadas são eficientes. É possível realizar a comparação entre carteiras ou ativos que apresentem o mesmo risco ou o mesmo retorno. Essa comparação pode mostrar aquele ativo ou carteira que é mais eficiente, comparativamente, que os demais.

Supondo que no mercado existam as ações $X$ e $Y$, essas ações possuem o mesmo retorno, mas riscos distintos - o risco da ação $Y$ é quatro vezes maior que o risco da ação $X$. Se o investidor avaliar somente o retorno esperado, será indiferente entre os dois ativos. Entretanto, se esse investidor for racional e analisar tanto o retorno como o risco, optará pela ação $X$, que está de acordo com o princípio da dominância. Esse princípio diz que: “um agente racional optará pelo investimento que lhe fornece o maior retorno esperado dado um nível de risco, ou o menor risco dado um nível de retorno”. Com isso é nítido que o ativo $X$ domina o ativo $Y$. 

No gráfico abaixo, note que a ação da Coca-Cola apresenta um risco de 25%, assim como a ação da Bore. Todavia, o retorno apresentado pela Coca-Cola é maior. Logo, um investidor racional, ao se deparar com as duas ações no mercado, irá optar por aquela com maior retorno. Apesar de ser dominante, nenhuma dessas duas ações está sobre a fronteira de eficiência, portanto existe uma combinação que pode trazer um maior retorno, com o mesmo risco.


<p>
  <img src='img-alicia/fronteira01.png'/>
  <br>
  <em>Fonte: Berk. Corporate Finance (2016)</em>
</p>

### Carteiras Eficientes

No exemplo anterior, o investidor escolheu a carteira composta com a ação da Coca Cola, uma vez que esta era dominante, dentre as opções que ele possui. Agora suponha que existe a carteira $A$, que assim como as ações apresentadas, possui uma volatilidade de 25%, mas a carteira $A$ representa a combinação de ativos com o maior retorno. Essa carteira será a carteira eficiente, uma vez que o investidor pode ficar numa melhor posição ao escolher $A$, invés das demais carteiras. 

<p>
  <img src='img-alicia/fronteira02.png'/>
  <br>
  <em>Fonte: Berk. Corporate Finance (2016)</em>
</p>


Note que na combinação $(0,1)$, em que a carteira é composta apenas por ativos da Coca-Cola, o risco é o mesmo que no ponto $(0.4, 0.6)$, em que 40% da carteira é composta por ações da Intel e 60% por ações da Coca-Cola, essa carteira apresenta o mesmo risco, entretanto o retorno é maior e ela está posicionada na fronteira de eficiência, isso significa que um investidor racional que está disposto a aceitar 25% de volatilidade, irá optar pela combinação $(0.4, 0.6)$. 

Uma carteira eficiente, portanto, pode ser definida como aquela que apresenta o maior retorno esperado dado um nível de risco. Ou, alternativamente, a carteira de menor risco dado um nível de retorno, isto é, a carteira de variância mínima. Essa é a carteira que um investidor racional irá escolher dentre as opções que foram apresentadas para ele.

Partindo da uma visão de carteira de variância mínima, o problema de selecionar uma carteira pode ser definido como um problema de otimização. Isto é, como encontrar a carteira de menor risco dado um retorno desejado. Matematicamente:

$$
\begin{equation}
\begin{split}
  \underset{w}{min} &\quad w'M w\\
  s.a &\\
  & wR = R_d \\
  & w\textbf{1} = 1
\end{split}
\end{equation}
$$

Sendo $w$ o vetor de pesos da carteira a ser encontrada, $M$ a matriz de covariância dos retornos, $R$ o vetor com dos retornos de cada ativo, $R_d$ o retorno desejado para a carteira ótima e $\textbf1$ um vetor de cuja todas as coordenadas são 1. O problema de otimização tem duas restrições: $wR=R_d$ e $w\textbf{1}=1$. A primeira restrição afirma que a carteira ótima deve ter o retorno igual ao retorno desejado, já segunda afirma que a soma das participações de cada ativo deve somar 1.

Resolver tal problema de minimização significa encontrar a participação de cada ativo na carteira, os pesos, tal que a carteira tenha o menor risco entre todas as carteiras com os mesmos ativos e retorno igual $R_d$. 

## Fronteira eficiente

Colocando todas as combinações de retorno e risco das possíveis carteiras de conjunto de ativos obtém-se o seguinte gráfico. Abaixo pode-se observar duas fronteiras eficientes, a fronteira eficiente de uma carteira contendo as 10 ativos, representada pela linha continua, a fronteira eficiente contendo 3 ativos, representada pela linha pontilhada.  O eixo $Y$ apresenta todos os retornos para cada combinação e o eixo $X$ apresenta o risco para cada combinação de ativos.

<p>
  <img src='img-alicia/fronteira03.png'/>
  <br>
  <em>Fonte: Berk. Corporate Finance (2016)</em>
</p>


Cada ponto no acima abaixo representa uma carteira. Dado um nível de risco desejado, o agente escolheria a carteira mais alta no gráfico e, dado um nível de retorno, o agente escolheria a carteira mais à esquerda no gráfico segundo o princípio da dominância. Essas escolhas são as carteiras eficientes e conjunto dessas carteiras é chamada de fronteira eficiente. No gráfico acima, as fronteiras eficientes são representadas pela cor vermelha.

Ademais, a fronteira eficiente tende a expandir à medida que se se aumenta a quantidade de ativos na carteira. Abaixo, na linha pontilhada, observa-se que uma fronteira formada apenas por três ativos é menor que a fronteira composta pelos 10 ativos, representada pela linha contínua. Essa expansão mostra que a diversificação pode ser benéfica.
