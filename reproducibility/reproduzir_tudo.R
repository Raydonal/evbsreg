###############################################################################
##  Reproduz todos os resultados numéricos do artigo
##  "Local Influence Diagnostics for Extreme-Value Birnbaum-Saunders
##   Regression, with an Application to Wind-Gust Extremes".
##  As figuras do artigo vêm dos scripts em scripts/; ./figuras/ recebe só
##  figuras de conferência.
##
##  Requisitos:  evbsreg (>= 1.2.2), ismev
##  Uso:         Rscript reproduzir_tudo.R
##  Saída:       ./figuras/*.png  e  os números impressos no console
###############################################################################
suppressMessages({library(evbsreg)})
options(warn = -1)
set.seed(20260718)
OUT <- "figuras"; dir.create(OUT, showWarnings = FALSE)
sep <- function(x) cat("\n", strrep("=", 70), "\n ", x, "\n", strrep("=", 70), "\n")

## ---------------------------------------------------------------- dados ----
data(itajai)
Xi <- cbind(1, itajai$pressure); yi <- itajai$wind
if (!requireNamespace("ismev", quietly = TRUE))
  stop("instale o pacote 'ismev' para o segundo estudo de caso")
data(fremantle, package = "ismev")
fremantle$tt <- (fremantle$Year - mean(fremantle$Year)) / 100
Xf <- cbind(1, fremantle$SOI, fremantle$tt); yf <- fremantle$SeaLevel

## --------------------------------------------- 1. ajuste e diagnósticos ----
sep("1. Itajai: ajuste, indice de cauda e diagnosticos")
fi <- evbsreg.fit(Xi, yi)
cat(sprintf("beta0=%.3f beta1=%.4f alpha=%.3f gama=%.3f\n",
            fi$betahat[1], fi$betahat[2], fi$alphahat, fi$gamahat))
cat(sprintf("SE(gama) assintotico = %.3f\n", fi$stderrorgama))
## Indice de valor extremo da resposta T (Ferreira, Gomes & Leiva 2012, Teo. 4.1-4.2):
## igual a gama quando gama < 0 (dominio de Weibull) e a 2*gama apenas quando gama > 0.
## Ate a v11 este script imprimia 2*gama incondicionalmente, o que e errado aqui.
cat(sprintf("indice de valor extremo da RESPOSTA = %s = %.3f\n",
            if (fi$gamahat < 0) "gama" else "2*gama",
            if (fi$gamahat < 0) fi$gamahat else 2 * fi$gamahat))
Bi <- colMeans(cnc_diagnostics(fi)$Bj)
cat(sprintf("top-3 influentes: #%d (%.3f), #%d (%.3f), #%d (%.3f)\n",
            order(Bi, decreasing = TRUE)[1], sort(Bi, TRUE)[1],
            order(Bi, decreasing = TRUE)[2], sort(Bi, TRUE)[2],
            order(Bi, decreasing = TRUE)[3], sort(Bi, TRUE)[3]))

## ------------------------------------------- 2. medidas de risco / endpoint --
sep("2. Itajai: medidas de risco e limite superior")
pbar <- mean(itajai$pressure); j <- which.max(Bi)
fr <- evbsreg.fit(Xi[-j, ], yi[-j])
for (T in c(10, 50, 100)) {
  a <- evbs_return_level(fi, c(1, pbar), 12 * T, es = TRUE)
  b <- evbs_return_level(fr, c(1, pbar), 12 * T, es = TRUE)
  cat(sprintf("T=%3d anos | RL %.2f -> %.2f (%+.1f%%) | ES %.2f -> %.2f (%+.1f%%)\n",
      T, a[1], b[1], 100*(b[1]-a[1])/a[1], a[2], b[2], 100*(b[2]-a[2])/a[2]))
}
pe <- itajai$pressure[j]
e1 <- evbs_endpoint(fi$betahat[1] + fi$betahat[2]*pe, fi$alphahat, fi$gamahat)
e2 <- evbs_endpoint(fr$betahat[1] + fr$betahat[2]*pe, fr$alphahat, fr$gamahat)
cat(sprintf("\nlimite superior: com #%d = %.2f | sem = %.2f | observado = %.1f\n",
            j, e1, e2, yi[j]))
cat(sprintf(">> sem a observacao, o modelo atribui ao evento %s\n",
            ifelse(e2 < yi[j], "probabilidade zero (acima do ponto final)", "probabilidade positiva")))

## ------------------------------------------- 3. dependencia serial / sazon. --
sep("3. Itajai: dependencia serial e sazonalidade")
r0 <- rqrandomized(Xi, yi)
cat(sprintf("ACF dos residuos, lag 1 = %.3f (banda +/- %.3f)\n",
            acf(r0, plot = FALSE, lag.max = 1)$acf[2], 1.96/sqrt(length(yi))))
m <- seq_along(yi)
X1 <- cbind(Xi, sin(2*pi*m/12), cos(2*pi*m/12))
f1 <- evbsreg.fit(X1, yi)
## log-verossimilhanca na escala da resposta, para o teste de sazonalidade
ll_evbs <- function(f, X, t)
  sum(devbs(t, eta = as.vector(X %*% f$betahat), alpha = f$alphahat,
            gama = f$gamahat, log = TRUE))
LR <- 2 * (ll_evbs(f1, X1, yi) - ll_evbs(fi, Xi, yi))
cat(sprintf("harmonicos anuais: LR = %.2f, 2 gl, p = %.2f\n",
            LR, pchisq(LR, 2, lower.tail = FALSE)))
B1 <- colMeans(cnc_diagnostics(f1)$Bj); o1 <- order(B1, decreasing = TRUE)[1:2]
cat(sprintf("  com harmonicos: #%d (%.3f) contra #%d (%.3f)\n",
            o1[1], B1[o1[1]], o1[2], B1[o1[2]]))
## Bootstrap em blocos: B = 2000 com tres sementes (cerca de 1 minuto); com
## B = 300 o valor oscila entre 0.07 e 0.08 conforme a semente.
se_bb <- sapply(1:3, function(s) {
  set.seed(s); evbs_block_boot(Xi, yi, L = 4, B = 2000)$se["gama"] })
cat(sprintf("SE(gama): assintotico %.3f | bootstrap em blocos %.3f (sementes: %s)\n",
            fi$stderrorgama, mean(se_bb), paste(sprintf("%.3f", se_bb), collapse = ", ")))

## --------------------------------------- 4. comparacao entre familias -----
## Tabela 6 do artigo. Log-verossimilhancas TODAS na escala da resposta (o
## ajuste EVBS e feito em Y = log T, entao subtrai-se o jacobiano sum(log t)),
## e os tres modelos tem o mesmo numero de parametros livres em cada serie.
sep("4. EVBS vs GEV vs EGPD (covariaveis centradas p/ GEV e EGPD)")
evbs_ll_T <- function(f, X, t) {
  y <- log(t); mu <- as.vector(X %*% f$betahat)
  a <- f$alphahat; g <- f$gamahat
  x1 <- (2/a)*cosh((y-mu)/2); x2 <- (2/a)*sinh((y-mu)/2); u <- 1 + g*x2
  sum(-log(2) + log(x1) + (-1-1/g)*log(u) - u^(-1/g)) - sum(log(t))
}
Xic <- cbind(1, itajai$pressure - pbar)
gi  <- gevreg.fit(Xic, yi)
lle <- evbs_ll_T(fi, Xi, yi)
cat(sprintf("Itajai   | EVBS AIC = %.2f | GEV AIC = %.2f | xi = %+.4f\n",
            -2*lle + 8, -2*gi$loglik + 8, gi$xi))
Bg <- cnc_diagnostics_gev(gi)$Bj
cat(sprintf("           influentes sob a GEV: #%d, #%d, #%d\n",
            order(Bg, decreasing = TRUE)[1], order(Bg, decreasing = TRUE)[2],
            order(Bg, decreasing = TRUE)[3]))
ff <- evbsreg.fit(Xf, yf); gf <- gevreg.fit(Xf, yf)
cat(sprintf("Fremantle| EVBS AIC = %.2f, gama = %+.4f | GEV AIC = %.2f, xi = %+.4f\n",
            -2*evbs_ll_T(ff, Xf, yf) + 10, ff$gamahat, -2*gf$loglik + 10, gf$xi))
cat(">> a EGPD e a verificacao do escore da GP estao em scripts/27_comparacao_familias.R\n")

## --------------------------------------------------- 5. carta de controle --
sep("5. Carta de controle (indice F_t)")
ci <- evbs_monitor(Xi, yi, burn = 40)
cf <- evbs_monitor(Xf, yf, burn = 40)
ci_naive <- evbs_monitor(Xi, yi, burn = 40, use = "max")
cf_naive <- evbs_monitor(Xf, yf, burn = 40, use = "max")
cat(sprintf("Itajai   | F antes de t=%d: %.3f | depois: %.3f\n",
            j, mean(ci$F[ci$t < j]), mean(ci$F[ci$t >= j])))
cat(sprintf("Fremantle| F medio (curvatura): %.3f | ingenuo: %.3f\n",
            mean(cf$F), mean(cf_naive$F)))
cat(">> o indice ingenuo daria ALARME FALSO em Fremantle\n")

png(file.path(OUT, "carta_controle.png"), width = 10, height = 4.6,
    units = "in", res = 170)
par(mfrow = c(1, 2), mar = c(4.3, 4.6, 3, 1))
for (k in 1:2) {
  d <- if (k == 1) ci else cf; dn <- if (k == 1) ci_naive else cf_naive
  ttl <- if (k == 1) "Itajai wind gusts" else "Fremantle sea levels"
  col <- if (k == 1) "#c1121f" else "#1b7837"
  plot(d$t, d$F, type = "n", ylim = c(0.75, 1.30), xlab = "Observation index t",
       ylab = expression(F[t]), main = ttl, cex.lab = 1.15)
  polygon(c(-9, 9e3, 9e3, -9), c(0.5, 0.5, 1, 1),
          col = rgb(1, 0, 0, 0.07), border = NA)
  lines(dn$t, dn$F, col = "grey65", lwd = 1.6, lty = 2)
  lines(d$t, d$F, col = col, lwd = 2.4)
  abline(h = 1, lwd = 2, lty = 2)
  if (k == 1) abline(v = j, col = "grey40", lty = 3)
  legend(if (k == 1) "bottomleft" else "bottomright",
         c("curvature-based", "naive (delete max)"), col = c(col, "grey65"),
         lwd = c(2.4, 1.6), lty = c(1, 2), bty = "n", cex = 0.85)
}
dev.off()

## ------------------------------------------------- 6. contraste dos B_j ----
png(file.path(OUT, "contraste.png"), width = 10, height = 4.3,
    units = "in", res = 170)
par(mfrow = c(1, 2), mar = c(4.3, 4.5, 2.6, 1))
Bf <- colMeans(cnc_diagnostics(ff)$Bj)
plot(Bi, type = "h", lwd = 2, col = "grey55", ylim = c(0, .62),
     xlab = "Observation index", ylab = expression(B[j]),
     main = "Itajai: concentrated influence", cex.lab = 1.12)
abline(h = 2/length(yi), col = "red", lty = 2)
points(j, Bi[j], pch = 19, col = "#c1121f", cex = 1.4)
plot(Bf, type = "h", lwd = 2, col = "grey55", ylim = c(0, .62),
     xlab = "Observation index", ylab = expression(B[j]),
     main = "Fremantle: diffuse influence", cex.lab = 1.12)
abline(h = 2/length(yf), col = "red", lty = 2)
points(which.max(Bf), max(Bf), pch = 19, col = "#1b7837", cex = 1.4)
dev.off()

## ---------------------------------------------------- 7. serie completa ----
png(file.path(OUT, "serie_completa.png"), width = 10, height = 4.6,
    units = "in", res = 170)
dt <- seq(as.Date("2010-07-01"), by = "month", length.out = length(yi))
par(mar = c(4.2, 4.6, 1.4, 4.6))
plot(dt, yi, type = "o", pch = 16, cex = .55, lwd = 1.4, col = "#1b5e3f",
     xlab = "", ylab = "Monthly maximum wind gust (m/s)", ylim = c(5, 36),
     cex.lab = 1.12)
points(dt[j], yi[j], pch = 21, bg = "#c1121f", col = "black", cex = 1.7)
abline(h = mean(yi), lty = 2, col = "grey55")
abline(h = max(yi[-j]), lty = 3, col = "grey45")
dev.off()
cat(sprintf("\nevento = %.1f m/s | 2o maior = %.1f | razao %.2f | %.1f desvios\n",
            yi[j], max(yi[-j]), yi[j]/max(yi[-j]), (yi[j]-mean(yi))/sd(yi)))

## ------------------------------------------- 8. densidades e diagnosticos --
for (nm in c("plot1","plot2","plot3","plot4")) {}
png(file.path(OUT, "densidades_evbs.png"), width = 10, height = 4.4,
    units = "in", res = 170)
par(mfrow = c(1, 2), mar = c(4.2, 4.4, 1, 1))
cores <- c("#1b9e77","#d95f02","#7570b3","#e7298a")
for (k in 1:2) {
  ps <- if (k == 1) c(1, .75, .5, .25) else c(-1.25, -.75, .75, 1.25)
  dd <- lapply(ps, function(v) if (k == 1)
      generate_evbs_data(alpha = v, beta = 1, gama = .5)
    else generate_evbs_data(alpha = .5, beta = 1.5, gama = v))
  xr <- range(sapply(dd, function(z) range(z$t)))
  yr <- max(sapply(dd, function(z) max(z$y)))
  plot(NA, xlim = xr, ylim = c(0, yr*1.02), xlab = "t", ylab = "f(t)", cex.lab = 1.2)
  for (i in 1:4) lines(dd[[i]]$t, dd[[i]]$y, col = cores[i], lty = i, lwd = 2.6)
  legend("topright", legend = ps, col = cores, lty = 1:4, lwd = 2.6, bty = "n")
}
dev.off()

png(file.path(OUT, "diagnosticos_itajai.png"), width = 10, height = 4.4,
    units = "in", res = 170)
par(mfrow = c(1, 2), mar = c(4.2, 4.4, 1, 1))
plot_normalized_eigenvalues(cnc_diagnostics(fi))
plot_aggregate_contributions(cnc_diagnostics(fi), q = 7, label.flagged = 5)
dev.off()

sep("CONCLUIDO")
cat("figuras em ./", OUT, "/\n", sep = "")
cat("sessao:", R.version.string, "| evbsreg",
    as.character(packageVersion("evbsreg")), "\n")

## ------------------------------------- 9. figuras da segunda aplicacao ----
sep("9. Fremantle: ajuste, residuos e diagnosticos")
dgf <- cnc_diagnostics(ff); Bf2 <- colMeans(dgf$Bj)
cat(sprintf("beta = (%.3f, %.3f, %.3f) | alpha %.3f | gama %+.3f\n",
    ff$betahat[1], ff$betahat[2], ff$betahat[3], ff$alphahat, ff$gamahat))
cat(sprintf("autovalores normalizados: %s\n",
    paste(sprintf("%.3f", dgf$eigenvalues_norm[1:4]), collapse=" ")))
cat(sprintf("top-5: %s\n", paste(sprintf("#%d(%.3f, %d)",
    order(Bf2, decreasing=TRUE)[1:5], sort(Bf2, TRUE)[1:5],
    fremantle$Year[order(Bf2, decreasing=TRUE)[1:5]]), collapse=" ")))

png(file.path(OUT,"fremantle_ajuste.png"), width=10, height=4.4, units="in", res=170)
par(mfrow=c(1,2), mar=c(4.3,4.5,1.2,1))
plot(fremantle$Year, yf, type="o", pch=16, cex=.6, col="#1b5e3f",
     xlab="Year", ylab="Annual maximum sea level (m)", cex.lab=1.12)
lines(fremantle$Year, exp(as.vector(Xf %*% ff$betahat)), col="#c1121f", lwd=2.6)
plot(fremantle$SOI, yf, pch=16, col="#1b5e3f", xlab="SOI",
     ylab="Annual maximum sea level (m)", cex.lab=1.12)
dev.off()

png(file.path(OUT,"fremantle_diag.png"), width=10, height=4.4, units="in", res=170)
par(mfrow=c(1,2), mar=c(4.3,4.5,1.2,1))
plot_normalized_eigenvalues(dgf)
plot_aggregate_contributions(dgf, q=7, label.flagged=5)
dev.off()
cat("figuras de Fremantle geradas\n")

## ------------------------------------------ 10. numeros restantes do texto --
sep("10. Tabelas 1 e 3, testes dos residuos, testes e carta de Fremantle")
w <- itajai$wind; mw <- mean(w); m2 <- mean((w - mw)^2)  # momentos
cat(sprintf("Tabela 1: n %d | min %.2f | Q1 %.2f | mediana %.2f | media %.2f | Q3 %.2f | max %.2f\n",
            length(w), min(w), quantile(w, .25), median(w), mw, quantile(w, .75), max(w)))
cat(sprintf("          DP %.2f | assimetria %.2f | curtose em excesso %.2f\n",
            sd(w), mean((w - mw)^3) / m2^1.5, mean((w - mw)^4) / m2^2 - 3))
ri <- rqrandomized(Xi, yi)
cat(sprintf("residuos quantilicos: Shapiro-Wilk p = %.3f | Kolmogorov-Smirnov p = %.3f\n",
            shapiro.test(ri)$p.value, ks.test(ri, "pnorm")$p.value))
cat("Tabela 3 (taxa de mudanca ao remover cada observacao marcada):\n")
for (j in c(82, 108)) {
  fj <- evbsreg.fit(Xi[-j, ], yi[-j])
  rc <- 100 * (fj$coeff - fi$coeff) / abs(fi$coeff)
  cat(sprintf("  sem #%d: MLE %s | R %s\n", j,
              paste(sprintf("%.3f", fj$coeff), collapse = " "),
              paste(sprintf("%+.1f%%", rc), collapse = " ")))
}
## Fremantle: significancia e razao de verossimilhancas (Jacobiano se cancela)
Xs <- Xf[, 1:2]
ff <- evbsreg.fit(Xf, yf); fs <- evbsreg.fit(Xs, yf)
cat(sprintf("Fremantle: p(SOI) = %.4f | p(tendencia) = %.4f\n", ff$pvalues[2], ff$pvalues[3]))
LRf <- 2 * (ll_evbs(ff, Xf, yf) - ll_evbs(fs, Xs, yf))
cat(sprintf("Fremantle: LR(tendencia) = %.2f, 1 gl, p = %.4f\n", LRf, pchisq(LRf, 1, lower.tail = FALSE)))
cf <- evbs_monitor(Xf, yf, burn = 40); cn <- evbs_monitor(Xf, yf, burn = 40, use = "max")
m6 <- cf$flagged == 6; m11 <- cf$flagged == 11
cat(sprintf("Fremantle F_t: #6 marcado em %d de %d instantes (media %.3f), #11 em %d (media %.3f), desde t = %d\n",
            sum(m6), nrow(cf), mean(cf$F[m6]), sum(m11), mean(cf$F[m11]), min(cf$t[m11])))
cat(sprintf("               media geral %.3f | ingenuo abaixo de 1 em %d de %d (media %.3f)\n",
            mean(cf$F), sum(cn$F < 1), nrow(cn), mean(cn$F)))
