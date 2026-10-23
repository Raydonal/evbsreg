# evbsreg

**Local influence diagnostics for the Extreme-Value Birnbaum–Saunders
(EVBS) regression model.**

It provides joint maximum likelihood estimation, conformal normal
curvature (CNC) diagnostics under three perturbation schemes, randomized
quantile residuals with simulation envelope, the EVBS distribution
family (density, distribution, quantile), the finite upper endpoint,
return levels and expected shortfall, moving-block bootstrap standard
errors, and the same local influence diagnostics for the generalized
extreme-value (GEV) regression model, used as a benchmark.
[`evbs_monitor()`](https://raydonal.github.io/evbsreg/reference/evbs_monitor.md)
combines the curvature diagnostic with the finite upper endpoint into a
prospective index of endpoint identifiability with a natural control
limit. See `NEWS.md` for the changelog and the vignette for a
reproducible walk-through.

The methodology is described in

> Ospina, R., Lima, J. I. C., Barros, M., and Macêdo, A. M. S. (2026).
> *Local influence diagnostics for extreme-value Birnbaum–Saunders
> regression, with an application to wind-gust extremes.* Submitted.
> Preliminary version:
> [arXiv:2507.22967](https://arxiv.org/abs/2507.22967).

## Installation

From CRAN:

``` r

install.packages("evbsreg")
```

Or the development version from GitHub:

``` r

# install.packages("remotes")
remotes::install_github("Raydonal/evbsreg")
```

Dependencies: `ggplot2` (density plots) besides base R. `gamlss` is
needed only to fit the optional
[`logEVBS()`](https://raydonal.github.io/evbsreg/reference/logEVBS.md)
family with the `gamlss` package itself.

## Quick start

``` r

library(evbsreg)
data(itajai)

# 1. Fit the EVBS regression model
X   <- cbind(1, itajai$pressure)
fit <- evbsreg.fit(X, itajai$wind)
round(fit$coeff, 4)

# 2. Local influence diagnostics
diag <- cnc_diagnostics(fit)
plot_cnc(diag, q = 7)

# 3. Most influential observation
which(diag$Bj[7, ] > diag$bq[7])

# 4. Refit without it and measure the impact
fit82 <- evbsreg.fit(X[-82, ], itajai$wind[-82])
round(100 * (fit82$coeff - fit$coeff) / abs(fit$coeff), 2)
```

The tail-shape parameter changes by about **−73.67%** when the
catastrophic event of 26 April 2017 (observation 82) is removed, while
the regression structure remains stable.

## Main functions

| Function | Purpose |
|----|----|
| [`evbsreg.fit()`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.md) | Joint maximum likelihood fit of the EVBS regression model |
| [`cnc_diagnostics()`](https://raydonal.github.io/evbsreg/reference/cnc_diagnostics.md) | Conformal normal curvature diagnostics |
| [`plot_cnc()`](https://raydonal.github.io/evbsreg/reference/plot_cnc.md) | Two-panel diagnostic figure (eigenvalues + contributions) |
| [`rqrandomized()`](https://raydonal.github.io/evbsreg/reference/rqrandomized.md), [`rcoxsnell()`](https://raydonal.github.io/evbsreg/reference/rcoxsnell.md) | Quantile and Cox–Snell residuals |
| [`envelope_qq()`](https://raydonal.github.io/evbsreg/reference/envelope_qq.md) | Normal probability plot with simulation envelope |
| [`revbs()`](https://raydonal.github.io/evbsreg/reference/revbs.md), [`devbs()`](https://raydonal.github.io/evbsreg/reference/devbs.md), [`pevbs()`](https://raydonal.github.io/evbsreg/reference/pevbs.md), [`qevbs()`](https://raydonal.github.io/evbsreg/reference/qevbs.md) | EVBS density, distribution, quantile, and random generation |
| [`evbs_endpoint()`](https://raydonal.github.io/evbsreg/reference/evbs_endpoint.md) | Finite upper endpoint of the fitted model (Weibull domain) |
| [`evbs_return_level()`](https://raydonal.github.io/evbsreg/reference/evbs_return_level.md) | Return levels and expected shortfall from the EVBS quantile function |
| [`evbs_block_boot()`](https://raydonal.github.io/evbsreg/reference/evbs_block_boot.md) | Moving-block bootstrap standard errors for serially dependent series |
| [`evbsreg.fit.mc()`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.mc.md) | Monte Carlo simulation study |
| [`plot_evbs_alpha()`](https://raydonal.github.io/evbsreg/reference/plot_evbs_alpha.md) … | Density plots (Figures 1–2 of the paper) |
| [`gevreg.fit()`](https://raydonal.github.io/evbsreg/reference/gevreg.fit.md), [`gev_scores()`](https://raydonal.github.io/evbsreg/reference/gev_scores.md), [`cnc_diagnostics_gev()`](https://raydonal.github.io/evbsreg/reference/cnc_diagnostics_gev.md) | GEV regression fit and matching local influence diagnostics |
| [`logEVBS()`](https://raydonal.github.io/evbsreg/reference/logEVBS.md), [`dlogEVBS()`](https://raydonal.github.io/evbsreg/reference/logEVBS-dist.md), [`plogEVBS()`](https://raydonal.github.io/evbsreg/reference/logEVBS-dist.md), [`qlogEVBS()`](https://raydonal.github.io/evbsreg/reference/logEVBS-dist.md) | `gamlss.family` for a log-EVBS model with covariate-dependent shape |
| [`evbs_monitor()`](https://raydonal.github.io/evbsreg/reference/evbs_monitor.md), [`plot.evbs_monitor()`](https://raydonal.github.io/evbsreg/reference/plot.evbs_monitor.md) | Prospective endpoint-identifiability control chart |

See
[`vignette("evbsreg")`](https://raydonal.github.io/evbsreg/articles/evbsreg.md)
for the full worked example.

## Reproducing the paper

Five standalone scripts reproduce every figure, table, and simulation:

``` r

source(system.file("scripts/script_01_density_figures.R",    package = "evbsreg"))
source(system.file("scripts/script_02_itajai_application.R", package = "evbsreg"))
source(system.file("scripts/script_03_simulation_scenario1.R", package = "evbsreg"))
source(system.file("scripts/script_04_simulation_scenario2.R", package = "evbsreg"))
source(system.file("scripts/script_05_simulation_scenario3.R", package = "evbsreg"))
```

Each simulation script defaults to `m = 5000` replicates (matching the
paper). Set `m <- 500` at the top of a script for a quick check.

## Documentation

Full documentation, including the reference index and the “Get started”
vignette, is available at the package website:
<https://raydonal.github.io/evbsreg/>.

## License

MIT © Raydonal Ospina
