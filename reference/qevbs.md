# Quantile function of the Extreme-Value Birnbaum-Saunders distribution

Exact quantile function on the response scale. This is the function
needed to compute return levels; the generalized extreme-value
return-level formula does **not** apply to the EVBS response, since the
response is a monotone transformation of a GEV variate rather than a GEV
variate itself.

## Usage

``` r
qevbs(p, eta, alpha, gama)
```

## Arguments

- p:

  Vector of probabilities in \\(0,1)\\.

- eta:

  Location on the log scale, typically \\x^\top \beta\\.

- alpha:

  Positive shape (scale) parameter.

- gama:

  Extreme-value shape parameter.

## Value

A numeric vector of quantiles.

## Examples

``` r
# 50-year return level from monthly maxima: p = 1 - 1/(12*50)
qevbs(1 - 1 / 600, eta = 2.58, alpha = 0.19, gama = -0.16)
#> [1] 27.75714
```
