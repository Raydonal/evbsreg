## R CMD check results

✔ 0 errors | ✔ 0 warnings | ✔ 0 notes

**Status:** Ready for CRAN submission

---

## Test environments

* **Local**: Ubuntu 22.04, R 4.5.2
* **GitHub Actions**: 
  - R-release (latest stable)
  - R-devel (development version)
* **win-builder**: 
  - Windows (devel)
  - Windows (release)

---

## Detailed Results

### Errors
None ✔

### Warnings
None ✔

### Notes
None ✔

---

## Package Information

* **Title**: Local Influence Diagnostics for the Extreme-Value Birnbaum-Saunders Regression Model
* **Version**: 1.0.0 (Initial CRAN release)
* **Author/Maintainer**: Raydonal Ospina <raydonal@de.ufpe.br>
* **License**: MIT + file LICENSE
* **Repository**: https://github.com/Raydonal/evbsreg

---

## Downstream Dependencies

There are currently no downstream dependencies for this package.

---

## Comments for CRAN Reviewers

This is the first release of evbsreg to CRAN.

### Key Features:
- Implements local influence diagnostics for Extreme-Value Birnbaum-Saunders (EVBS) regression models
- Joint maximum likelihood estimation with flexible specification
- Conformal normal curvature diagnostics under three perturbation schemes
- Randomized quantile residuals with simulation envelopes
- Monte Carlo simulation utilities
- Publication-quality diagnostic and density plots

### Dependencies:
- The package imports `SpatialExtremes` (required for its `rgev()` function) to generate Generalized Extreme Value variates used in simulation utilities and random number generation
- All other dependencies (ggplot2, stats, graphics) are widely used and stable

### Methodology:
The methods are described in:
- Ospina, Lima, Barros, and Macedo (2026, submitted)

The package includes a comprehensive vignette demonstrating the workflow on real data (monthly maximum wind gust data from Itajai, Brazil).

---

## Maintainer Contact

Raydonal Ospina  
UFPE (Universidade Federal de Pernambuco)  
Email: raydonal@de.ufpe.br  
ORCID: 0000-0002-9884-9090
