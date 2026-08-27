# Distribution function of the Extreme-Value Birnbaum-Saunders distribution

Distribution function of the Extreme-Value Birnbaum-Saunders
distribution

## Usage

``` r
pevbs(t, eta, alpha, gama, lower.tail = TRUE)
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

- lower.tail:

  Logical; if `TRUE` (default), probabilities are \\P(T \le t)\\,
  otherwise \\P(T \> t)\\.

## Value

A numeric vector of probabilities.

## Examples

``` r
pevbs(30, eta = 2.58, alpha = 0.19, gama = -0.16, lower.tail = FALSE)
#> [1] 0.0004258884
```
