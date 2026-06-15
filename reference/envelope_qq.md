# Normal Probability Plot with Simulation Envelope

Produces a normal probability (QQ) plot of the randomized quantile
residuals together with a simulated envelope, reproducing the residual
diagnostic figure of the paper. Points falling outside the envelope
indicate poor fit.

## Usage

``` r
envelope_qq(X, t, nrep = 100)
```

## Arguments

- X:

  A numeric design matrix with an intercept column.

- t:

  A numeric vector of strictly positive responses.

- nrep:

  Number of simulated samples used to build the envelope (default
  `100`).

## Value

Invisibly, a list with components `r` (observed residuals), `e1` and
`e2` (lower and upper envelope bounds), and `med` (envelope median). A
base-graphics plot is produced as a side effect.

## References

Atkinson, A. C. (1985). *Plots, Transformations and Regression*. Oxford
University Press.

## See also

[`rqrandomized`](https://raydonal.github.io/evbsreg/reference/rqrandomized.md).

## Examples

``` r
data(itajai)
X <- cbind(1, itajai$pressure)
envelope_qq(X, itajai$wind, nrep = 100)

```
