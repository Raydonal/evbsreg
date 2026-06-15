# evbsreg: Local Influence Diagnostics for the EVBS Regression Model

Implements local influence diagnostics for the Extreme-Value
Birnbaum-Saunders (EVBS) regression model: joint maximum likelihood
estimation, conformal normal curvature diagnostics under three
perturbation schemes (case-weight, response variable, and explanatory
variable), randomized quantile residuals with simulation envelope, Monte
Carlo simulation utilities, and publication-quality density and
diagnostic plots.

## Main functions

- [`evbsreg.fit`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.md):

  Joint MLE of the EVBS regression model.

- [`cnc_diagnostics`](https://raydonal.github.io/evbsreg/reference/cnc_diagnostics.md):

  Conformal normal curvature diagnostics.

- [`plot_cnc`](https://raydonal.github.io/evbsreg/reference/plot_cnc.md):

  Two-panel diagnostic figure.

- [`rqrandomized`](https://raydonal.github.io/evbsreg/reference/rqrandomized.md),
  [`rcoxsnell`](https://raydonal.github.io/evbsreg/reference/rcoxsnell.md),
  [`envelope_qq`](https://raydonal.github.io/evbsreg/reference/envelope_qq.md):

  Residuals and envelope.

- [`revbs`](https://raydonal.github.io/evbsreg/reference/revbs.md),
  [`evbsreg.fit.mc`](https://raydonal.github.io/evbsreg/reference/evbsreg.fit.mc.md):

  Random generation and Monte Carlo study.

## References

Ospina, R., Lima, J. I. C., Barros, M., and Macedo, A. M. S. (2026).
Local influence diagnostics for the extreme-value Birnbaum-Saunders
regression model: methodology, validation, and application to anomalous
wind gusts. *Submitted*.

## See also

Useful links:

- <https://github.com/Raydonal/evbsreg>

- Report bugs at <https://github.com/Raydonal/evbsreg/issues>

## Author

**Maintainer**: Raydonal Ospina <raydonal@de.ufpe.br>
([ORCID](https://orcid.org/0000-0002-9884-9090))

Authors:

- Raydonal Ospina <raydonal@de.ufpe.br>
  ([ORCID](https://orcid.org/0000-0002-9884-9090))
