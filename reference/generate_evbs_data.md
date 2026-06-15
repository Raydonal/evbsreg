# Generate EVBS Density Values

Computes \\(t, f(t))\\ pairs of the Extreme-Value Birnbaum-Saunders
(EVBS) density over its support, for given parameters.

## Usage

``` r
generate_evbs_data(alpha, beta, gama)
```

## Arguments

- alpha:

  Shape parameter \\\alpha \> 0\\.

- beta:

  Scale parameter \\\beta \> 0\\.

- gama:

  Tail-shape parameter \\\gamma\\ (real). The support is bounded below
  when \\\gamma \> 0\\ and above when \\\gamma \< 0\\.

## Value

A `data.frame` with columns `t` (support points) and `y` (density
values).

## References

Ferreira, M., Gomes, M. I., and Leiva, V. (2012). On an extreme value
version of the Birnbaum-Saunders distribution. *REVSTAT*, 10, 181–210.

## See also

[`plot_evbs_alpha`](https://raydonal.github.io/evbsreg/reference/plot_evbs_alpha.md),
[`generate_logevbs_data`](https://raydonal.github.io/evbsreg/reference/generate_logevbs_data.md).

## Examples

``` r
d <- generate_evbs_data(alpha = 0.5, beta = 1, gama = 0.5)
plot(d$t, d$y, type = "l", xlab = "t", ylab = "f(t)")

```
