## Verifies every closed-form expression of the paper (v16) against central
## finite differences of the log-likelihood: the case-specific quantities
## (16)-(20) and their Gumbel forms, the three perturbation matrices (21)-(23),
## the Hessian of Section S3 (both gamma != 0 and gamma = 0), and the
## individual scores of Section S5 (GEV, generalized Pareto, EGPD).
## Also checks numerically Proposition 1 (extreme-value index of T) and the
## finiteness threshold of Proposition 2. Self-contained, base R only.
## Run from the project root: Rscript scripts/29_verifica_formulas.R
## Every line printed should read "OK"; the script stops otherwise.

set.seed(2026)
TOL <- 1e-6
check <- function(label, analytic, numeric) {
  e <- max(abs(analytic - numeric)) / max(abs(numeric))
  cat(sprintf("%-58s rel.err %.1e  %s\n", label, e, if (e < TOL) "OK" else "FAIL"))
  if (e >= TOL) stop("formula check failed: ", label)
}
cd1 <- function(f, x, h = 1e-6) sapply(seq_along(x), function(j) {
  e <- replace(0 * x, j, h); (f(x + e) - f(x - e)) / (2 * h) })

n <- 40
X <- cbind(1, runif(n), rnorm(n))          # p = 3, centred-ish design
p <- ncol(X)

## per-observation log-likelihood of Y = log T (eq. 8); gamma0 = Gumbel kernel
lli <- function(th, y, X, gamma0 = FALSE) {
  b <- th[1:p]; a <- th[p + 1]
  u <- as.vector(y - X %*% b); x1 <- (2/a) * cosh(u/2); x2 <- (2/a) * sinh(u/2)
  if (gamma0) return(-log(2) + log(x1) - x2 - exp(-x2))
  g <- th[p + 2]; r <- 1 + g * x2
  -log(2) + log(x1) - (1 + 1/g) * log(r) - r^(-1/g)
}
rlogevbs <- function(th, X, gamma0 = FALSE) {
  g <- if (gamma0) 0 else th[p + 2]; U <- runif(nrow(X))
  z <- if (g == 0) -log(-log(U)) else ((-log(U))^(-g) - 1) / g
  as.vector(X %*% th[1:p] + 2 * asinh(th[p + 1] * z / 2))
}

## case-specific quantities exactly as printed in Section 4.2
quant <- function(th, y, X, gamma0 = FALSE) {
  b <- th[1:p]; a <- th[p + 1]
  u <- as.vector(y - X %*% b); x1 <- (2/a) * cosh(u/2); x2 <- (2/a) * sinh(u/2)
  if (gamma0) {
    e <- exp(-x2)
    return(list(b = 0.5 * (x1 * (1 - e) - x2/x1), c = (x2 * (1 - e) - 1) / a,
                m = 0.25 * (1 - x2^2/x1^2 - x2 * (1 - e) - x1^2 * e),
                z = -x1 * (1 - e * (1 - x2)) / (2 * a), x1 = x1, x2 = x2))
  }
  g <- th[p + 2]; r <- 1 + g * x2; w <- r^(-1/g)
  list(b = 0.5 * (x1/r * (1 + g - w) - x2/x1),                                   # (16)
       c = (x2/r * (1 + g - w) - 1) / a,                                         # (16)
       d = (1 - w) * log(r) / g^2 - x2/(g * r) * (1 + g - w),                    # (17)
       m = 0.25 * (1 - x2^2/x1^2 - x2/r * (1 + g - w) + (1 + g) * x1^2/r^2 * (g - w)),   # (18)
       z = (-(x1/r) * (1 + g - w) + (1 + g) * x1 * x2/r^2 * (g - w)) / (2 * a),          # (19)
       v = 0.5 * ((x1/r) * (1 - w * log(r)/g^2) - (1 + g) * x1 * x2/r^2 * (1 - w/g)),    # (20)
       x1 = x1, x2 = x2, r = r, w = w)
}

## Hessian exactly as printed in Appendix C
hess <- function(th, y, X, gamma0 = FALSE) {
  q <- quant(th, y, X, gamma0); a <- th[p + 1]
  Lbb <- t(X) %*% (X * q$m); Lba <- t(X) %*% q$z
  if (gamma0) {
    e <- exp(-q$x2)
    Laa <- sum(1 - 2 * q$x2 * (1 - e) - q$x2^2 * e) / a^2
    return(rbind(cbind(Lbb, Lba), c(Lba, Laa)))
  }
  g <- th[p + 2]; r <- q$r; w <- q$w; qq <- q$x2 / r; A <- log(r)/g^2 - qq/g
  Lbg <- t(X) %*% q$v
  Laa <- sum(1 - 2 * qq * (1 + g - w) + (1 + g) * qq^2 * (g - w)) / a^2
  Lag <- sum(qq * (1 - w * log(r)/g^2) - (1 + g) * qq^2 * (1 - w/g)) / a
  Lgg <- sum(qq^2 + (1 - w) * (2 * qq/g^2 + qq^2/g - 2 * log(r)/g^3) - w * A^2)
  rbind(cbind(Lbb, Lba, Lbg), c(Lba, Laa, Lag), c(Lbg, Lag, Lgg))
}

cat("\n--- EVBS regression: score, Hessian, perturbation matrices ---\n")
for (cs in list(list(nm = "gamma = -0.20", th = c(1, 0.5, -0.3, 0.5, -0.20), g0 = FALSE),
                list(nm = "gamma = +0.15", th = c(1, 0.5, -0.3, 0.5,  0.15), g0 = FALSE),
                list(nm = "gamma = 0 (Gumbel)", th = c(1, 0.5, -0.3, 0.5), g0 = TRUE))) {
  th <- cs$th; g0 <- cs$g0; y <- rlogevbs(th, X, g0); k <- length(th)
  q <- quant(th, y, X, g0)
  ## score: individual contributions by finite differences, one per observation
  S_num <- sapply(seq_len(k), function(j) { e <- replace(0 * th, j, 1e-6)
    (lli(th + e, y, X, g0) - lli(th - e, y, X, g0)) / 2e-6 })            # n x k
  S_ana <- if (g0) cbind(X * q$b, q$c) else cbind(X * q$b, q$c, q$d)
  check(paste(cs$nm, "| individual scores (16)-(17), Delta (21)"), S_ana, S_num)
  ## Hessian
  H_num <- matrix(0, k, k); h <- 1e-4; L <- function(t) sum(lli(t, y, X, g0))
  for (i in 1:k) for (j in 1:k) { ei <- replace(0*th, i, h); ej <- replace(0*th, j, h)
    H_num[i, j] <- (L(th+ei+ej) - L(th+ei-ej) - L(th-ei+ej) + L(th-ei-ej)) / (4*h^2) }
  check(paste(cs$nm, "| Hessian, Appendix C"), hess(th, y, X, g0), H_num)
  ## response perturbation (22): Delta[, i] = d/d omega_i of d l_i / d theta
  ## mixed central second difference, one step for theta and omega
  ## (nested first differences with tiny steps leave ~1e-6 rounding noise)
  sy <- 0.7; hw <- 1e-4
  mixed <- function(i, pert) sapply(seq_len(k), function(j) { e <- replace(0*th, j, hw)
    (lli(th + e, pert(hw)$y, pert(hw)$X, g0)[i] - lli(th + e, pert(-hw)$y, pert(-hw)$X, g0)[i] -
     lli(th - e, pert(hw)$y, pert(hw)$X, g0)[i] + lli(th - e, pert(-hw)$y, pert(-hw)$X, g0)[i]) / (4 * hw^2) })
  Dnum <- sapply(seq_len(n), function(i)
    mixed(i, function(om) { yy <- y; yy[i] <- yy[i] + sy * om; list(y = yy, X = X) }))
  Dana <- -sy * (if (g0) rbind(t(X * q$m), q$z) else rbind(t(X * q$m), q$z, q$v))
  check(paste(cs$nm, "| response perturbation (22)"), Dana, Dnum)
  ## explanatory-variable perturbation (23), covariate t = 2
  tt <- 2; sx <- sd(X[, tt]); bt <- th[tt]
  Dnum <- sapply(seq_len(n), function(i)
    mixed(i, function(om) { XX <- X; XX[i, tt] <- XX[i, tt] + sx * om; list(y = y, X = XX) }))
  Db <- bt * t(X * q$m); Db[tt, ] <- Db[tt, ] + q$b
  Dana <- sx * (if (g0) rbind(Db, bt * q$z) else rbind(Db, bt * q$z, bt * q$v))
  check(paste(cs$nm, "| explanatory-variable perturbation (23)"), Dana, Dnum)
}

cat("\n--- Appendix D: individual scores of the benchmark families ---\n")
Xb <- cbind(1, rnorm(n))
## GEV
gev_lli <- function(par, y) { mu <- as.vector(Xb %*% par[1:2]); s <- par[3]; xi <- par[4]
  z <- (y - mu)/s; u <- 1 + xi*z; -log(s) - (1 + 1/xi)*log(u) - u^(-1/xi) }
pg <- c(2, 0.4, 0.8, -0.15); U <- runif(n)
yg <- as.vector(Xb %*% pg[1:2]) + pg[3] * ((-log(U))^(-pg[4]) - 1)/pg[4]
mu <- as.vector(Xb %*% pg[1:2]); z <- (yg - mu)/pg[3]; u <- 1 + pg[4]*z; w <- u^(-1/pg[4])
S_ana <- cbind(Xb * (pg[4] + 1 - w)/(pg[3]*u), -1/pg[3] + z*(pg[4] + 1 - w)/(pg[3]*u),
               (1 - w)/pg[4]^2*log(u) - z/u*(1 + (1 - w)/pg[4]))
S_num <- sapply(1:4, function(j) { e <- replace(0*pg, j, 1e-6); (gev_lli(pg+e, yg) - gev_lli(pg-e, yg))/2e-6 })
check("GEV individual scores (Appendix D)", S_ana, S_num)
## generalized Pareto
gp_lli <- function(par, y) { s <- exp(as.vector(Xb %*% par[1:2])); xi <- par[3]
  -log(s) - (1 + 1/xi)*log(1 + xi*y/s) }
pp <- c(0.3, 0.2, 0.15)
yp <- exp(as.vector(Xb %*% pp[1:2]))/pp[3] * ((1 - runif(n))^(-pp[3]) - 1)
s <- exp(as.vector(Xb %*% pp[1:2])); z <- yp/s; u <- 1 + pp[3]*z
S_ana <- cbind(Xb * ((pp[3] + 1)*z/u - 1), log(u)/pp[3]^2 - (pp[3] + 1)*z/(pp[3]*u))
S_num <- sapply(1:3, function(j) { e <- replace(0*pp, j, 1e-6); (gp_lli(pp+e, yp) - gp_lli(pp-e, yp))/2e-6 })
check("generalized Pareto individual scores (Appendix D)", S_ana, S_num)
## EGPD, model I: F(t) = H_xi(t/sigma)^kappa
egpd_lli <- function(par, y) { s <- exp(as.vector(Xb %*% par[1:2])); xi <- par[3]; ka <- par[4]
  z <- y/s; u <- 1 + xi*z; H <- 1 - u^(-1/xi)
  log(ka) + (ka - 1)*log(H) - log(s) - (1 + 1/xi)*log(u) }
pe <- c(0.5, 0.3, 0.1, 3)
ye <- exp(as.vector(Xb %*% pe[1:2])) * ((1 - runif(n)^(1/pe[4]))^(-pe[3]) - 1)/pe[3]
s <- exp(as.vector(Xb %*% pe[1:2])); xi <- pe[3]; ka <- pe[4]
z <- ye/s; u <- 1 + xi*z; H <- 1 - u^(-1/xi); hh <- u^(-1/xi - 1)
S_ana <- cbind(Xb * ((1 + xi)*z/u - 1 - (ka - 1)*z*hh/H),
               log(u)/xi^2 - (1 + xi)*z/(xi*u) - (ka - 1)*u^(-1/xi)/H*(log(u)/xi^2 - z/(xi*u)),
               1/ka + log(H))
S_num <- sapply(1:4, function(j) { e <- replace(0*pe, j, 1e-6); (egpd_lli(pe+e, ye) - egpd_lli(pe-e, ye))/2e-6 })
check("EGPD individual scores (Appendix D)", S_ana, S_num)

cat("\n--- Proposition 1: extreme-value index of T = h(X), X ~ GEV(0,1,gamma) ---\n")
hT <- function(x, a = 0.6, b = 2) b * exp(2 * asinh(a * x / 2))
SX <- function(x, g) -expm1(-pmax(1 + g*x, 0)^(-1/g))
for (g in c(0.3, 0.1)) { x <- 10^(5:7); sl <- diff(log(SX(x, g))) / diff(log(hT(x)))
  est <- -1/tail(sl, 1)
  cat(sprintf("gamma = %+.2f: estimated index %.4f, Proposition 1 gives 2*gamma = %.2f  %s\n",
              g, est, 2*g, if (abs(est - 2*g) < 1e-3) "OK" else "FAIL")) }
for (g in c(-0.2, -0.4)) { xs <- -1/g; x <- xs - 10^-(3:5)
  sl <- diff(log(SX(x, g))) / diff(log(hT(xs) - hT(x))); est <- -1/tail(sl, 1)
  cat(sprintf("gamma = %+.2f: estimated index %.4f, Proposition 1 gives gamma = %.2f  %s\n",
              g, est, g, if (abs(est - g) < 1e-3) "OK" else "FAIL")) }
x <- c(10, 20, 40); rX <- -expm1(-exp(-x)) / exp(-x - exp(-x))
rT <- function(x) { rX <- -expm1(-exp(-x)) / exp(-x - exp(-x)); rX * 0.6 * hT(x) / sqrt(1 + (0.3*x)^2) }
d <- 1e-4; rTp <- (rT(x + d) - rT(x - d)) / (hT(x + d) - hT(x - d))
cat(sprintf("gamma =  0.00: r_T'(t) at x = 10, 20, 40: %s (-> 0, index 0)  %s\n",
            paste(signif(rTp, 3), collapse = ", "), if (all(diff(rTp) < 0) && tail(rTp, 1) < 0.03) "OK" else "FAIL"))

cat("\n--- Proposition 2: E(s_eta^2) as gamma crosses -1/2 (V ~ Exp(1)) ---\n")
seta2 <- function(g, a = 0.5, eps) integrate(function(v) {
  X <- (v^(-g) - 1)/g; x1 <- sqrt(4/a^2 + X^2)
  (0.5 * (x1 * (1 + g - v) * v^g - X/x1))^2 * exp(-v) }, eps, Inf, subdivisions = 5000)$value
for (g in c(-0.40, -0.45, -0.55)) {
  v <- sapply(c(1e-4, 1e-8, 1e-12), function(e)
    tryCatch(seta2(g, eps = e), error = function(err) Inf))
  ## near -1/2 the remainder decays like eps^(1 + 2 gamma): slow but shrinking
  ok <- if (g > -0.5) (v[3] - v[2]) < (v[2] - v[1]) else (v[3] > 10 * v[1])
  cat(sprintf("gamma = %+.2f: E(s_eta^2) truncated at V > 1e-4, 1e-8, 1e-12: %s  -> %s  %s\n", g,
      paste(signif(v, 4), collapse = ", "), if (g > -0.5) "converges" else "diverges",
      if (ok) "OK" else "FAIL")) }

cat("\n--- Proposition 3: the maximum of n iid EVBS is not EVBS ---\n")
## exact quantiles of M_n = h(mu_n + sigma_n X) versus the closest EVBS(a', b', g')
hq <- function(x, a, b) b * exp(2 * asinh(a * x / 2))
zq <- function(p, g) if (g == 0) -log(-log(p)) else ((-log(p))^(-g) - 1) / g
pp <- seq(0.001, 0.999, length.out = 2000)
for (g in c(-0.2, 0, 0.2)) for (nn in c(1, 12)) {
  mu <- if (g == 0) log(nn) else (nn^g - 1)/g; sg <- if (g == 0) 1 else nn^g
  qmax <- hq(mu + sg * zq(pp, g), 0.5, 1)
  obj <- function(th) { q <- hq(zq(pp, th[3]), exp(th[1]), exp(th[2]))
    if (any(!is.finite(q))) return(1e10); mean((log(q) - log(qmax))^2) }
  o <- optim(c(log(0.5 * sg), 0, g), obj, control = list(maxit = 5000, reltol = 1e-14))
  o <- optim(o$par, obj, method = "BFGS", control = list(reltol = 1e-14))
  ok <- if (nn == 1) o$value < 1e-12 else o$value > 1e-7
  cat(sprintf("gamma = %+.1f, n = %2d: rms log-quantile error of closest EVBS %.1e (gamma' = %+.3f)  %s\n",
      g, nn, sqrt(o$value), o$par[3], if (ok) "OK" else "FAIL"))
}
