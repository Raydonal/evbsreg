## Prospective identifiability index F_t (eq. 26) recomputed under the
## generalised extreme-value regression, next to the EVBS version, for both
## records. Same definition as evbsreg::evbs_monitor(): at each t >= burn, fit
## to the first t records, flag j*(t) = argmax Bbar_j, refit without it, and
## divide the refitted endpoint, evaluated at the covariate value of the running
## maximum, by the running maximum. Endpoint = mu(x) - sigma/xi if xi < 0 and
## +Inf otherwise (same convention as evbs_endpoint()). Bbar_j is computed
## identically for the GEV, from the individual scores (eq. 24). Figure 12.
## Writes fig/carta_gev.png. Run from the project root.

.libPaths(c("~/R/libs", .libPaths()))
suppressMessages(library(evbsreg)); options(warn = -1)

## ---- GEV ingredients (as in scripts/27_comparacao_familias.R) ----
gev_lli <- function(par, X, y) {
  p <- ncol(X); mu <- as.vector(X %*% par[1:p]); s <- exp(par[p+1]); xi <- par[p+2]
  u <- 1 + xi * (y - mu) / s
  if (any(u <= 0)) return(rep(-1e6, length(y)))
  -log(s) - (1 + 1/xi) * log(u) - u^(-1/xi)
}
F_generic <- function(lli, par, h = 1e-5) {
  k <- length(par)
  S <- sapply(seq_len(k), function(a) { e <- replace(0 * par, a, h)
    (lli(par + e) - lli(par - e)) / (2 * h) })
  L <- matrix(0, k, k)
  for (a in seq_len(k)) for (b in seq_len(k)) {
    ea <- replace(0 * par, a, h); eb <- replace(0 * par, b, h)
    L[a, b] <- (sum(lli(par+ea+eb)) - sum(lli(par+ea-eb)) -
                sum(lli(par-ea+eb)) + sum(lli(par-ea-eb))) / (4 * h^2) }
  S %*% solve(-L) %*% t(S)
}
bbar <- function(F) {
  n <- nrow(F); ev <- eigen((F + t(F)) / 2, symmetric = TRUE)
  ls <- abs(ev$values) / sqrt(sum(ev$values^2)); A2 <- ev$vectors^2
  Bq <- sapply(1:7, function(q) A2 %*% ifelse(ls > q / sqrt(n), ls, 0))
  rowMeans(cbind(Bq, A2 %*% ls))
}
gev_endpoint <- function(f, x) if (f$xi < 0) sum(x * f$beta) - f$sigma / f$xi else Inf

gev_monitor <- function(X, y, burn = 40, use = c("curvature", "max")) {
  use <- match.arg(use); out <- NULL; nfail <- 0
  for (t in burn:length(y)) {
    yt <- y[1:t]; Xt <- X[1:t, , drop = FALSE]; jm <- which.max(yt)
    f <- try(gevreg.fit(Xt, yt), silent = TRUE)
    if (inherits(f, "try-error") || f$convergence != 0) { nfail <- nfail + 1; next }
    j <- if (use == "curvature") {
      B <- try(bbar(F_generic(function(q) gev_lli(q, Xt, yt), c(f$beta, log(f$sigma), f$xi))), silent = TRUE)
      if (inherits(B, "try-error")) { nfail <- nfail + 1; next }
      which.max(B)
    } else jm
    fj <- try(gevreg.fit(Xt[-j, , drop = FALSE], yt[-j]), silent = TRUE)
    if (inherits(fj, "try-error") || fj$convergence != 0) { nfail <- nfail + 1; next }
    ep <- gev_endpoint(fj, Xt[jm, ])
    out <- rbind(out, data.frame(t = t, ymax = max(yt), flagged = j, xi = f$xi,
                                 xi_del = fj$xi, endpoint = ep, F = ep / max(yt)))
  }
  attr(out, "nfail") <- nfail; out
}

## ---- data: GEV with centred covariates (a reparametrisation; the fitted
## model, and hence the endpoint, does not depend on the centring constant) ----
data(itajai)
Xi  <- cbind(1, itajai$pressure); yi <- itajai$wind
Xic <- cbind(1, itajai$pressure - mean(itajai$pressure))
data(fremantle, package = "ismev")
fremantle$tt <- (fremantle$Year - mean(fremantle$Year)) / 100
Xf <- cbind(1, fremantle$SOI, fremantle$tt); yf <- fremantle$SeaLevel

ei <- evbs_monitor(Xi, yi, burn = 40); ef <- evbs_monitor(Xf, yf, burn = 40)
gi <- gev_monitor(Xic, yi); gf <- gev_monitor(Xf, yf)
gin <- gev_monitor(Xic, yi, use = "max"); gfn <- gev_monitor(Xf, yf, use = "max")

summ <- function(nm, e, g, gn, tcut) {
  m <- merge(data.frame(t = e$t, jE = e$flagged, FE = e$F),
             data.frame(t = g$t, jG = g$flagged, FG = g$F), by = "t")
  cat(sprintf("\n%s: %d instants (GEV fits failed/unconverged: %d)\n", nm, nrow(m), attr(g, "nfail")))
  cat(sprintf("  same flagged case under EVBS and GEV: %d of %d instants (%.0f%%)\n",
              sum(m$jE == m$jG), nrow(m), 100 * mean(m$jE == m$jG)))
  cat(sprintf("  GEV refit without j* has xi >= 0 (endpoint infinite): %d instants\n", sum(!is.finite(g$F))))
  for (lab in c("EVBS", "GEV")) { Fv <- if (lab == "EVBS") m$FE else m$FG
    cat(sprintf("  %-4s F_t: below 1 at %2d instants; first below 1 at t = %s; t < %d: %d below 1 | t >= %d: %d of %d below 1\n",
        lab, sum(Fv < 1), if (any(Fv < 1)) m$t[which(Fv < 1)[1]] else "never",
        tcut, sum(Fv[m$t < tcut] < 1), tcut, sum(Fv[m$t >= tcut] < 1), sum(m$t >= tcut))) }
  fin <- is.finite(m$FG)
  cat(sprintf("  median F_t (finite values): EVBS %.3f, GEV %.3f\n", median(m$FE), median(m$FG[fin])))
  cat(sprintf("  naive GEV index (delete the maximum): below 1 at %d of %d instants\n", sum(gn$F < 1), nrow(gn)))
  invisible(m)
}
mi <- summ("Itajai", ei, gi, gin, 82)
mf <- summ("Fremantle", ef, gf, gfn, 68)
cat("\nFremantle, flagged case by instant (EVBS / GEV):\n")
print(table(EVBS = mf$jE, GEV = mf$jG))

## ---- figure: one chart per record with the three indices (replaces, in
## v13, both fig/carta_final.png and the separate EVBS-vs-GEV panel) ----
ein <- evbs_monitor(Xi, yi, burn = 40, use = "max")
efn <- evbs_monitor(Xf, yf, burn = 40, use = "max")
t_sw_e <- min(ef$t[ef$flagged == 11]); t_sw_g <- min(gf$t[gf$flagged == 11])
dir.create("fig", showWarnings = FALSE)
png("fig/carta_combinada.png", width = 10, height = 4.8, units = "in", res = 170)
par(mfrow = c(1, 2), mar = c(4.3, 4.6, 3.0, 1))
yl <- c(0.75, 1.50)
frame <- function(t, main) {
  plot(t, t, type = "n", ylim = yl, xlim = range(t),
       xlab = expression("Records used, " * italic(t)), ylab = expression(F[italic(t)]),
       main = main, cex.lab = 1.15)
  polygon(c(-9, 999, 999, -9), c(0.5, 0.5, 1, 1), col = rgb(1, 0, 0, 0.07), border = NA)
  abline(h = 1, lwd = 2, lty = 2)
}
draw <- function(e, g, en, col) {
  lines(en$t, en$F, col = "grey55", lwd = 1.8, lty = 3)
  lines(g$t, g$F, col = "#7570b3", lwd = 2, lty = 2)
  lines(e$t, e$F, col = col, lwd = 2.4); points(e$t, e$F, col = col, pch = 16, cex = .45)
}
frame(ei$t, "Itaja\u00ed wind gusts (n = 124)")
abline(v = 82, col = "grey40", lty = 3)
draw(ei, gi, ein, "#c1121f")
text(84, 0.78, "Apr 2017", col = "grey30", cex = .85, adj = 0)
legend("topright", c("EVBS, curvature-based", "GEV, curvature-based", "EVBS, naive (delete max)"),
       col = c("#c1121f", "#7570b3", "grey55"), lwd = c(2.4, 2, 1.8), lty = c(1, 2, 3),
       bty = "n", cex = .8)
frame(ef$t, "Fremantle sea levels (n = 86)")
abline(v = c(t_sw_e, t_sw_g), col = c("#1b7837", "#7570b3"), lty = 3)
draw(ef, gf, efn, "#1b7837")
text(41, 1.46, "flags minimum", col = "grey25", cex = .8, adj = 0, font = 3)
text(t_sw_g + 1, 1.46, "flags maximum", col = "grey25", cex = .8, adj = 0, font = 3)
text(t_sw_e - 0.5, 1.38, "EVBS", col = "#1b7837", cex = .75, adj = 1)
text(t_sw_g + 0.5, 1.38, "GEV", col = "#7570b3", cex = .75, adj = 0)
legend("bottomleft", c("EVBS, curvature-based", "GEV, curvature-based", "EVBS, naive (delete max)"),
       col = c("#1b7837", "#7570b3", "grey55"), lwd = c(2.4, 2, 1.8), lty = c(1, 2, 3),
       bty = "n", cex = .8)
dev.off()
cat(sprintf("\nswitch to the maximum at Fremantle: EVBS t = %d, GEV t = %d\n", t_sw_e, t_sw_g))
cat("fig/carta_combinada.png written\n")
