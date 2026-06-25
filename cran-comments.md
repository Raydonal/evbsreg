## R CMD check results

0 errors | 0 warnings | 0 notes

This is a resubmission addressing all issues raised by the CRAN incoming
checks and the CRAN reviewer (Konstanze Lauseker).

## Resubmission Notes (2nd submission)

### 1. Writing to user home filespace (inst/scripts/)

All scripts in inst/scripts/ now write output files exclusively to
tempdir() instead of the current working directory:
- script_01_density_figures.R: ggsave() now uses file.path(tempdir(), ...)
- script_02_itajai_application.R: png() now uses file.path(tempdir(), ...)
- script_03/04/05_simulation_*.R: save() now uses file.path(tempdir(), ...)

### 2. Changing graphical parameters without on.exit()

In R/evbsreg_residuals.R, the envelope_qq() function now saves and
restores par() immediately using on.exit():

  oldpar <- par(no.readonly = TRUE)
  on.exit(par(oldpar))
  par(pty = "s")

### 3. Possibly misspelled words (from previous check)

The following terms flagged by the spell-checker are legitimate proper nouns
and technical terms:
- Ospina, Barros, Macedo: Author surnames
- Birnbaum: Distribution name (Birnbaum-Saunders)
- EVBS: Acronym for Extreme-Value Birnbaum-Saunders regression
- Itajai: Municipality name in Brazil (application location)

### 4. URL corrections (from previous check)

- Fixed README.md: https://Raydonal.github.io/evbsreg changed to
  https://raydonal.github.io/evbsreg/ (lowercase + trailing slash)
- Removed unreachable URL (portal.inmet.gov.br) from man/itajai.Rd

## Test environments

* local Ubuntu 22.04, R 4.5.2
* GitHub Actions: R-release and R-devel
* win-builder: devel and release

## Downstream dependencies

There are currently no downstream dependencies for this package.