function [dof, T0, rhs, coefs] = si32(gridx)

n = length(gridx)-1; numeq = n+5;
hx = gridx(2) - gridx(1);       % assume uniform grid

rhs(3:n+3, 1) = truevd(gridx');

% using exact derivative values
[t0, t1, t2, t3, t4] = truevd(gridx(1));   rhs(1,   1) = t1; rhs(2,   1) = t3;
[t0, t1, t2, t3, t4] = truevd(gridx(n+1)); rhs(n+4, 1) = t3; rhs(n+5, 1) = t1;

coefs = zeros(numeq, 5);
coefs(3:n+3, 1) = 1;
coefs(1, 2) = 1; coefs(n+5, 2) = 1;
coefs(2, 4) = 1; coefs(n+4, 4) = 1;
amidx = (gridx(1:n)+gridx(2:n+1))/2;
extx = bsplex(6, gridx, n+1);
T0 = sc54(n, gridx, amidx, extx, coefs);

dof = T0\rhs;
