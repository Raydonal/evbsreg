# Reproducibility material

Code that reproduces the numbers, tables and figures of

> Ospina, R., Lima, J. I. C., Barros, M., and Macêdo, A. M. S. (2026).
> *Local influence diagnostics for extreme-value Birnbaum–Saunders
> regression, with an application to wind-gust extremes.* Submitted.

This directory is not part of the R package (it is excluded from the CRAN
tarball). Figure and table numbers refer to the submitted version; those
prefixed S are in its Supplementary Material.

## Requirements

R (>= 4.0) with `evbsreg` (>= 1.2.2), `ismev` (Fremantle data) and `ggplot2`:

```r
install.packages(c("evbsreg", "ismev", "ggplot2"))
```

Both datasets are public: `itajai` ships with `evbsreg`, `fremantle` with `ismev`.

## Usage

Run every script from this directory. Each one is self-contained and creates
its output folders (`fig/`, `fig_originais/`, `figuras/`) if needed.

```sh
Rscript reproduzir_tudo.R               # all numbers reported in the text, ~2 min
Rscript scripts/29_verifica_formulas.R  # every printed formula vs finite differences
```

The console output and the comments of `reproduzir_tudo.R` are in Portuguese;
each block is labelled with the table or quantity it reproduces.

## What reproduces what

| Result in the paper | Script | Output |
|---|---|---|
| Fit, tail index, influence ranking; Tables 1–4 and 6, estimates and tests of Table 5; endpoint; serial dependence, seasonality test and block bootstrap; Fremantle fit and tests; monitoring index | `reproduzir_tudo.R` | console |
| Table 7 (EVBS vs GEV vs EGPD, Vuong tests); check of the generalized Pareto score of Section S5 | `scripts/27_comparacao_familias.R` | console |
| Every formula of Section 4.2 and of Sections S1–S5, Propositions 1, 2 and S5 | `scripts/29_verifica_formulas.R` | console (29 checks) |
| Figures 1, 2, 4, 6, 7 | `scripts/gerar_figuras.R` | `fig_originais/` |
| Figure 3 | `scripts/22_serie.R` | `fig/serie_completa.png` |
| Figures 5, 8 | `scripts/28_fitted_quantiles.R` | `fig_originais/plot6.png`, `fig/frem_serie.png` |
| Figures 9, 10 | `scripts/26_frem_figs.R` | `fig/frem_resid.png`, `fig/frem_diag.png` |
| Figure 11 | `scripts/20_figs_final.R` | `fig/contraste_final.png` |
| Figure 12 (index under EVBS and GEV) | `scripts/30_monitor_gev.R` | `fig/carta_combinada.png` |
| Figure S1 | `scripts/21_simfig.R` | `fig/simulacao.png` |
| Table S7, Figure S2 (Scenario 4) | `scripts/24_simdim2.R` (Monte Carlo, writes `simdim2.rds`), then `scripts/25_simdim_fig.R` | `fig/simdim.png` |
| Tables S1–S6 (Scenarios 1–3) | `inst/scripts/script_03`–`05` of the package, via `evbsreg.fit.mc()` | console |

Notes:

- Simulated envelopes and bootstrap resamples are drawn after `set.seed()`, so
  every figure and number is reproduced exactly.
- `simdim2.rds` caches the Scenario 4 Monte Carlo of `24_simdim2.R`;
  `25_simdim_fig.R` redraws Figure S2 from it in seconds.
  `23_simdim.R` is an earlier variant of the same study, kept for reference.
- Tables S1–S6 use 5,000 replicates and take hours. `21_simfig.R` draws
  Figure S1 from the published values of those tables, which it lists.
- `reproduzir_tudo.R` also writes check figures to `figuras/`; the figures of
  the paper are the ones produced by the scripts above.
