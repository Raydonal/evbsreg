# Plot Normalized Eigenvalues of the Influence Matrix

Produces panel (a) of the diagnostic figure: the normalized eigenvalues
of the influence matrix, with horizontal reference thresholds for \\q =
1, \ldots, 7\\.

## Usage

``` r
plot_normalized_eigenvalues(diag, pch = 16, cex = 1, main = "")
```

## Arguments

- diag:

  A list returned by
  [`cnc_diagnostics`](https://raydonal.github.io/evbsreg/reference/cnc_diagnostics.md).

- pch:

  Plotting character (default `16`).

- cex:

  Point size expansion (default `1`).

- main:

  Plot title (default empty).

## Value

Called for its side effect (a base-graphics plot). Returns `NULL`
invisibly.

## See also

[`plot_cnc`](https://raydonal.github.io/evbsreg/reference/plot_cnc.md),
[`cnc_diagnostics`](https://raydonal.github.io/evbsreg/reference/cnc_diagnostics.md).

## Examples

``` r
data(itajai)
fit <- evbsreg.fit(cbind(1, itajai$pressure), itajai$wind)
diag <- cnc_diagnostics(fit)
plot_normalized_eigenvalues(diag, main = "(a)")

```
