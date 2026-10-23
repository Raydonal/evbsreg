suppressMessages({
  library(evbsreg)
  library(ggplot2)
})
options(warn = -1)
set.seed(2023)

outdir <- "fig_originais"
dir.create(outdir, showWarnings = FALSE)
DPI <- 150; W <- 6; H <- 5

data(itajai)
X <- cbind(1, itajai$pressure)

## ---- Cores e estilos consistentes (Dark2) ----
cores <- c("#1b9e77", "#d95f02", "#7570b3", "#e7298a")
ltys  <- c(1, 2, 3, 4)

## =====================================================================
## FIG 1 (plot1, plot2): EVBS densities
## (a) alpha in {1,0.75,0.50,0.25}, beta=1, gamma=0.5
## (b) alpha=0.5, beta=1.5, gamma in {-1.25,-0.75,0.75,1.25}
## =====================================================================
plot_density_set <- function(datasets, labels, xlab, ylab, file) {
  png(file.path(outdir, file), width = W, height = H, units = "in", res = DPI)
  par(mar = c(4.2, 4.4, 1, 1))
  xr <- range(sapply(datasets, function(d) range(d[[1]])))
  yr <- range(sapply(datasets, function(d) range(d[[2]])))
  plot(NA, xlim = xr, ylim = c(0, yr[2]*1.02), xlab = xlab, ylab = ylab,
       cex.lab = 1.2, cex.axis = 1.05)
  for (i in seq_along(datasets)) {
    lines(datasets[[i]][[1]], datasets[[i]][[2]],
          col = cores[i], lty = ltys[i], lwd = 2.6)
  }
  legend("topright", legend = labels, col = cores, lty = ltys,
         lwd = 2.6, bty = "n", cex = 1.05)
  dev.off()
}

# Fig 1a
d1a <- lapply(c(1, 0.75, 0.50, 0.25), function(a) {
  df <- generate_evbs_data(alpha = a, beta = 1, gama = 0.5); list(df$t, df$y)
})
plot_density_set(d1a,
  c(expression(alpha==1), expression(alpha==0.75),
    expression(alpha==0.50), expression(alpha==0.25)),
  expression(italic(t)), expression(italic(f)(italic(t))), "plot1.png")

# Fig 1b
d1b <- lapply(c(-1.25, -0.75, 0.75, 1.25), function(g) {
  df <- generate_evbs_data(alpha = 0.5, beta = 1.5, gama = g); list(df$t, df$y)
})
plot_density_set(d1b,
  c(expression(gamma==-1.25), expression(gamma==-0.75),
    expression(gamma==0.75), expression(gamma==1.25)),
  expression(italic(t)), expression(italic(f)(italic(t))), "plot2.png")

## =====================================================================
## FIG 2 (plot3, plot4): log-EVBS densities
## (a) alpha in {0.25,0.50,2,4}, eta=0, gamma=0
## (b) alpha=1, eta=0, gamma in {-1.05,-0.5,0.5,1.05}
## =====================================================================
# Fig 2a
d2a <- lapply(c(0.25, 0.50, 2, 4), function(a) {
  df <- generate_logevbs_data(alpha = a, eta = 0, gama = 0); list(df$y_vals, df$fdp)
})
plot_density_set(d2a,
  c(expression(alpha==0.25), expression(alpha==0.50),
    expression(alpha==2), expression(alpha==4)),
  expression(italic(y)), expression(italic(f)(italic(y))), "plot3.png")

# Fig 2b
d2b <- lapply(c(-1.05, -0.5, 0.5, 1.05), function(g) {
  df <- generate_logevbs_data(alpha = 1, eta = 0, gama = g); list(df$y_vals, df$fdp)
})
plot_density_set(d2b,
  c(expression(gamma==-1.05), expression(gamma==-0.5),
    expression(gamma==0.5), expression(gamma==1.05)),
  expression(italic(y)), expression(italic(f)(italic(y))), "plot4.png")

cat("Figs 1-2 (densities) done\n")

## =====================================================================
## FIG 3 (plot3a, plot3b): scatter + ACF
## =====================================================================
png(file.path(outdir, "plot3a.png"), width = W, height = H, units = "in", res = DPI)
par(mar = c(4.2, 4.4, 1, 1))
plot(itajai$pressure, itajai$wind, pch = 16, col = "#1b7837",
     xlab = "Atmospheric pressure (mb)", ylab = "Maximum wind speed (m/s)",
     cex.lab = 1.2, cex.axis = 1.05, cex = 1.1)
dev.off()

png(file.path(outdir, "plot3b.png"), width = W, height = H, units = "in", res = DPI)
par(mar = c(4.2, 4.4, 1, 1))
acf(itajai$wind, main = "", lwd = 2, ci.col = "red",
    cex.lab = 1.2, cex.axis = 1.05)
dev.off()
cat("Fig 3 (scatter+acf) done\n")

## =====================================================================
## FIG 4 (plot4a, plot4b): residuals - envelope + index plot
## =====================================================================
png(file.path(outdir, "plot4a.png"), width = W, height = H, units = "in", res = DPI)
par(mar = c(4.2, 4.4, 1, 1))
invisible(envelope_qq(X, itajai$wind, nrep = 100))
dev.off()

r <- rqrandomized(X, itajai$wind)
png(file.path(outdir, "plot4b.png"), width = W, height = H, units = "in", res = DPI)
par(mar = c(4.2, 4.4, 1, 1))
plot(r, pch = 16, col = "#1b7837", xlab = "Index",
     ylab = "Quantile residuals", ylim = range(-3.5, 3.5, r),
     cex.lab = 1.2, cex.axis = 1.05)
abline(h = c(-3, 0, 3), lty = c(2, 1, 2), col = c("red", "grey50", "red"))
dev.off()
cat("Fig 4 (residuals) done\n")

## =====================================================================
## FIG 5 (plot5a, plot5b): eigenvalues + aggregate contributions
## =====================================================================
fit  <- evbsreg.fit(X, itajai$wind)
diag <- cnc_diagnostics(fit)

png(file.path(outdir, "plot5a.png"), width = W, height = H, units = "in", res = DPI)
par(mar = c(4.2, 4.4, 1, 1))
plot_normalized_eigenvalues(diag)
dev.off()

png(file.path(outdir, "plot5b.png"), width = W, height = H, units = "in", res = DPI)
par(mar = c(4.2, 4.4, 1, 1))
plot_aggregate_contributions(diag, q = 7, label.flagged = 5)
dev.off()
cat("Fig 5 (diagnostics) done\n")

## =====================================================================
## FIG 6 (plot6): fitted regression curve
## =====================================================================
## Moved to scripts/28_fitted_quantiles.R (v12). The curve drawn here up to
## v11, exp(x'beta), is not the conditional median of the EVBS regression;
## script 28 draws the exact conditional median and 5%/95% quantiles.

cat("\nALL FIGURES GENERATED\n")
