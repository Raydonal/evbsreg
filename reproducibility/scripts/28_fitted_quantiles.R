## Fitted conditional quantiles for Figure 5 (fig_originais/plot6.png, Itajai)
## and Figure 8 (fig/frem_serie.png, Fremantle) of the paper (v16). Run from the project root.
##
## Up to v11 both figures drew exp(x'beta) and labelled it the "fitted median".
## That curve is not the median: exp(x'beta) is the scale of the multiplicative
## EVBS error, and the median of EVBS(alpha, 1, gamma) is
##   exp{2 asinh(alpha z_0.5 / 2)},  z_0.5 = {(log 2)^(-gamma) - 1} / gamma,
## which equals 1 only when z_0.5 = 0 (never, for a GEV kernel). The curves
## below are the exact conditional quantiles from qevbs(), and the multiplier
## is printed so the text can quote it.
## This script replaces the plot6 block of gerar_figuras.R and the "Fig A"
## block of 26_frem_figs.R, which have been removed from those scripts.

.libPaths(c("~/R/libs", .libPaths()))
suppressMessages(library(evbsreg))
options(warn = -1)

med_mult <- function(alpha, gama) qevbs(0.5, eta = 0, alpha = alpha, gama = gama)
cq <- function(p, eta, f) qevbs(p, eta = eta, alpha = f$alphahat, gama = f$gamahat)

col_obs <- "#1b7837"; col_med <- "#c1121f"; col_band <- "#c1121f"

## ---------------------------------------------------------------- Itajai
data(itajai)
X <- cbind(1, itajai$pressure)
fit <- evbsreg.fit(X, itajai$wind)
cat(sprintf("Itajai:    median / exp(x'beta) = %.4f\n",
            med_mult(fit$alphahat, fit$gamahat)))

for (d in c("fig", "fig_originais")) dir.create(d, showWarnings = FALSE)
png("fig_originais/plot6.png", width = 6, height = 5, units = "in", res = 150)
par(mar = c(4.2, 4.4, 1, 1))
pg <- seq(min(itajai$pressure), max(itajai$pressure), length.out = 200)
eta <- fit$betahat[1] + fit$betahat[2] * pg
plot(itajai$pressure, itajai$wind, pch = 16, col = col_obs,
     xlab = "Atmospheric pressure (mb)", ylab = "Maximum wind speed (m/s)",
     cex.lab = 1.2, cex.axis = 1.05, cex = 1.1,
     ylim = range(itajai$wind, cq(0.05, eta, fit), cq(0.95, eta, fit)))
lines(pg, cq(0.50, eta, fit), col = col_med, lwd = 3)
lines(pg, cq(0.05, eta, fit), col = col_band, lwd = 1.6, lty = 2)
lines(pg, cq(0.95, eta, fit), col = col_band, lwd = 1.6, lty = 2)
legend("topright", c("conditional median", "5% and 95% conditional quantiles"),
       col = col_med, lwd = c(3, 1.6), lty = c(1, 2), bty = "n", cex = 1)
dev.off()

## ------------------------------------------------------------- Fremantle
data(fremantle, package = "ismev"); d <- fremantle
d$tt <- (d$Year - mean(d$Year)) / 100
X <- cbind(1, d$SOI, d$tt); y <- d$SeaLevel
f <- evbsreg.fit(X, y); B <- colMeans(cnc_diagnostics(f)$Bj)
cat(sprintf("Fremantle: median / exp(x'beta) = %.4f\n",
            med_mult(f$alphahat, f$gamahat)))

png("fig/frem_serie.png", width = 10, height = 4.4, units = "in", res = 170)
par(mfrow = c(1, 2), mar = c(4.3, 4.5, 1.2, 1))
eta_t <- as.vector(X %*% f$betahat)
lo <- cq(0.05, eta_t, f); hi <- cq(0.95, eta_t, f)
yr <- range(y, lo, hi); ypad <- diff(yr) * 0.12
plot(d$Year, y, type = "n", xlab = "Year", ylab = "Annual maximum sea level (m)",
     cex.lab = 1.12, ylim = c(yr[1] - ypad, yr[2] + ypad))
polygon(c(d$Year, rev(d$Year)), c(lo, rev(hi)),
        col = adjustcolor(col_band, 0.12), border = NA)
lines(d$Year, cq(0.5, eta_t, f), col = col_med, lwd = 2.2)
lines(d$Year, y, type = "o", pch = 16, cex = .6, col = "#1b5e3f")
j <- which.max(B); j2 <- order(B, decreasing = TRUE)[2]
points(d$Year[j], y[j], pch = 21, bg = col_obs, col = "black", cex = 1.6)
points(d$Year[j2], y[j2], pch = 21, bg = "#d95f02", col = "black", cex = 1.6)
text(d$Year[j], y[j] + .07, d$Year[j], col = col_obs, font = 2, cex = .85)
text(d$Year[j2], y[j2] - .07, d$Year[j2], col = "#d95f02", font = 2, cex = .85)
legend("bottomright", c("observed", "conditional median", "5%-95% conditional band"),
       col = c("#1b5e3f", col_med, adjustcolor(col_band, 0.35)),
       lwd = c(1, 2.2, 8), pch = c(16, NA, NA), bty = "n", cex = .85)

sg <- seq(min(d$SOI), max(d$SOI), length.out = 200)
eta_s <- f$betahat[1] + f$betahat[2] * sg + f$betahat[3] * mean(d$tt)
plot(d$SOI, y, pch = 16, col = "#1b5e3f", xlab = "Southern Oscillation Index",
     ylab = "Annual maximum sea level (m)", cex.lab = 1.12,
     ylim = range(y, cq(0.05, eta_s, f), cq(0.95, eta_s, f)))
lines(sg, cq(0.50, eta_s, f), col = col_med, lwd = 2.6)
lines(sg, cq(0.05, eta_s, f), col = col_band, lwd = 1.4, lty = 2)
lines(sg, cq(0.95, eta_s, f), col = col_band, lwd = 1.4, lty = 2)
dev.off()

cat("plot6.png and frem_serie.png written\n")
