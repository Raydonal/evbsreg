suppressMessages(library(evbsreg)); options(warn=-1)
data(fremantle,package="ismev"); d<-fremantle
d$tt<-(d$Year-mean(d$Year))/100
X<-cbind(1,d$SOI,d$tt); y<-d$SeaLevel
f<-evbsreg.fit(X,y); dg<-cnc_diagnostics(f); B<-colMeans(dg$Bj)

## --- Fig A: serie + ajuste (paralela a fig 6 de Itajai) ---
## Moved to scripts/28_fitted_quantiles.R (v12): the curve drawn here up to
## v11, exp(x'beta), was labelled "fitted median" but is not the median of
## the EVBS regression. Script 28 draws the exact conditional quantiles.

## --- Fig B: diagnosticos (paralela a fig 5 de Itajai) ---
dir.create("fig", showWarnings = FALSE)
png("fig/frem_diag.png",width=10,height=4.4,units="in",res=170)
par(mfrow=c(1,2),mar=c(4.3,4.5,1.2,1))
plot_normalized_eigenvalues(dg)
## Right panel: mean aggregate contribution Bbar_j across q=1..7 plus the
## unthresholded (global) contribution -- see \bar B_j in the manuscript.
## No single q isolates a clearly influential set here (the top normalised
## eigenvalue, 0.671, falls short of the q=7 cutoff 7/sqrt(86)=0.755), so
## B_j(7) alone is degenerate for this record; Bbar_j is what Table 8 and
## the highlighted points in Figure 10 already use.
Bbar <- colMeans(dg$Bj)
ordB <- order(Bbar, decreasing = TRUE)[1:5]
ypos <- evbsreg:::.declutter_above(ordB, Bbar[ordB], n = dg$n,
                                    step = max(Bbar) * 0.05)
plot(Bbar, type = "p", pch = 16, cex = 0.7,
     ylim = c(0, max(Bbar, 2/dg$n) * 1.15),
     ylab = expression(bar(B)[j]), xlab = "Index")
abline(h = 2/dg$n, lty = 2, col = "red")
text(ordB, ypos, labels = ordB, cex = 0.85, col = "blue")
dev.off()

## --- Fig C: residuos (paralela a fig 4 de Itajai) ---
png("fig/frem_resid.png",width=10,height=4.4,units="in",res=170)
par(mfrow=c(1,2),mar=c(4.3,4.5,1.2,1))
set.seed(2023)  # simulated envelope; same seed as the Itajai figure
invisible(envelope_qq(X,y,nrep=100))
r<-rqrandomized(X,y)
plot(r,pch=16,col="#1b5e3f",xlab="Index",ylab="Quantile residuals",
     ylim=range(-3.5,3.5,r),cex.lab=1.12)
abline(h=c(-3,0,3),lty=c(2,1,2),col=c("red","grey50","red"))
dev.off()

cat("=== Numeros para a tabela de Fremantle ===\n")
for(k in seq_along(f$betahat))
  cat(sprintf("beta%d = %+.3f  SE %.3f  z %+.2f  p %.4g\n",
      k-1,f$betahat[k],f$stderrors[k],f$zstats[k],f$pvalues[k]))
cat(sprintf("alpha = %.3f (SE %.3f) | gama = %+.3f (SE %.3f)\n",
    f$alphahat,f$stderroralpha,f$gamahat,f$stderrorgama))
cat(sprintf("autovalores normalizados: %s\n", paste(sprintf("%.3f",dg$eigenvalues_norm[1:4]),collapse=" ")))
cat(sprintf("limiar 7/sqrt(n) = %.3f | b(7) = %.4f\n", 7/sqrt(86), dg$bq))
cat(sprintf("top-5 B_j: %s\n", paste(sprintf("#%d(%.3f,%d)",order(B,decreasing=TRUE)[1:5],
    sort(B,decreasing=TRUE)[1:5], d$Year[order(B,decreasing=TRUE)[1:5]]),collapse=" ")))
