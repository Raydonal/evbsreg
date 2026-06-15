# Fit the Extreme-Value Birnbaum-Saunders Regression Model

Fits the log-Extreme-Value Birnbaum-Saunders (log-EVBS) regression model
by joint maximum likelihood estimation. All parameters \\(\beta^\top,
\alpha, \gamma)^\top\\ are estimated simultaneously using the BFGS
algorithm with an analytic score function. Standard errors are computed
from the analytic observed Fisher information matrix, which is
numerically stable even for ill-conditioned design matrices.

## Usage

``` r
evbsreg.fit(x, t)
```

## Arguments

- x:

  A numeric design matrix of dimension \\n \times p\\. It **must**
  include an intercept column (a column of ones). Each row corresponds
  to one observation and each column to one covariate.

- t:

  A numeric vector of length \\n\\ containing the **strictly positive**
  responses (e.g. wind gust speeds). Internally the model is fit to
  `log(t)`.

## Value

A list of class `"evbsreg"` with components:

- `coeff`:

  Numeric vector of length \\p+2\\: the full parameter vector
  \\(\beta_0,\ldots,\beta\_{p-1}, \alpha, \gamma)\\.

- `betahat`:

  Numeric vector of length \\p\\: the regression coefficients.

- `alphahat`:

  Scalar: the estimated shape parameter \\\hat\alpha\\.

- `gamahat`:

  Scalar: the estimated tail-shape parameter \\\hat\gamma\\.

- `stderrors`:

  Numeric vector of length \\p\\: standard errors of the regression
  coefficients.

- `stderroralpha`:

  Scalar: standard error of \\\hat\alpha\\.

- `stderrorgama`:

  Scalar: standard error of \\\hat\gamma\\.

- `zstats`:

  Numeric vector: Wald z-statistics for the regression coefficients.

- `pvalues`:

  Numeric vector: two-sided p-values for the regression coefficients.

- `muhat`:

  Numeric vector of length \\n\\: fitted linear predictor on the log
  scale.

- `xi1`, `xi2`:

  Numeric vectors of length \\n\\: helper quantities \\\xi\_{i1},
  \xi\_{i2}\\ evaluated at the MLE.

- `observmatrix`:

  Numeric matrix of dimension \\(p+2)\times(p+2)\\: the analytic Hessian
  \\\ddot\ell(\hat\theta)\\ of the log-likelihood (negative definite at
  the maximum).

- `hessian`:

  Numeric matrix: identical to `observmatrix`; provided under the
  conventional name. The observed Fisher information is `-hessian`.

- `inv`:

  Numeric matrix of dimension \\(p+2)\times(p+2)\\: the inverse of the
  observed Fisher information `-hessian`, i.e. the asymptotic
  variance-covariance matrix of \\\hat\theta\\.

- `B`:

  Numeric matrix of dimension \\n\times n\\: the influence matrix \\B =
  \Delta^\top (-\ddot\ell)^{-1} \Delta\\ for the case-weight
  perturbation scheme, consumed by
  [`cnc_diagnostics`](https://raydonal.github.io/evbsreg/reference/cnc_diagnostics.md).

- `nobs`:

  Integer: the number of observations \\n\\.

- `npar`:

  Integer: the number of parameters \\p+2\\.

The returned object has class `"evbsreg"` and has a
[`print.evbsreg`](https://raydonal.github.io/evbsreg/reference/print.evbsreg.md)
method that displays a coefficient table.

## Details

The EVBS regression model links the location parameter of the log-EVBS
distribution to a linear predictor \\\mu_i = x_i^\top \beta\\. The shape
parameter \\\alpha \> 0\\ controls dispersion and the tail-shape
parameter \\\gamma\\ governs the Generalized Extreme Value tail
behaviour (Frechet for \\\gamma\>0\\, Gumbel for \\\gamma=0\\, Weibull
for \\\gamma\<0\\).

Initial values are obtained from
[`lm.fit`](https://rdrr.io/r/stats/lmfit.html) applied to the log
response, together with the moment-based starting point \\\alpha_0 =
\sqrt{(4/n)\sum \sinh^2((y_i - x_i^\top \beta_0)/2)}\\ and \\\gamma_0 =
0.01\\. Optimization uses [`optim`](https://rdrr.io/r/stats/optim.html)
with `method = "BFGS"`, the analytic score, and tolerance
`reltol = 1e-12`.

The observed Fisher information is assembled analytically (see the
package vignette and the paper's appendix) and inverted via a Cholesky
factorization, falling back to
[`solve`](https://rdrr.io/r/base/solve.html) if the matrix is not
positive definite.

## References

Ospina, R., Lima, J. I. C., Barros, M., and Macedo, A. M. S. (2026).
Local influence diagnostics for the extreme-value Birnbaum-Saunders
regression model: methodology, validation, and application to anomalous
wind gusts. *Submitted*.

Leiva, V., Ferreira, M., Gomes, M. I., and Lillo, C. (2016). Extreme
value Birnbaum-Saunders regression models applied to environmental data.
*Stochastic Environmental Research and Risk Assessment*, 30, 1045–1058.

Cook, R. D. (1986). Assessment of local influence. *Journal of the Royal
Statistical Society, Series B*, 48, 133–169.

## See also

[`cnc_diagnostics`](https://raydonal.github.io/evbsreg/reference/cnc_diagnostics.md)
for influence diagnostics,
[`rqrandomized`](https://raydonal.github.io/evbsreg/reference/rqrandomized.md)
for residuals,
[`itajai`](https://raydonal.github.io/evbsreg/reference/itajai.md) for
the example dataset.

## Examples

``` r
data(itajai)
X <- cbind(1, itajai$pressure)
fit <- evbsreg.fit(X, itajai$wind)

## Parameter estimates and standard errors
round(fit$coeff, 4)
#>      x1      x2                 
#> 25.5148 -0.0227  0.1857 -0.1551 
round(c(fit$stderrors, fit$stderroralpha, fit$stderrorgama), 4)
#> [1] 3.3338 0.0033 0.0127 0.0472
```
