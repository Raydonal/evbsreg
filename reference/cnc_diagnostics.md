# Conformal Normal Curvature Local Influence Diagnostics

Computes conformal normal curvature (CNC) local influence diagnostics
from a fitted EVBS regression model. The CNC approach of Poon and Poon
(1999) produces a scale-invariant influence measure bounded in
\\\[0,1\]\\; the aggregate contribution statistic of Zhu and Lee (2001)
attributes curvature to individual observations and is compared against
interpretable reference thresholds.

## Usage

``` r
cnc_diagnostics(fit)
```

## Arguments

- fit:

  A fitted model object returned by
  [`evbsreg.fit`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.md).
  The function uses the influence matrix `fit$B`.

## Value

A list with components:

- `eigenvalues`:

  Numeric vector: the raw eigenvalues of \\B\\.

- `eigenvalues_norm`:

  Numeric vector: the absolute normalized eigenvalues
  \\\|\lambda_i^\*\|\\.

- `eigenvectors`:

  Matrix: the eigenvectors of \\B\\ (columns).

- `thresholds`:

  Numeric vector of length 7: the reference thresholds \\q/\sqrt{n}\\
  for \\q = 1, \ldots, 7\\.

- `Bj`:

  Matrix of dimension \\8 \times n\\: rows 1–7 hold the aggregate
  contributions \\B_j(q)\\ for \\q=1,\ldots,7\\; row 8 holds the global
  aggregate over all eigenvectors.

- `bq`:

  Numeric vector of length 8: the reference values \\b(q)\\ for flagging
  influential observations at each level.

- `n`:

  Integer: the sample size.

## Details

The function performs the symmetric eigendecomposition of the influence
matrix \\B\\, normalizes the eigenvalues to unit norm, and for each
threshold \\q = 1, \ldots, 7\\ identifies the \\q\\-influential
eigenvectors (those whose normalized eigenvalue exceeds \\q/\sqrt{n}\\).
The aggregate contribution of observation \\j\\ at level \\q\\,
\\B_j(q)\\, is the sum of the normalized eigenvalues weighted by the
squared eigenvector coordinates of observation \\j\\.

## References

Poon, W.-Y. and Poon, Y. S. (1999). Conformal normal curvature and
assessment of local influence. *Journal of the Royal Statistical
Society, Series B*, 61, 51–61.

Zhu, H. and Lee, S. (2001). Local influence for incomplete-data models.
*Journal of the Royal Statistical Society, Series B*, 63, 111–126.

Ospina, R., Lima, J. I. C., Barros, M., and Macedo, A. M. S. (2026).
Local influence diagnostics for the extreme-value Birnbaum-Saunders
regression model. *Submitted*.

## See also

[`evbsreg.fit`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.md),
[`plot_cnc`](https://raydonal.github.io/evbsreg/reference/plot_cnc.md).

## Examples

``` r
data(itajai)
X <- cbind(1, itajai$pressure)
fit <- evbsreg.fit(X, itajai$wind)
diag <- cnc_diagnostics(fit)

## Top normalized eigenvalues
head(diag$eigenvalues_norm, 4)
#> [1] 0.6967768 0.4951145 0.4454736 0.2663023

## Observations flagged at q = 7
which(diag$Bj[7, ] > diag$bq[7])
#> [1]  27  43  44  47  82  87 108 110 120
```
