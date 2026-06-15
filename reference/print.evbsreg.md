# Print Method for EVBS Regression Fits

Compactly prints the parameter estimates, standard errors, and Wald
tests of an object returned by
[`evbsreg.fit`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.md).

## Usage

``` r
# S3 method for class 'evbsreg'
print(x, digits = 4, ...)
```

## Arguments

- x:

  An object of class `"evbsreg"`.

- digits:

  Number of significant digits (default 4).

- ...:

  Further arguments passed to
  [`print.default`](https://rdrr.io/r/base/print.default.html).

## Value

The object `x`, invisibly. Called for the side effect of printing a
coefficient table to the console.

## See also

[`evbsreg.fit`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.md).

## Examples

``` r
data(itajai)
fit <- evbsreg.fit(cbind(1, itajai$pressure), itajai$wind)
print(fit)
#> Extreme-Value Birnbaum-Saunders regression
#> n = 124 observations, 4 parameters
#> 
#>       Estimate Std.Error z.value p.value
#> beta0  25.5148    3.3338  7.6533       0
#> beta1  -0.0227    0.0033 -6.8803       0
#> alpha   0.1857    0.0127      NA      NA
#> gamma  -0.1551    0.0472      NA      NA
```
