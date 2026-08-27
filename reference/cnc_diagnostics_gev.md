# Conformal normal curvature diagnostics for the GEV regression model

Local influence diagnostics under case-weight perturbation for the GEV
regression model, obtained from the individual score contributions (see
[`gev_scores`](https://raydonal.github.io/evbsreg/reference/gev_scores.md))
and the observed information.

## Usage

``` r
cnc_diagnostics_gev(object)
```

## Arguments

- object:

  An object of class `gevreg` from
  [`gevreg.fit`](https://raydonal.github.io/evbsreg/reference/gevreg.fit.md).

## Value

A list with the normalized aggregate contributions `Bj`, the threshold
`2/n`, and the indices of the flagged observations.

## Examples

``` r
data(itajai)
X <- cbind(1, itajai$pressure - mean(itajai$pressure))
fit <- gevreg.fit(X, itajai$wind)
d <- cnc_diagnostics_gev(fit)
head(order(d$Bj, decreasing = TRUE))
#> [1]  82   6 108 110  24  47
```
