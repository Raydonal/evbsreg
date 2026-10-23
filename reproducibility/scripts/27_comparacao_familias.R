## Table 7 of the paper (v16): EVBS vs GEV vs EGPD on both records, with the Vuong
## tests, plus the verification of the closed-form generalized Pareto score of
## Section S5 of the Supplementary Material.
## Self-contained. Run from the repository root: Rscript scripts/27_comparacao_familias.R
.libPaths(c("~/R/libs", .libPaths()))
suppressMessages(library(evbsreg)); options(warn = -1)
if (!requireNamespace("ismev", quietly = TRUE))
  stop("install the 'ismev' package for the Fremantle case study")

data(itajai)
Xi  <- cbind(1, itajai$pressure)                       # EVBS: uncentred is fine
Xic <- cbind(1, itajai$pressure - mean(itajai$pressure))  # GEV/EGPD: centre
yi  <- itajai$wind
data(fremantle, package = "ismev")
fremantle$tt <- (fremantle$Year - mean(fremantle$Year)) / 100
Xf <- cbind(1, fremantle$SOI, fremantle$tt); yf <- fremantle$SeaLevel

## ---- EVBS log-likelihood on the RESPONSE scale (Jacobian of Y = log T) ----
evbs_ll_T <- function(fit, X, t) {
  y <- log(t); mu <- as.vector(X %*% fit$betahat)
  a <- fit$alphahat; g <- fit$gamahat
  x1 <- (2/a)*cosh((y-mu)/2); x2 <- (2/a)*sinh((y-mu)/2); u <- 1 + g*x2
  sum(-log(2) + log(x1) + (-1-1/g)*log(u) - u^(-1/g)) - sum(log(t))
}

## ---- EGPD, Naveau et al. (2016) model I: F(t) = {H_xi(t/sigma)}^kappa ----
egpd_lli <- function(par, X, y) {
  p <- ncol(X); b <- par[1:p]; xi <- par[p+1]; kap <- exp(par[p+2])
  s <- exp(as.vector(X %*% b)); z <- y/s; u <- 1 + xi*z
  if (any(u <= 0)) return(rep(-1e6, length(y)))
  H <- 1 - u^(-1/xi); if (any(H <= 0)) return(rep(-1e6, length(y)))
  log(kap) + (kap-1)*log(H) + (-1/xi - 1)*log(u) - log(s)
}
fit_egpd <- function(X, y) {
  p <- ncol(X); nll <- function(q) -sum(egpd_lli(q, X, y)); best <- NULL
  for (xi0 in c(-0.2, -0.05, 0.05, 0.2, 0.4)) for (lk0 in c(0, 1, 2, 3, 5)) {
    st <- c(log(mean(y)), rep(0, p-1), xi0, lk0)
    o <- try(optim(st, nll, method = "Nelder-Mead",
                   control = list(maxit = 50000, reltol = 1e-13)), silent = TRUE)
    if (inherits(o, "try-error")) next
    o2 <- try(optim(o$par, nll, method = "BFGS",
                    control = list(maxit = 50000, reltol = 1e-14)), silent = TRUE)
    if (!inherits(o2, "try-error") && o2$value < o$value) o <- o2
    if (o$value < 1e5 && (is.null(best) || o$value < best$value)) best <- o
  }
  best
}

## ---- Case-weight curvature from individual log-likelihood contributions ----
## F = Delta' (-L)^{-1} Delta with Delta the matrix of individual scores
## (case-weight perturbation), by central differences. Use a centred design:
## with uncentred covariates (pressure ~ 1000 mb) the finite-difference
## Hessian loses about two digits and Bbar_j moves in the second decimal.
F_generic <- function(lli, par, h = 1e-5) {
  k <- length(par)
  S <- sapply(seq_len(k), function(a) { e <- replace(0 * par, a, h)
    (lli(par + e) - lli(par - e)) / (2 * h) })                 # n x k
  L <- matrix(0, k, k)
  for (a in seq_len(k)) for (b in seq_len(k)) {
    ea <- replace(0 * par, a, h); eb <- replace(0 * par, b, h)
    L[a, b] <- (sum(lli(par+ea+eb)) - sum(lli(par+ea-eb)) -
                sum(lli(par-ea+eb)) + sum(lli(par-ea-eb))) / (4 * h^2) }
  S %*% solve(-L) %*% t(S)
}
## Mean aggregate contribution Bbar_j of eq. (26): average of B_j(q), q = 1..7,
## and of the unthresholded B_j^inf. Same definition as colMeans(cnc_diagnostics(fit)$Bj).
## Up to v11 this table compared Bbar_j (EVBS) with diag(F)/tr(F) (GEV) and
## with B_j(7) forced to at least one direction (EGPD): three different
## statistics. All three families now use Bbar_j.
bbar <- function(F) {
  n <- nrow(F); ev <- eigen((F + t(F)) / 2, symmetric = TRUE)
  ls <- abs(ev$values) / sqrt(sum(ev$values^2)); A2 <- ev$vectors^2
  Bq <- sapply(1:7, function(q) A2 %*% ifelse(ls > q / sqrt(n), ls, 0))
  rowMeans(cbind(Bq, A2 %*% ls))
}
gev_lli <- function(par, X, y) {
  p <- ncol(X); mu <- as.vector(X %*% par[1:p]); s <- exp(par[p+1]); xi <- par[p+2]
  u <- 1 + xi * (y - mu) / s
  if (any(u <= 0)) return(rep(-1e6, length(y)))
  -log(s) - (1 + 1/xi) * log(u) - u^(-1/xi)
}
lead <- function(B) { o <- order(B, decreasing = TRUE)
  sprintf("#%d (%.3f; next #%d %.3f)", o[1], B[o[1]], o[2], B[o[2]]) }

cat("\n=== Table 6: three families, matched parameters, response scale ===\n")
cat("Tail index of the response: gamma for the EVBS when gamma < 0 (2*gamma only\n")
cat("when gamma > 0; Ferreira, Gomes & Leiva 2012, Thms 4.1-4.2); xi for GEV/EGPD.\n")
for (nm in c("Itajai", "Fremantle")) {
  if (nm == "Itajai") { Xe <- Xi; Xg <- Xic; y <- yi } else { Xe <- Xf; Xg <- Xf; y <- yf }
  k <- ncol(Xe) + 2
  fe <- evbsreg.fit(Xe, y);  lle <- evbs_ll_T(fe, Xe, y)
  fg <- gevreg.fit(Xg, y)
  fp <- fit_egpd(Xg, y);     llp <- -fp$value
  Be <- colMeans(cnc_diagnostics(fe)$Bj)
  Bg <- bbar(F_generic(function(q) gev_lli(q, Xg, y), c(fg$beta, log(fg$sigma), fg$xi)))
  Bp <- bbar(F_generic(function(q) egpd_lli(q, Xg, y), fp$par))
  ev_evbs <- if (fe$gamahat < 0) fe$gamahat else 2 * fe$gamahat
  cat(sprintf("\n%s (n = %d, %d free parameters per family)\n", nm, length(y), k))
  cat(sprintf("  EVBS  loglik %9.3f  AIC %8.2f  EV index %+.4f  lead %s\n",
      lle, -2*lle + 2*k, ev_evbs, lead(Be)))
  cat(sprintf("  GEV   loglik %9.3f  AIC %8.2f  EV index %+.4f  lead %s  rho %.3f\n",
      fg$loglik, -2*fg$loglik + 2*k, fg$xi, lead(Bg), cor(Be, Bg, method = "spearman")))
  cat(sprintf("  EGPD  loglik %9.3f  AIC %8.2f  EV index %+.4f  lead %s  rho %.3f  kappa %.0f\n",
      llp, -2*llp + 2*k, fp$par[ncol(Xg)+1], lead(Bp),
      cor(Be, Bp, method = "spearman"), exp(fp$par[ncol(Xg)+2])))
  ## Vuong (1989) test for non-nested models: d_i = l_i(EVBS) - l_i(other), all on
  ## the response scale. Equal parameter counts, so no penalty correction.
  lle_i <- function() { yy <- log(y); mu <- as.vector(Xe %*% fe$betahat)
    a <- fe$alphahat; g <- fe$gamahat
    x1 <- (2/a)*cosh((yy-mu)/2); x2 <- (2/a)*sinh((yy-mu)/2); u <- 1 + g*x2
    -log(2) + log(x1) - (1 + 1/g)*log(u) - u^(-1/g) - log(y) }
  le <- lle_i()
  lg <- gev_lli(c(fg$beta, log(fg$sigma), fg$xi), Xg, y)
  lp <- egpd_lli(fp$par, Xg, y)
  vu <- function(d) { z <- sqrt(length(d)) * mean(d) / sd(d); c(z = z, p = 2 * pnorm(-abs(z))) }
  v1 <- vu(le - lg); v2 <- vu(le - lp)
  cat(sprintf("  check: sum of individual logliks EVBS %.3f GEV %.3f EGPD %.3f\n", sum(le), sum(lg), sum(lp)))
  cat(sprintf("  Vuong EVBS vs GEV : z = %+.2f, p = %.2f | EVBS vs EGPD: z = %+.2f, p = %.2f\n",
      v1["z"], v1["p"], v2["z"], v2["p"]))
}

cat("\n=== Verification of the generalized Pareto score, equation (19) ===\n")
gp_lli <- function(par, X, y) { p <- ncol(X); b <- par[1:p]; xi <- par[p+1]
  s <- exp(as.vector(X %*% b)); u <- 1 + xi*(y/s)
  if (any(u <= 0)) return(rep(-1e6, length(y)))
  -log(s) - (1 + 1/xi)*log(u) }
gp_score <- function(par, X, y) { p <- ncol(X); b <- par[1:p]; xi <- par[p+1]
  s <- exp(as.vector(X %*% b)); z <- y/s; u <- 1 + xi*z
  cbind(((xi+1)*z/u - 1) * X, log(u)/xi^2 - (xi+1)*z/(xi*u)) }
set.seed(1); n <- 40; Xg <- cbind(1, rnorm(n)); pg <- c(0.3, 0.2, 0.15)
yg <- (exp(as.vector(Xg %*% pg[1:2]))/pg[3]) * ((1-runif(n))^(-pg[3]) - 1)
num <- t(sapply(seq_len(n), function(i)
  sapply(seq_along(pg), function(a) { e <- rep(0, length(pg)); e[a] <- 1e-6
    (gp_lli(pg+e, Xg, yg)[i] - gp_lli(pg-e, Xg, yg)[i])/2e-6 })))
cat(sprintf("max |analytic - numerical| over all cases and parameters = %.3e\n",
            max(abs(num - gp_score(pg, Xg, yg)))))
