# Prospective endpoint-identifiability index under the GEV regression

The index \\F_t\\ of
[`evbs_monitor`](https://raydonal.github.io/evbsreg/reference/evbs_monitor.md),
computed with the GEV regression of
[`gevreg.fit`](https://raydonal.github.io/evbsreg/reference/gevreg.fit.md)
in place of the EVBS model. At each \\t \ge\\ `burn` the model is fitted
to the first \\t\\ records, the observation with the largest mean
aggregate contribution (`cnc_diagnostics_gev(fit)$Bbar`) is deleted, the
model is refitted, and the endpoint \\\mu(x) - \sigma/\xi\\ of the
refit, evaluated at the covariate value of the running maximum, is
divided by the running maximum. The endpoint is infinite, and so is the
index, when the refitted \\\xi\\ is not negative.

## Usage

``` r
gev_monitor(X, y, burn = 40, use = c("curvature", "max"))
```

## Arguments

- X:

  Design matrix (including the intercept column). Centre the covariates:
  the GEV likelihood is poorly conditioned otherwise.

- y:

  Response vector, in time order.

- burn:

  Number of initial observations before the index is first computed.

- use:

  Either `"curvature"` (default) or `"max"`.

## Value

A data frame of class `evbs_monitor` with the time index, the running
maximum, the flagged observation, the fitted shape parameter `xi`, the
endpoint and the index `F`. Instants at which a fit fails or does not
converge are omitted.

## Examples

``` r
# \donttest{
data(itajai)
X <- cbind(1, itajai$pressure - mean(itajai$pressure))
gt <- gev_monitor(X, itajai$wind, burn = 40)
plot(gt)

# }
```
