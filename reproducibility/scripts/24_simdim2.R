suppressMessages(library(evbsreg)); options(warn=-1); set.seed(7)
## contaminacao COM SENTIDO: a observacao contaminada vira um extremo
## CONDICIONAL (quantil q da sua propria distribuicao), nao um multiplo cego
qev <- function(p,eta,a,g){z<-((-log(p))^(-g)-1)/g; exp(eta+2*asinh(a*z/2))}
sim <- function(p,n,R=300,gama=-0.2,alpha=0.5,qc=0.9995){
  det1<-det3<-cov<-ok<-0; gh<-numeric(0)
  for(r in 1:R){
    X<-cbind(1,matrix(rnorm(n*(p-1))/2,n,p-1)); beta<-c(1,rep(0.3,p-1))
    eta<-as.vector(X%*%beta)
    y<-revbs(n,alpha=alpha,beta=exp(eta),gama=gama)
    if(any(!is.finite(y))||any(y<=0)) next
    j0<-sample(n,1); y[j0]<-qev(qc,eta[j0],alpha,gama)   # extremo condicional
    if(!is.finite(y[j0])) next
    f<-try(evbsreg.fit(X,y),silent=TRUE); if(inherits(f,"try-error")) next
    if(!is.finite(f$gamahat)||abs(f$gamahat)>2) next
    ok<-ok+1; gh<-c(gh,f$gamahat)
    ci<-f$gamahat+c(-1,1)*1.96*f$stderrorgama
    if(gama>=ci[1]&&gama<=ci[2]) cov<-cov+1
    B<-try(colMeans(cnc_diagnostics(f)$Bj),silent=TRUE)
    if(!inherits(B,"try-error")){ o<-order(B,decreasing=TRUE)
      if(o[1]==j0) det1<-det1+1
      if(j0 %in% o[1:3]) det3<-det3+1 }
  }
  c(p=p,n=n,reps=ok,bias=mean(gh)-gama,rmse=sqrt(mean((gh-gama)^2)),
    cover=cov/ok,det1=det1/ok,det3=det3/ok)
}
cat("=== Contaminacao = extremo condicional (quantil 0.9995) ===\n")
cat(sprintf("%3s %5s %6s %8s %8s %7s %7s %7s\n","p","n","reps","bias","RMSE","cover","top-1","top-3"))
res<-list()
for(n in c(100,200)) for(p in c(2,4,6,8)){
  r<-sim(p,n); res[[paste(p,n)]]<-r
  cat(sprintf("%3d %5d %6d %+8.4f %8.4f %7.3f %7.3f %7.3f\n",
      r["p"],r["n"],r["reps"],r["bias"],r["rmse"],r["cover"],r["det1"],r["det3"]))
}
saveRDS(res,"simdim2.rds")
