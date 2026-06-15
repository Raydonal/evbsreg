# Randomized Quantile Residuals for the Log-EVBS Regression Model

Computes randomized quantile residuals (Dunn and Smyth, 1996) for a
log-EVBS regression fit. Under a correctly specified model these
residuals are approximately standard normal, so departures from
normality indicate lack of fit.

## Usage

``` r
rqrandomized(X, t)
```

## Arguments

- X:

  A numeric design matrix with an intercept column.

- t:

  A numeric vector of strictly positive responses.

## Value

A numeric vector of length `length(t)` containing the randomized
quantile residuals.

## References

Dunn, P. K. and Smyth, G. K. (1996). Randomized quantile residuals.
*Journal of Computational and Graphical Statistics*, 5, 236–244.

## See also

[`rcoxsnell`](https://raydonal.github.io/evbsreg/reference/rcoxsnell.md),
[`envelope_qq`](https://raydonal.github.io/evbsreg/reference/envelope_qq.md),
[`evbsreg.fit`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.md).

## Examples

``` r
data(itajai)
X <- cbind(1, itajai$pressure)
r <- rqrandomized(X, itajai$wind)
shapiro.test(r)
#> 
#>  Shapiro-Wilk normality test
#> 
#> data:  r
#> W = 0.98727, p-value = 0.3021
#> 
```
