# Density of the Extreme-Value Birnbaum-Saunders distribution

Probability density function of the EVBS distribution on the response
(positive) scale. The EVBS variate \\T\\ satisfies \\Z =
(2/\alpha)\\\sinh\\(\log T - \eta)/2\\ \sim \mathrm{GEV}(0,1,\gamma)\\.

## Usage

``` r
devbs(t, eta, alpha, gama, log = FALSE)
```

## Arguments

- t:

  Vector of positive quantiles.

- eta:

  Location on the log scale, typically \\x^\top \beta\\.

- alpha:

  Positive shape (scale) parameter.

- gama:

  Extreme-value shape parameter.

- log:

  Logical; if `TRUE`, the log-density is returned.

## Value

A numeric vector of (log-)density values.

## Details

The response \\T\\ lies in the same max-domain of attraction as the GEV
variate. Its extreme-value index is \\2\gamma\\ when \\\gamma \> 0\\,
because \\T \approx \beta\alpha^2 Z^2\\ in the upper tail, and
\\\gamma\\ itself when \\\gamma \le 0\\: near a finite endpoint the
transformation is locally linear (Ferreira, Gomes and Leiva, 2012,
Theorems 4.1 and 4.2).

## Examples

``` r
devbs(c(10, 20, 30), eta = 2.58, alpha = 0.19, gama = -0.16)
#> [1] 0.0385729564 0.0256715224 0.0002807054
```
