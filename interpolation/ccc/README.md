# Code Organization
The code is organized into the top-level directories below

## `1sc32` (Spline interpolant construction and evaluation routines)
Function     | Description
-------------|------------
`si32`       | Observe that we may express the interpolant S(x) as a linear combination of ngrid + 2 order k B-spline basis functions, which means that S(x) is completely determined by its coordinates wrt. the above basis (`dof`). `si32()` computes the `dof` based on a tridiagonal constraint matrix (constructed using `sptrid`) which stipulates that S(x) must interpolate `truevd()` at the gridpoints. The `Uname` global, set by `testinterp()`, determines which function `truevd()` represents
`eval32`     | Evaluate S(x) at point `p` using the `dof` supplied by `si32()` and the basis function values supplied by `bsplvd()`
`testinterp` | First, construct a spline interpolant S(x) for some particular function in `truevd()` using `si32()`. Next, use `eval32()`, `error1()` and `converge1()` to compute error and convergence rates for S(x) at the gridpoints and Gauss points

## `Bspl` (General B-spline construction and evaluation routines)
Function | Description
---------|------------
`bsplex` | Extend grid so that exactly `k` basis functions are active in each interval, where `k` is the B-spline order (i.e. four for cubic splines). Note that the additional gridpoints lie outside of Domain(S(x))
`bsplvd` | Return the values of the (at most) `k` nonzero (order `k`) B-spline basis functions active at point `p` for S(x) and `nderiv` of its derivatives
`bsplvn` | Helper routine used by `bsplvd`
`intrvl` | Locate and return the grid subinterval in which point `p` lies

## `Lib` (Various library routines)
Function    | Description
------------|------------
`converge1` | Compute the rate of convergence (as `numgrid` -> Inf) at the gridpoints, midpoints and Gauss points
`error1`    | Compute the error in interpolation at the gridpoints, midpoints and Gauss points
`setgrid`   | Return the gridpoints, midpoints and Gauss points for the specified interval and grid size
`sptrid`    | Construct the specified tridiagonal matrix. This routine is used by `si32()` to solve for `dof`
`truevd`    | Evaluate the (globally set) 'test function' (`Uname`), as well as its first and second derivatives, at the specified points
