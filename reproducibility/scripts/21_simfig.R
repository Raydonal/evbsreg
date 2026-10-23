## Figure S1 of the Supplementary Material (fig/simulacao.png): RMSE and coverage
## of gamma-hat against n in Scenarios 1-3. The values are the gamma columns of
## Tables S2, S4 and S6, which come from evbsreg::evbsreg.fit.mc() with 5,000
## replicates (inst/scripts/script_03-05 of the package; hours to run). The
## script used to read them from a JSON dump that no longer exists, so they are
## written out here and the figure is redrawn from the published tables.
## Run from the repository root.
cols <- c("#1b9e77","#d95f02","#7570b3"); gs <- c(-0.20, 0, 0.20); ns <- c(60, 120, 180)
## rows: n = 60, 120, 180; columns: gamma = -0.2, 0, 0.2
rmse <- list(
  S1 = rbind(c(0.112, 0.116, 0.129), c(0.067, 0.073, 0.083), c(0.052, 0.058, 0.066)),
  S2 = rbind(c(0.109, 0.115, 0.127), c(0.067, 0.073, 0.083), c(0.052, 0.058, 0.066)),
  S3 = rbind(c(0.126, 0.132, 0.142), c(0.074, 0.080, 0.089), c(0.057, 0.064, 0.071)))
cp <- list(
  S1 = rbind(c(0.924, 0.933, 0.938), c(0.935, 0.939, 0.940), c(0.942, 0.944, 0.943)),
  S2 = rbind(c(0.919, 0.931, 0.937), c(0.931, 0.936, 0.942), c(0.941, 0.945, 0.946)),
  S3 = rbind(c(0.923, 0.925, 0.930), c(0.946, 0.942, 0.942), c(0.946, 0.944, 0.946)))

dir.create("fig", showWarnings = FALSE)
png("fig/simulacao.png", width=10.5, height=6.4, units="in", res=170)
par(mfrow=c(2,3), mar=c(4.1,4.5,2.6,0.9), oma=c(0,0,0,0))
## row 1: RMSE of gamma-hat
for(s in 1:3){
  m <- rmse[[s]]
  plot(NA, xlim=c(50,190), ylim=c(0,max(0.2,max(m)*1.15)), xlab=expression(italic(n)),
       ylab=expression(RMSE(hat(gamma))), main=paste("Scenario",s), cex.lab=1.15)
  for(i in 1:3) lines(ns, m[,i], col=cols[i], lwd=2.4, type="o", pch=15+i, cex=1.1)
  if(s==1) legend("topright", legend=sapply(gs,function(g) as.expression(bquote(gamma==.(g)))),
     col=cols, lwd=2.4, pch=16:18, bty="n", cex=1.0)
}
## row 2: coverage
for(s in 1:3){
  m <- cp[[s]]
  plot(NA, xlim=c(50,190), ylim=c(0.82,1), xlab=expression(italic(n)),
       ylab="Coverage probability", main=paste("Scenario",s), cex.lab=1.15)
  abline(h=0.95, lwd=2, lty=2, col="grey35")
  for(i in 1:3) lines(ns, m[,i], col=cols[i], lwd=2.4, type="o", pch=15+i, cex=1.1)
  if(s==1) text(60,0.955,"nominal 0.95",col="grey35",cex=.85,adj=0)
}
dev.off()
cat("fig/simulacao.png written\n")
