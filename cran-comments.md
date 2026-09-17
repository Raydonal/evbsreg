## R CMD check results

0 errors | 0 warnings | 1 note

* The only note concerns HTML manual validation and is a limitation of the
  local check machine only (no `tidy` binary installed); it is not expected
  on CRAN's own check systems, which carry `tidy`.

## Summary of changes since the CRAN-accepted 1.0.0

This is an update, not a resubmission in response to reviewer comments; no
new comments have been received since 1.0.0 was accepted. Version 1.2.0 adds:

* `evbs_monitor()` / `plot.evbs_monitor()`: a prospective control chart for
  endpoint identifiability.
* `devbs()`, `pevbs()`, `qevbs()`: the density, distribution, and quantile
  functions completing the EVBS family (1.0.0 exported only the random
  generator, `revbs()`).
* `evbs_endpoint()`, `evbs_return_level()`: the finite upper endpoint and
  return levels/expected shortfall implied by the fitted model.
* `evbs_block_boot()`: moving-block bootstrap standard errors for serially
  dependent series.
* `gevreg.fit()`, `gev_scores()`, `cnc_diagnostics_gev()`: the same local
  influence framework extended to generalized extreme-value regression,
  used as a benchmark against the EVBS model.
* `logEVBS()` (+ `dlogEVBS()`, `plogEVBS()`, `qlogEVBS()`): a `gamlss.family`
  implementation allowing the tail-shape parameter to depend on covariates.

All additions are new exports; nothing from the 1.0.0 public API was removed
or changed. Two internal bug fixes are also included: `plot_aggregate_
contributions()` no longer lets labels for nearby observations overlap, and
`envelope_qq()` no longer corrupts the panel position of a multi-panel layout
set up by the caller (see NEWS.md for both).

## Fixes from the previous CRAN review remain in place

The two substantive issues raised by the CRAN reviewer (Konstanze Lauseker)
on 1.0.0 were verified to still hold in this version:

* `inst/scripts/*.R` still write exclusively to `tempdir()`, not the working
  directory.
* `envelope_qq()` (R/evbsreg_residuals.R) still restores on exit every
  graphical parameter it changes. The restoration is now scoped to `pty`
  specifically, rather than the caller's entire `par()` state: the wider
  restoration was found in this release cycle to also roll back the
  caller's plot-layout position when the function is used inside a
  multi-panel figure, so it was narrowed to only what the function itself
  sets. The CRAN reviewer's requirement (leave no graphical parameter
  dirtied) is unaffected; this only removes an unintended side effect on the
  caller's layout state.

## Test environments

* local Ubuntu 24.04, R 4.6.1: `R CMD build` + `R CMD check --as-cran`, 0
  errors / 0 warnings / 1 note (see above). Full `testthat` suite (31 tests
  across 5 files) passes.

Not yet run for this version, recommended before submitting: win-builder
(devel and release) and the R-hub checks (`.github/workflows/rhub.yaml`,
manual `workflow_dispatch`). The 1.0.0 submission was checked on both.

## Downstream dependencies

There are currently no downstream dependencies for this package.
