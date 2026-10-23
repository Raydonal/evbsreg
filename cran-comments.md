## Resubmission after archival

evbsreg was archived on 2026-10-21 because it required 'SpatialExtremes',
which was archived the same day. Version 1.2.2 removes that dependency.

evbsreg used a single function from 'SpatialExtremes', `rgev()`, inside
`revbs()`. It is replaced by an internal generator using the same inversion of
an Exp(1) draw, so seeded results are unchanged (checked against
`SpatialExtremes::rgev()` and covered by a new test). Imports are now only
stats, graphics and ggplot2.

The release also includes the changes prepared as 1.2.1, which never reached
CRAN: a new export `gev_monitor()`, a new element `Bbar` in the value of
`cnc_diagnostics_gev()`, and documentation corrections (`devbs()`,
`evbs_return_level()`, `evbs_monitor()`). No existing export or return value
was removed or changed. See NEWS.md.

## R CMD check results

0 errors | 0 warnings | 2 notes

* "New submission / Package was archived on CRAN": expected, this is the
  resubmission addressing the reason for archival described above.
* The other note concerns HTML manual validation and is a limitation of the
  local check machine only (no `tidy` binary installed); it is not expected
  on CRAN's own check systems, which carry `tidy`.

## Fixes from the previous CRAN review remain in place

* `inst/scripts/*.R` write exclusively to `tempdir()`, not the working
  directory.
* `envelope_qq()` restores on exit every graphical parameter it changes
  (`pty`).

## Test environments

* local Ubuntu 24.04, R 4.6.1: `R CMD build` + `R CMD check --as-cran`
  (see above). Full `testthat` suite (41 expectations across 5 files) passes.

Not yet run for this version, recommended before submitting: win-builder
(devel and release) and the R-hub checks (`.github/workflows/rhub.yaml`,
manual `workflow_dispatch`).

## Downstream dependencies

There are currently no downstream dependencies for this package.
