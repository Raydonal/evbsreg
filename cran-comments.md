## Version 1.2.3 replaces 1.2.2 in the incoming queue

1.2.2 was submitted on 2026-10-23 and is waiting in newbies/. After submitting
we found that `envelope_qq()` did not actually restore `par("pty")` on exit,
contrary to what we stated for the previous CRAN review: it saved the value
without its name, so `par(oldpar)` restored nothing and raised a warning. 1.2.3
fixes this (`oldpar <- par(pty = "s"); on.exit(par(oldpar))`, with a test) and
an indexing error in the same function for small `nrep`. Nothing else changed
relative to 1.2.2; please consider 1.2.3 in its place. We apologise for the
extra submission.

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
  The same note lists "possibly misspelled words" in DESCRIPTION (Barros,
  Birnbaum, EVBS, Ferreira, Gomes, Itajai, Leiva, Macedo, Ospina): all are
  author names, the model acronym, or a place name, and are spelled correctly.
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
  (see above). Full `testthat` suite (45 expectations across 5 files) passes.

* win-builder R-devel (2026-10-22 r90748 ucrt): 1 note (the incoming
  feasibility note above).
* mac-builder, r-release-macosx-arm64, R 4.6.1: OK.
* GitHub Actions, all OK: macos-latest (release), windows-latest (release),
  ubuntu-latest (devel, release, oldrel-1).
* R-hub, all OK: linux (R-devel), windows (R-devel), macos (R-devel),
  macos-arm64 (R-devel), ubuntu-next, ubuntu-release.

## Downstream dependencies

There are currently no downstream dependencies for this package.
