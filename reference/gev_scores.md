# Individual score contributions for the GEV regression model

Returns the matrix whose \\i\\th row is the score vector of the \\i\\th
observation, \\s_i(\theta) = \partial \ell_i / \partial \theta\\, for
the generalized extreme-value regression model with linear location,
\\Y_i \sim \mathrm{GEV}(\mu_i, \sigma, \xi)\\ and \\\mu_i = x_i^\top
\beta\\.

## Usage

``` r
gev_scores(y, X, beta, sigma, xi)
```

## Arguments

- y:

  Response vector.

- X:

  Design matrix (including the intercept column).

- beta:

  Regression coefficients for the location parameter.

- sigma:

  Positive scale parameter.

- xi:

  Extreme-value shape parameter.

## Value

An \\n \times (p+2)\\ matrix of individual score contributions.

## Details

This matrix is the key to generalizing local influence diagnostics
beyond a single model class. Under the case-weight perturbation scheme
the perturbed log-likelihood is \\\ell(\theta \mid \omega) = \sum_i
\omega_i \ell_i(\theta)\\, so the perturbation matrix is \$\$\Delta =
\frac{\partial^2 \ell(\theta \mid \omega)}{\partial \theta \\ \partial
\omega^\top} = \[\\ s_1(\theta) \\ \cdots \\ s_n(\theta) \\\],\$\$
evaluated at the maximum likelihood estimate. That is, \\\Delta\\ is
simply the matrix of individual score contributions. This holds for
*any* likelihood model, which is why the conformal normal curvature
framework requires nothing beyond the score and the observed
information.

With \\z_i = (y_i - \mu_i)/\sigma\\, \\u_i = 1 + \xi z_i \> 0\\ and
\\w_i = u_i^{-1/\xi}\\, the components are \$\$\partial \ell_i /
\partial \mu_i = (\xi + 1 - w_i)/(\sigma u_i),\$\$ \$\$\partial \ell_i /
\partial \sigma = -1/\sigma + z_i(\xi + 1 - w_i)/(\sigma u_i),\$\$
\$\$\partial \ell_i / \partial \xi = \xi^{-2}(1 - w_i)\log u_i -
(z_i/u_i)\\1 + (1 - w_i)/\xi\\.\$\$

## Examples

``` r
data(itajai)
X <- cbind(1, itajai$pressure - mean(itajai$pressure))
fit <- gevreg.fit(X, itajai$wind)
S <- gev_scores(itajai$wind, X, fit$beta, fit$sigma, fit$xi)
colSums(S) # approximately zero at the MLE
#>         beta0         beta1         sigma            xi 
#> -5.352546e-09  2.256779e-08  4.493913e-09 -2.582967e-08 
```
