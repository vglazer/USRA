% function dof = si32(gridx)
% runs on nonuniform grid with exact derivative values

function dof = si32(gridx)

n = length(gridx)-1; numeq = n+3;
%hx = gridx(2) - gridx(1);       % assume uniform grid

rhs(2:n+2, 1) = truevd(gridx');
% approximating the derivative O(h^3) on uniform grid
%rhs(1,   1) = ( 2*rhs(5)   - 9*rhs(4) + 18*rhs(3)   - 11*rhs(2))  /(6*hx);
%rhs(n+3, 1) = (-2*rhs(n-1) + 9*rhs(n) - 18*rhs(n+1) + 11*rhs(n+2))/(6*hx);
% approximating the derivative O(h^4) on uniform grid
%rhs(1,   1) = (-3*rhs(6)   +16*rhs(5)   -36*rhs(4) +48*rhs(3)   -25*rhs(2))/(12*hx);
%rhs(n+3, 1) = ( 3*rhs(n-2) -16*rhs(n-1) +36*rhs(n) -48*rhs(n+1) +25*rhs(n+2))/(12*hx);
% using the exact derivative value
[t0, t1, t2] = truevd(gridx(1));   rhs(1,   1) = t1;
[t0, t1, t2] = truevd(gridx(n+1)); rhs(n+3, 1) = t1;

% on uniform grid only
%T0 = sptrid(1/6, 2/3, 1/6, numeq);              % Interpolation matrix
%T0(1,     1)     =-1/2; T0(1,     2)       = 0; T0(1,     3)       = 1/2;
%T0(numeq, numeq) = 1/2; T0(numeq, numeq-1) = 0; T0(numeq, numeq-2) =-1/2;
%T0(1, :) = T0(1, :)/hx; T0(numeq, :) = T0(numeq, :)/hx;

coefs = zeros(numeq, 3);
coefs(2:n+2, 1) = 1;
coefs(1, 2) = 1; coefs(n+3, 2) = 1;
extx = bsplex(4, gridx, n+1);
T0 = sc32(n, gridx, gridx, extx, coefs);

dof = T0\rhs;
