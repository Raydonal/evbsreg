# Random Number Generation from the EVBS Distribution

Generates random variates from the Extreme-Value Birnbaum-Saunders
(EVBS) distribution by transforming Generalized Extreme Value (GEV)
variates.

## Usage

``` r
revbs(n, alpha, beta, gama)
```

## Arguments

- n:

  Sample size (number of variates to generate).

- alpha:

  Shape parameter \\\alpha \> 0\\.

- beta:

  Scale parameter \\\beta \> 0\\.

- gama:

  Tail-shape parameter \\\gamma\\ (real).

## Value

A numeric vector of `n` EVBS variates. Returns `NA` if `n` is `NA`.

## Details

If \\Z \sim \mathrm{GEV}(0, 1, \gamma)\\, then \\T = \beta\\1 + \alpha^2
Z^2/2 + \alpha Z \sqrt{1 + \alpha^2 Z^2/4}\\\\ follows the EVBS
distribution. GEV variates are drawn via `rgev` from the SpatialExtremes
package.

## References

Ferreira, M., Gomes, M. I., and Leiva, V. (2012). On an extreme value
version of the Birnbaum-Saunders distribution. *REVSTAT*, 10, 181–210.

## See also

[`evbsreg.fit.mc`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.mc.md),
[`evbsreg.fit`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.md).

## Examples

``` r
set.seed(2023)
x <- revbs(100, alpha = 0.5, beta = 1, gama = 0.2)
summary(x)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>  0.5755  0.9404  1.3232  1.9947  1.9640 13.6259 
```
