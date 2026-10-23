suppressMessages(library(evbsreg)); options(warn=-1)
set.seed(20260718)
## Simulacao com NUMERO CRESCENTE de covariaveis:
## avalia (a) vies/EQM de gamma, (b) cobertura, (c) o diagnostico ainda
## detecta uma observacao contaminada quando p cresce?
sim <- function(p, n, R=300, gama=-0.2, alpha=0.5, contam=TRUE){
  det<-0; gh<-numeric(0); cov<-0; ok<-0
  for(r in 1:R){
    X <- cbind(1, matrix(rnorm(n*(p-1))/2, n, p-1))
    beta <- c(1, rep(0.3, p-1))
    eta <- as.vector(X%*%beta)
    y <- revbs(n, alpha=alpha, beta=exp(eta), gama=gama)
    if(any(!is.finite(y))||any(y<=0)) next
    j0 <- NA
    if(contam){ j0 <- sample(n,1); y[j0] <- y[j0]*3 }   # observacao contaminada
    f <- try(evbsreg.fit(X,y), silent=TRUE); if(inherits(f,"try-error")) next
    if(!is.finite(f$gamahat)||abs(f$gamahat)>2) next
    ok <- ok+1; gh<-c(gh,f$gamahat)
    ci <- f$gamahat + c(-1,1)*1.96*f$stderrorgama
    if(gama>=ci[1] && gama<=ci[2]) cov<-cov+1
    if(contam){
      B <- try(colMeans(cnc_diagnostics(f)$Bj), silent=TRUE)
      if(!inherits(B,"try-error") && which.max(B)==j0) det<-det+1
    }
  }
  c(p=p, n=n, reps=ok, bias=mean(gh)-gama, rmse=sqrt(mean((gh-gama)^2)),
    cover=cov/ok, detect=if(contam) det/ok else NA)
}
cat("=== Simulacao com numero crescente de covariaveis ===\n")
cat("(uma observacao contaminada por replica; 'detect' = taxa em que o\n")
cat(" diagnostico a aponta em 1o lugar)\n\n")
cat(sprintf("%3s %5s %6s %8s %8s %8s %8s\n","p","n","reps","bias","RMSE","cover","detect"))
res <- list()
for(n in c(100,200)) for(p in c(2,4,6,8)){
  r <- sim(p,n)
  res[[paste(p,n)]] <- r
  cat(sprintf("%3d %5d %6d %+8.4f %8.4f %8.3f %8.3f\n",
      r["p"],r["n"],r["reps"],r["bias"],r["rmse"],r["cover"],r["detect"]))
}
saveRDS(res,"simdim.rds")
