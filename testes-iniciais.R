# == Implementação à mão == #

sd=0.50; cv=0.05; m=100
sd_p = matrix(0,m,1) # Alocando memória para receber os pesos


simular_carteira <- function(n, sd, cv){
  
  # Matriz de covariancia
  cv_mat = matrix(1, n, n)*cv
  diag(cv_mat) = sd^2
  
  # Calculando os pesos
  w = matrix(1/n, n, 1)
  
  # Variância da carteira
  sd_p <- sqrt(t(w) %*% cv_mat %*% w)
  
  return(sd_p[1,1])
}

min(retornos_esperados)
max(retornos_esperados)
saida <- vapply(1:100, FUN = simular_carteira, sd = sd, cv = cv, FUN.VALUE = double(1))

simular_carteira(4, sd = sd, cv = cv)

plot(sd_p,type="l",col="blue")


markowitz <-  function(mu,cv,Er) {
  n = length(mu)
  wuns = matrix(1,n,1)
  A = t(wuns) %*% solve(cv) %*% mu
  B = t(mu) %*% solve(cv) %*% mu
  C = t(wuns) %*% solve(cv) %*% wuns
  D = B*C - A^2
  lam = (C*Er-A)/D
  gam = (B-A*Er)/D
  wts = lam[1]*(solve(cv) %*% mu) + gam[1]*(solve(cv) %*% wuns)
  g = (B[1]*(solve(cv) %*% wuns) - A[1]*(solve(cv) %*% mu))/D[1]
  h = (C[1]*(solve(cv) %*% mu) - A[1]*(solve(cv) %*% wuns))/D[1]
  wts = g + h*Er
  
  return(wts)
}

markowitz(
  mu = retornos_esperados,
  cv = matriz_cova,
  Er = .001
)