# Accurate Monotone Splines

## Overview
MATLAB functions for constructing accurate 
[monotone cubic interpolants](https://en.wikipedia.org/wiki/Monotone_cubic_interpolation), 
based on a NASA
[tech memo](https://ntrs.nasa.gov/archive/nasa/casi.ntrs.nasa.gov/19910011517.pdf) by Hung T. Huynh.
The following
[report](https://github.com/vglazer/USRA/blob/master/interpolation/reports/report.pdf) compares errors and convergence 
rates across a variety of monotonicity constraints from the literature,
demonstrating that Huynh's perform the best. This work was performed under the supervision of 
[Christina C. Christara](http://www.cs.toronto.edu/~ccc/).

The monotone spline functions themselves are [here](https://github.com/vglazer/USRA/tree/master/interpolation/hermite).
Miscellaneous functions used to construct the report are
[here](https://github.com/vglazer/USRA/tree/master/interpolation/ccc).

