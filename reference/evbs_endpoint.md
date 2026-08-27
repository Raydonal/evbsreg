# Finite upper endpoint of the EVBS distribution

When \\\gamma \< 0\\ the EVBS lies in the Weibull max-domain of
attraction and its support is bounded above. The endpoint is the largest
response the fitted model regards as possible, and is therefore the
quantity of primary interest in design applications. It is also highly
sensitive to individual observations, which is what the local influence
diagnostics in this package are designed to detect.

## Usage

``` r
evbs_endpoint(eta, alpha, gama)
```

## Arguments

- eta:

  Location on the log scale, typically \\x^\top \beta\\.

- alpha:

  Positive shape (scale) parameter.

- gama:

  Extreme-value shape parameter.

## Value

The finite upper endpoint, or `Inf` when \\\gamma \ge 0\\.

## Examples

``` r
evbs_endpoint(eta = 2.58, alpha = 0.19, gama = -0.16)
#> [1] 40.72802
evbs_endpoint(eta = 2.58, alpha = 0.19, gama = 0.10) # Inf
#> [1] Inf
```
