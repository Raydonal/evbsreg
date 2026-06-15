# Cox-Snell Residuals for the Log-EVBS Regression Model

Computes Cox-Snell residuals for a log-EVBS regression fit. Under a
correctly specified model these residuals form an approximately standard
exponential sample.

## Usage

``` r
rcoxsnell(X, t)
```

## Arguments

- X:

  A numeric design matrix with an intercept column.

- t:

  A numeric vector of strictly positive responses.

## Value

A numeric vector of length `length(t)` containing the Cox-Snell
residuals.

## References

Cox, D. R. and Snell, E. J. (1968). A general definition of residuals.
*Journal of the Royal Statistical Society, Series B*, 30, 248–275.

## See also

[`rqrandomized`](https://raydonal.github.io/evbsreg/reference/rqrandomized.md),
[`envelope_qq`](https://raydonal.github.io/evbsreg/reference/envelope_qq.md).

## Examples

``` r
data(itajai)
X <- cbind(1, itajai$pressure)
cs <- rcoxsnell(X, itajai$wind)
summary(cs)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#> 0.01276 0.30000 0.75253 0.99150 1.39970 7.32919 
```
