# Combined Conformal Normal Curvature Diagnostic Plot

Produces the two-panel diagnostic figure of the paper: normalized
eigenvalues (left) and aggregate contributions \\B_j(q)\\ (right), side
by side.

## Usage

``` r
plot_cnc(diag, q = 7, label.flagged = 5)
```

## Arguments

- diag:

  A list returned by
  [`cnc_diagnostics`](https://raydonal.github.io/evbsreg/reference/cnc_diagnostics.md).

- q:

  Integer influence threshold in \\1, \ldots, 7\\ (default `7`).

- label.flagged:

  Number of largest observations to label in the right panel (default
  `5`).

## Value

Called for its side effect (a two-panel base-graphics figure). Returns
`NULL` invisibly.

## See also

[`cnc_diagnostics`](https://raydonal.github.io/evbsreg/reference/cnc_diagnostics.md),
[`plot_normalized_eigenvalues`](https://raydonal.github.io/evbsreg/reference/plot_normalized_eigenvalues.md),
[`plot_aggregate_contributions`](https://raydonal.github.io/evbsreg/reference/plot_aggregate_contributions.md).

## Examples

``` r
data(itajai)
fit <- evbsreg.fit(cbind(1, itajai$pressure), itajai$wind)
diag <- cnc_diagnostics(fit)
plot_cnc(diag, q = 7)

```
