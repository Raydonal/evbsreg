# Density of the log-EVBS distribution (GAMLSS parametrization)

Density of the log-EVBS distribution (GAMLSS parametrization)

## Usage

``` r
dlogEVBS(x, mu = 0, sigma = 1, nu = 0, log = FALSE)

plogEVBS(q, mu = 0, sigma = 1, nu = 0, lower.tail = TRUE, log.p = FALSE)

qlogEVBS(p, mu = 0, sigma = 1, nu = 0, lower.tail = TRUE, log.p = FALSE)
```

## Arguments

- x, q, p:

  Vector of quantiles / probabilities.

- mu:

  Location on the log scale.

- sigma:

  Positive scale parameter.

- nu:

  Extreme-value shape parameter.

- log, log.p:

  Logical; return the log-density / log-probability.

- lower.tail:

  Logical; if `TRUE`, probabilities are \\P(Y \le y)\\.

## Value

A numeric vector.
