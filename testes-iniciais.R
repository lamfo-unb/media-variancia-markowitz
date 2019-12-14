
# Simulando a variância de carteiros com n pesos iguais

sd=0.50; cv=0.05; m=100
sd_p = matrix(0,m,1) # Alocando memória para receber os pesos

for (j in 1:m) {
  cv_mat = matrix(1,j,j)*cv # Inicializando matriz de covariância
  diag(cv_mat) = sd^2       # Modificando diagonal da matriz
  w = matrix(1/j,j,1)       # Definindo pesos das ações na carteira
  sd_p[j] = sqrt(t(w) %*% cv_mat %*% w) # Calculando risco das carteiras
}


simular_carteira <- function(n, sd, cv){
  
  # Matriz de covariancia
  cv_mat = matrix(1, n, n)*cv
  diag(cv_mat) = sd^2
  
  # Pesos
  w = matrix(1/n, n, 1)
  
  # Variância da carteira
  sd_p <- sqrt(t(w) %*% cv_mat %*% w)
  
  return(sd_p[1,1])
}


saida <- vapply(1:100, FUN = simular_carteira, sd = sd, cv = cv, FUN.VALUE = double(1))

simular_carteira(4, sd = sd, cv = cv)

plot(sd_p,type="l",col="blue")

