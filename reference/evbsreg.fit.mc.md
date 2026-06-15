# Monte Carlo Simulation Study for the EVBS Regression Model

Runs a Monte Carlo simulation that evaluates the finite-sample
properties of the joint maximum likelihood estimator of the EVBS
regression model under one of three scenarios.

## Usage

``` r
evbsreg.fit.mc(
  m,
  n,
  beta0,
  beta1,
  alpha,
  gama,
  scenario = c("canonical", "leverage", "robustness"),
  semente = 2023
)
```

## Arguments

- m:

  Number of Monte Carlo replicates (the paper uses `5000`; set to a
  smaller value such as `500` for a quick check).

- n:

  Sample size for each replicate (the paper uses 60, 120, 180).

- beta0:

  True intercept \\\beta_0\\.

- beta1:

  True slope \\\beta_1\\.

- alpha:

  True shape parameter \\\alpha\\.

- gama:

  True tail-shape parameter \\\gamma\\.

- scenario:

  Character string selecting the design:

  `"canonical"`

  :   covariate \\x \sim U(0,1)\\, no contamination (baseline).

  `"leverage"`

  :   10% of covariate values drawn from \\U(5,10)\\ to introduce
      high-leverage points.

  `"robustness"`

  :   10% of observations generated with the shape parameter shifted by
      \\-0.5\\ (alpha contamination).

- semente:

  Integer RNG seed for reproducibility (default `2023`).

## Value

A numeric matrix of dimension \\10 \times 4\\. Columns are the four
parameters `Beta0`, `Beta1`, `Alpha`, `Gama`; rows are: `Parametro`
(true value), `EMV` (mean estimate), `VIES-ABS` (absolute bias),
`VIES-REL` (relative bias), `VAR` (empirical variance), `EQM` (mean
squared error), `E-PADRAO` (empirical standard error), `EP-FISHER` (mean
Fisher standard error), `RAIZ-EQM` (root mean squared error), and
`TAXA-COB` (empirical 95% coverage rate).

## References

Ospina, R., Lima, J. I. C., Barros, M., and Macedo, A. M. S. (2026).
Local influence diagnostics for the extreme-value Birnbaum-Saunders
regression model. *Submitted*.

## See also

[`revbs`](https://raydonal.github.io/evbsreg/reference/revbs.md),
[`evbsreg.fit`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.md).

## Examples

``` r
# \donttest{
## Quick check with m = 50 replicates
res <- evbsreg.fit.mc(m = 50, n = 60,
                       beta0 = 0.5, beta1 = 0.5,
                       alpha = 0.5, gama = 0.20,
                       scenario = "canonical")
print(res)
#>            Beta0 Beta1  Alpha  Gama
#> Parametro  0.500 0.500  0.500 0.200
#> EMV        0.488 0.500  0.469 0.234
#> VIES-ABS  -0.012 0.000 -0.031 0.034
#> VIES-REL  -0.024 0.001 -0.061 0.170
#> VAR        0.022 0.046  0.004 0.022
#> EQM        0.022 0.046  0.005 0.023
#> E-PADRAO   0.148 0.213  0.066 0.149
#> EP-FISHER  0.125 0.197  0.057 0.121
#> RAIZ-EQM   0.148 0.213  0.073 0.153
#> TAXA-COB   0.860 0.980  0.860 0.880
# }
```
