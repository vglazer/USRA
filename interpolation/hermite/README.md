# Code Organization

The code is organized into the three top-level directories below

## `Lib` (Library subroutines)
Function       | Description
---------------|------------
`approxder`    | approximate derivative using finite difference formulas
`approxsecder` | approximate second derivative using fd formulas
`perturbder`   | perturb derivative values to ensure monotonicity
`ppvalnder`    | evaluate pp structure and its derivatives
`pperror1`     | compute error and convergence rate 
`median`       | return the middle of three numbers (helper function for `perturbder`)
`minmod`       | a special case of `median` (another helper function for `perturbder`)
`divdiffs`     | return matrix of divided differences
`vecdiffs`     | return vectors of divided differences

## `cubic` (Cubic interpolants)
Function | Description
---------|------------
`pchint` | driver for cubic monotonicity-preserving interpolation
`phint`  | self-contained, restrictive driver for cubic interpolation

## `test` (Testing functions)
Function      | Description
--------------|------------
`testpcqhint` | tester for `pchint` and `pqhint`
`testphint`   | tester for `phint`
`testdata`    | script to load testing data into the workspace
`testfd`      | tester for the finite difference approximation formulas in `approxder`
`testfdsec`   | similar tester for the formulas in `approxsecder`
