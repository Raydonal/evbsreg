options(warn=-1)
r <- readRDS("simdim2.rds")
M <- do.call(rbind, r); M <- as.data.frame(M)
dir.create("fig", showWarnings = FALSE)
png("fig/simdim.png", width=10, height=3.9, units="in", res=170)
par(mfrow=c(1,3), mar=c(4.3,4.6,2.4,1))
cols<-c("#1b9e77","#d95f02"); ns<-c(100,200)
pxlab <- expression("Number of covariates " * italic(p))
# RMSE
plot(NA,xlim=c(2,8),ylim=c(0,0.12),xlab=pxlab,
     ylab=expression(RMSE(hat(gamma))),main="Precision",cex.lab=1.15)
for(i in 1:2){s<-M[M$n==ns[i],];lines(s$p,s$rmse,col=cols[i],lwd=2.4,type="o",pch=15+i,cex=1.2)}
legend("topleft",legend=paste("n =",ns),col=cols,lwd=2.4,pch=16:17,bty="n")
# cobertura
plot(NA,xlim=c(2,8),ylim=c(0.82,1),xlab=pxlab,
     ylab="Coverage",main="Calibration",cex.lab=1.15)
abline(h=0.95,lty=2,lwd=2,col="grey35")
for(i in 1:2){s<-M[M$n==ns[i],];lines(s$p,s$cover,col=cols[i],lwd=2.4,type="o",pch=15+i,cex=1.2)}
text(7.9,0.965,"nominal 0.95",col="grey35",cex=.85,adj=1)
# deteccao
plot(NA,xlim=c(2,8),ylim=c(0,1),xlab=pxlab,
     ylab="Detection rate",main="Screening ability",cex.lab=1.15)
for(i in 1:2){s<-M[M$n==ns[i],]
  lines(s$p,s$det3,col=cols[i],lwd=2.6,type="o",pch=15+i,cex=1.2)
  lines(s$p,s$det1,col=cols[i],lwd=1.8,lty=2,type="o",pch=15+i,cex=.9)}
legend("bottomleft",c("in top 3 (solid)","ranked first (dashed)"),
       lwd=c(2.6,1.8),lty=c(1,2),bty="n",cex=.9,col="grey25")
dev.off()
cat("fig/simdim.png gerada\n")
