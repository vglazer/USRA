function dof = si32(gridx)

n = length(gridx)-1; numeq = n+3;
hx = gridx(2) - gridx(1);       % assume uniform grid

rhs(2:n+2, 1) = truevd(gridx');

% approximating the derivative O(h^3)
rhs(1,   1) = ( 2*rhs(5)   - 9*rhs(4) + 18*rhs(3)   - 11*rhs(2))  /(6*hx);
rhs(n+3, 1) = (-2*rhs(n-1) + 9*rhs(n) - 18*rhs(n+1) + 11*rhs(n+2))/(6*hx);
% approximating the derivative O(h^4)
% rhs(1,   1) = ( 9*rhs(6)   -40*rhs(5)   +54*rhs(4) +72*rhs(3)   -95*rhs(2))/(96*hx);
% rhs(n+3, 1) = (-9*rhs(n-2) +40*rhs(n-1) -54*rhs(n) -72*rhs(n+1) +95*rhs(n+2))/(96*hx);
% using the exact derivative value
% [t0, t1, t2] = truevd(gridx(1));   rhs(1,   1) = t1;
% [t0, t1, t2] = truevd(gridx(n+1)); rhs(n+3, 1) = t1;

T0 = sptrid(1/6, 2/3, 1/6, numeq);              % Interpolation matrix
T0(1,     1)     =-1/2; T0(1,     2)       = 0; T0(1,     3)       = 1/2;
T0(numeq, numeq) = 1/2; T0(numeq, numeq-1) = 0; T0(numeq, numeq-2) =-1/2;
T0(1, :) = T0(1, :)/hx; T0(numeq, :) = T0(numeq, :)/hx;

dof = T0\rhs;
