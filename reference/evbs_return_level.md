# Return level and expected shortfall for the EVBS regression model

Computes the `period`-observation return level and, optionally, the
conditional tail expectation (expected shortfall) at a given linear
predictor value.

## Usage

``` r
evbs_return_level(object, x, period, es = FALSE)
```

## Arguments

- object:

  An object of class `evbsreg` from
  [`evbsreg.fit`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.md).

- x:

  Covariate vector (including the intercept) at which to evaluate.

- period:

  Return period, expressed in the units of one observation. For monthly
  maxima and a \\T\\-year return level, use `period = 12 * T`.

- es:

  Logical; if `TRUE`, also return the expected shortfall.

## Value

A named numeric vector with the return level and, if requested, the
expected shortfall.

## Examples

``` r
data(itajai)
fit <- evbsreg.fit(cbind(1, itajai$pressure), itajai$wind)
# 50-year return level at mean pressure, from monthly maxima
evbs_return_level(fit, x = c(1, mean(itajai$pressure)),
                  period = 12 * 50, es = TRUE)
#>       return_level expected_shortfall 
#>           27.60566           29.20929 
```
