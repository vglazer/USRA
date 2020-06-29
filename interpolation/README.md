# Accurate Monotone Splines

## Overview
MATLAB rountines for accurate 
[monotone cubic](https://en.wikipedia.org/wiki/Monotone_cubic_interpolation) 
interpolants, based on a
[paper](https://ntrs.nasa.gov/archive/nasa/casi.ntrs.nasa.gov/19910011517.pdf) by Hung T. Huynh.
The following
[report](https://github.com/vglazer/USRA/blob/master/interpolation/reports/report.pdf) compares errors and convergence 
rates for cubic spline interpolants across a variety of monotonicity 
constraints from the literature. Huynh's M3 (uniform third order) and M4 
(uniform fourth order) is shown to perform the best.

The monotone spline functions themselves are [here](https://github.com/vglazer/USRA/tree/master/interpolation/hermite).
Miscellaneous functions for computing interpolation errors and convergence 
rates, used to construct the report, can be found
[here](https://github.com/vglazer/USRA/tree/master/interpolation/ccc).

This work was performed under the supervision of 
[Christina C. Christara](http://www.cs.toronto.edu/~ccc/).
