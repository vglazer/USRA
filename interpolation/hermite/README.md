# CODE ORGANIZATION

The code is organized into the following four top-level directories: 

## cubic: cubic interpolants
  pchint - driver for cubic monotonicity-preserving interpolation
  phint - self-contained, restrictive driver for cubic interpolation

## quintic: quintic interpolants *
  pqhint - driver for quintic monotonicity-preserving interpolation

## test: functions used for testing purposes
Routine     | Description
------------|------------
`testpcqhint` | tester for `pchint` and `pqhint`
`testphint` | tester for `phint`
`testdata` | script to load testing data into the workspace
`testfd` | tester for the finite difference approximation formulas in `approxder`
`testfdsec` | similar tester for the formulas in `approxsecder`

## Lib: library subroutines 
  approxder - approximate derivative using finite difference formulas
  approxsecder - approximate second derivative using fd formulas
  perturbder - perturb derivative values to ensure monotonicity
  perturbders - perturb both f'(x) and f''(x) values to ensure monotonicity *
  ppvalnder - evaluate pp structure and its derivatives
  pperror1 - compute error and convergence rate 
  median - return the middle of three numbers (helper function for perturbder)
  minmod - a special case of median (another helper function for perturbder)
  divdiffs - return matrix of divided differences
  vecdiffs - return vectors of divided differences

* - doesn't work properly
