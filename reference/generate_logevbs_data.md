# Generate log-EVBS Density Values

Computes \\(y, f(y))\\ pairs of the log-EVBS density over its support,
for given parameters.

## Usage

``` r
generate_logevbs_data(alpha, eta, gama)
```

## Arguments

- alpha:

  Shape parameter \\\alpha \> 0\\.

- eta:

  Location parameter \\\eta\\ (real).

- gama:

  Tail-shape parameter \\\gamma\\ (real).

## Value

A `data.frame` with columns `y_vals` (support points) and `fdp` (density
values).

## References

Leiva, V., Ferreira, M., Gomes, M. I., and Lillo, C. (2016). Extreme
value Birnbaum-Saunders regression models applied to environmental data.
*Stochastic Environmental Research and Risk Assessment*, 30, 1045–1058.

## See also

[`plot_logevbs_alpha`](https://raydonal.github.io/evbsreg/reference/plot_logevbs_alpha.md),
[`generate_evbs_data`](https://raydonal.github.io/evbsreg/reference/generate_evbs_data.md).

## Examples

``` r
d <- generate_logevbs_data(alpha = 1, eta = 0, gama = 0.5)
plot(d$y_vals, d$fdp, type = "l", xlab = "y", ylab = "f(y)")

```
