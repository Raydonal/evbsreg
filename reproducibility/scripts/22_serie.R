suppressMessages(library(evbsreg)); options(warn=-1); data(itajai)
dt <- seq(as.Date("2010-07-01"), by="month", length.out=124)
y  <- itajai$wind
dir.create("fig", showWarnings = FALSE)
png("fig/serie_completa.png", width=10, height=4.6, units="in", res=170)
par(mar=c(4.2,4.6,1.4,4.6))
plot(dt, y, type="o", pch=16, cex=.55, lwd=1.4, col="#1b5e3f",
     xlab="", ylab="Monthly maximum wind gust (m/s)",
     ylim=c(5,36), cex.lab=1.12, xaxt="n")
axis.Date(1, at=seq(min(dt),max(dt),by="2 years"), format="%Y")
## destaque do evento
points(dt[82], y[82], pch=21, bg="#c1121f", col="black", cex=1.7)
text(dt[82], y[82]-2.4, "Apr 2017", col="#c1121f", font=2, cex=.95)
segments(dt[82], y[82]-1.9, dt[82], y[82]-0.9, col="#c1121f")
## 2o e 3o maiores, para contexto
o <- order(y, decreasing=TRUE)[2:3]
points(dt[o], y[o], pch=1, col="grey30", cex=1.5)
text(dt[o], y[o]+1.5, sprintf("%.1f", y[o]), col="grey30", cex=.85)
abline(h=mean(y), lty=2, col="grey55")
text(max(dt), mean(y), sprintf(" mean %.1f", mean(y)), adj=0, xpd=NA, cex=.85, col="grey40")
abline(h=max(y[-82]), lty=3, col="grey45")
box()
dev.off()
cat(sprintf("Serie: %s a %s (%d meses)\n", format(min(dt),"%b %Y"), format(max(dt),"%b %Y"), length(dt)))
cat(sprintf("Evento: %.1f m/s | 2o maior: %.1f | razao: %.2f\n", y[82], max(y[-82]), y[82]/max(y[-82])))
cat(sprintf("Media %.1f | dp %.1f | o evento esta a %.1f desvios da media\n",
    mean(y), sd(y), (y[82]-mean(y))/sd(y)))
