# Changelog

## evbsreg 1.2.0

### New features

- [`evbs_monitor()`](https://raydonal.github.io/evbsreg/reference/evbs_monitor.md)
  computes the prospective endpoint-identifiability index $`F_t`$,
  combining the conformal normal curvature with the finite upper
  endpoint, and
  [`plot.evbs_monitor()`](https://raydonal.github.io/evbsreg/reference/plot.evbs_monitor.md)
  draws the corresponding control chart. Values below one indicate that
  the endpoint is determined by a single observation and should not be
  quoted as a design value.

## evbsreg 1.1.0

### New features

- [`logEVBS()`](https://raydonal.github.io/evbsreg/reference/logEVBS.md)
  provides a `gamlss.family` implementation of the log-EVBS
  distribution, allowing every parameter, including the tail-shape
  parameter, to depend on covariates or smooth terms. With a constant
  predictor it reproduces the fixed-parameter fit of
  [`evbsreg.fit()`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.md).
  Companion functions
  [`dlogEVBS()`](https://raydonal.github.io/evbsreg/reference/logEVBS-dist.md),
  [`plogEVBS()`](https://raydonal.github.io/evbsreg/reference/logEVBS-dist.md)
  and
  [`qlogEVBS()`](https://raydonal.github.io/evbsreg/reference/logEVBS-dist.md)
  are also provided.
- [`devbs()`](https://raydonal.github.io/evbsreg/reference/devbs.md),
  [`pevbs()`](https://raydonal.github.io/evbsreg/reference/pevbs.md) and
  [`qevbs()`](https://raydonal.github.io/evbsreg/reference/qevbs.md)
  complete the distribution family. The package previously exported only
  [`revbs()`](https://raydonal.github.io/evbsreg/reference/revbs.md), so
  users had no way to compute quantiles or return levels.
- [`evbs_endpoint()`](https://raydonal.github.io/evbsreg/reference/evbs_endpoint.md)
  returns the finite upper endpoint of the fitted model when `gama < 0`
  (Weibull max-domain of attraction).
- [`evbs_return_level()`](https://raydonal.github.io/evbsreg/reference/evbs_return_level.md)
  computes return levels and expected shortfall from the exact EVBS
  quantile function.
- [`gevreg.fit()`](https://raydonal.github.io/evbsreg/reference/gevreg.fit.md),
  [`gev_scores()`](https://raydonal.github.io/evbsreg/reference/gev_scores.md)
  and
  [`cnc_diagnostics_gev()`](https://raydonal.github.io/evbsreg/reference/cnc_diagnostics_gev.md)
  extend the local influence framework to the generalized extreme-value
  regression model.
- [`evbs_block_boot()`](https://raydonal.github.io/evbsreg/reference/evbs_block_boot.md)
  provides moving-block bootstrap standard errors for series with
  residual serial dependence.

### Important notes

- The extreme-value index of the EVBS *response* is `2 * gama`, not
  `gama`. The transformation preserves the max-domain of attraction but
  doubles the tail index. Documentation updated accordingly.
- The GEV return-level formula does **not** apply to the EVBS response.
  Use [`qevbs()`](https://raydonal.github.io/evbsreg/reference/qevbs.md)
  or
  [`evbs_return_level()`](https://raydonal.github.io/evbsreg/reference/evbs_return_level.md).
- [`gevreg.fit()`](https://raydonal.github.io/evbsreg/reference/gevreg.fit.md)
  centres are strongly recommended: the GEV likelihood is poorly
  conditioned for uncentred covariates and may silently fail to
  converge.

## evbsreg 1.0.0

CRAN release: 2026-06-30

### New Features

- **Initial CRAN Release** - Complete implementation of local influence
  diagnostics for Extreme-Value Birnbaum-Saunders (EVBS) regression
  models

- **Estimation** -
  [`evbsreg.fit()`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.md)
  function for joint maximum likelihood estimation of EVBS regression
  models with flexible parameter specification

- **Diagnostics** - Conformal normal curvature-based local influence
  diagnostics under three perturbation schemes:

  - Case-weight perturbation
  - Response variable perturbation
  - Explanatory variable perturbation

- **Residuals** - Randomized quantile residuals
  ([`rcoxsnell()`](https://raydonal.github.io/evbsreg/reference/rcoxsnell.md),
  [`rqrandomized()`](https://raydonal.github.io/evbsreg/reference/rqrandomized.md))
  with simulation envelopes for model validation

- **Visualization** - Publication-quality diagnostic and density plots:

  - [`plot_cnc()`](https://raydonal.github.io/evbsreg/reference/plot_cnc.md)
    for local influence plots
  - [`envelope_qq()`](https://raydonal.github.io/evbsreg/reference/envelope_qq.md)
    for quantile-quantile plots with envelopes
  - [`plot_evbs_alpha()`](https://raydonal.github.io/evbsreg/reference/plot_evbs_alpha.md)
    and
    [`plot_evbs_gama()`](https://raydonal.github.io/evbsreg/reference/plot_evbs_gama.md)
    for parameter density visualization
  - [`plot_aggregate_contributions()`](https://raydonal.github.io/evbsreg/reference/plot_aggregate_contributions.md)
    for influence aggregation
  - [`plot_normalized_eigenvalues()`](https://raydonal.github.io/evbsreg/reference/plot_normalized_eigenvalues.md)
    for eigenvalue analysis

- **Monte Carlo Utilities** -
  [`generate_evbs_data()`](https://raydonal.github.io/evbsreg/reference/generate_evbs_data.md)
  and
  [`generate_logevbs_data()`](https://raydonal.github.io/evbsreg/reference/generate_logevbs_data.md)
  for simulation studies

- **Random Number Generation** -
  [`revbs()`](https://raydonal.github.io/evbsreg/reference/revbs.md) for
  generating random variates from EVBS distributions with flexible GEV
  parent distributions

### Methodology

The methods implemented in this package are described in: - Ospina,
Lima, Barros, and Macedo (2026, submitted)

Application to real-world data: - Monthly maximum wind gust data from
Itajai, Brazil (included in `itajai` dataset)

### Documentation

- Complete function reference with examples
- Comprehensive vignette demonstrating workflow on real data
- CITATION file with proper attribution

### Dependencies

- **Imports**: stats, graphics, SpatialExtremes, ggplot2
- **Suggests**: gamlss, grDevices, knitr, rmarkdown, testthat

------------------------------------------------------------------------

For more information, visit: <https://raydonal.github.io/evbsreg/>
