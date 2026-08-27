# The log-EVBS distribution for GAMLSS models

Defines the log-Extreme-Value Birnbaum-Saunders distribution as a
three-parameter gamlss family, so that each parameter may depend on
covariates through a linear predictor or a smooth term. This is the
natural way to let the tail-shape parameter vary with covariates, which
the fixed three-parameter fit of
[`evbsreg.fit`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.md)
does not allow.

## Usage

``` r
logEVBS(mu.link = "identity", sigma.link = "log", nu.link = "identity")
```

## Arguments

- mu.link:

  Link for the location parameter \\\mu\\ (default `"identity"`; the
  predictor is on the log-response scale).

- sigma.link:

  Link for the scale parameter \\\alpha \> 0\\ (default `"log"`).

- nu.link:

  Link for the extreme-value shape parameter \\\gamma\\ (default
  `"identity"`).

## Value

A `gamlss.family` object.

## Details

The response is \\Y = \log T\\ where \\T\\ follows the EVBS
distribution, so that \\Z = (2/\sigma)\sinh\\(Y-\mu)/2\\ \sim
\mathrm{GEV}(0,1,\nu)\\. The parameter map is \\\mu = \eta =
x^\top\beta\\ (identity link), \\\sigma = \alpha\\ (log link, positive)
and \\\nu = \gamma\\ (identity link, real-valued).

With a constant predictor the fitted \\(\mu, \sigma, \nu)\\ reproduce
the \\(\eta, \alpha, \gamma)\\ of
[`evbsreg.fit`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.md);
this equivalence is the recommended check after loading the family. The
score and second-order derivatives required by gamlss are obtained by
automatic numerical differentiation of the analytic log-density, which
is exact to working precision and avoids transcription error in the
lengthy closed forms.

## Examples

``` r
if (FALSE) { # \dontrun{
  library(gamlss)
  data(itajai)
  y <- log(itajai$wind)
  # constant model: should match evbsreg.fit on the log scale
  m0 <- gamlss(y ~ 1, family = logEVBS())
  # tail shape depending on pressure:
  m1 <- gamlss(y ~ pressure, nu.formula = ~ pressure,
               data = itajai, family = logEVBS())
} # }
```
