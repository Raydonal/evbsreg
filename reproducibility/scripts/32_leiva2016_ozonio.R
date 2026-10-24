## Table S8 of the Supplementary Material (v16), last row: refit of the La Calera
## ozone example of Leiva, Ferreira, Gomes & Lillo (2016, SERRA 30:1045-1058,
## Sec. 4; data in their Appendix 2). Their estimates come from the joint maximum
## likelihood fit of all four parameters (BFGS on the full log-likelihood), which
## evbsreg.fit() reproduces to the four decimals they report, log-likelihood
## included. Their standard errors are larger than those of the observed
## information, which the numerical Hessian confirms. A two-stage fit (beta and
## alpha with gamma = 0, then gamma) does NOT reproduce their numbers.
## Self-contained. Run from the repository root: Rscript scripts/32_leiva2016_ozonio.R
.libPaths(c("~/R/libs", .libPaths()))
suppressMessages(library(evbsreg)); options(warn = -1)

## daily maximum ozone (ppb) and daily maximum temperature (C), 17/09-19/10/2005
t <- c(14.290, 40.820, 40.310, 45.920, 8.163, 13.270, 11.220, 21.940, 14.800,
       20.920, 38.270, 32.650, 41.330, 46.430, 42.860, 23.980, 27.040, 34.180,
       20.410, 11.730, 36.220, 11.220, 31.120, 13.270, 13.270, 16.330, 19.900,
       14.800, 15.820, 14.800, 14.800, 18.370, 8.673)
x <- c(16.8, 24.2, 22.9, 22.5, 15.8, 17.2, 14.8, 18.5, 16.4, 19.8, 26.5, 18.1,
       19.1, 22.2, 21.4, 21.3, 25.5, 20.3, 15.7, 16.2, 22.7, 16.8, 22.5, 17.0,
       16.5, 17.6, 16.8, 17.9, 18.4, 18.7, 19.9, 17.1, 15.4)
X <- cbind(1, x); y <- log(t)
cat(sprintf("n = %d | mean %.3f, median %.3f, SD %.3f (their Table 5: 23.610, 19.900, 12.141)\n",
            length(t), mean(t), median(t), sd(t)))

## log-likelihood of Y = log T, their eq. (6)
ll <- function(p) {
  b <- p[1:2]; a <- p[3]; g <- p[4]
  if (a <= 0) return(-Inf)
  x1 <- (y - X %*% b)/2; x2 <- (2/a)*sinh(x1)
  if (abs(g) < 1e-8) lg <- -x2 - exp(-x2) else {
    z <- 1 + g*x2; if (any(z <= 0)) return(-Inf)
    lg <- -(1 + 1/g)*log(z) - z^(-1/g)
  }
  sum(-log(a) + log(cosh(x1)) + lg)
}

fit <- evbsreg.fit(X, t)
th  <- c(fit$betahat, fit$alphahat, fit$gamahat)
se  <- c(fit$stderrors, fit$stderroralpha, fit$stderrorgama)
seH <- sqrt(diag(solve(optimHess(th, function(p) -ll(p)))))
pub <- c(0.4524, 0.1280, 0.2835, -0.1511); pub_se <- c(0.3087, 0.0166, 0.0807, 0.2109)
tab <- rbind("joint MLE (evbsreg)" = th, "Leiva et al. (2016)" = pub,
             "SE, observed information" = se, "SE, numerical Hessian" = seH,
             "SE, Leiva et al. (2016)" = pub_se)
colnames(tab) <- c("beta0", "beta1", "alpha", "gamma")
print(round(tab, 4))
cat(sprintf("max |estimate - published| = %.1e | log-likelihood %.4f (published -7.4012)\n",
            max(abs(round(th, 4) - pub)), ll(th)))

## the two-stage procedure (beta, alpha under gamma = 0, then gamma given them)
s1 <- optim(th[1:3], function(p) -ll(c(p, 0)))
s2 <- optimize(function(g) -ll(c(s1$par, g)), c(-0.5, 0.5))
cat("two-stage fit:", round(c(s1$par, s2$minimum), 4), "(does not reproduce)\n")
