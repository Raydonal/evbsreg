# Block bootstrap standard errors for the EVBS regression model

Nonparametric moving-block bootstrap for the parameters of the EVBS
regression model. Intended for series with residual serial dependence,
where the standard errors obtained from the observed information under
the independence assumption are optimistic.

## Usage

``` r
evbs_block_boot(X, y, L = 4, B = 500)
```

## Arguments

- X:

  Design matrix (including the intercept column).

- y:

  Response vector.

- L:

  Block length.

- B:

  Number of bootstrap resamples.

## Value

A list with the bootstrap standard errors and the matrix of bootstrap
estimates.

## Examples

``` r
# \donttest{
data(itajai)
evbs_block_boot(cbind(1, itajai$pressure), itajai$wind, L = 4, B = 100)$se
#>       beta0       beta1       alpha        gama 
#> 3.394828676 0.003359365 0.011982107 0.089169799 
# }
```
