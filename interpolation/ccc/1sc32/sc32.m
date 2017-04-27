% function T = sc32(n, gridx, amidx, extx, coefs)
%
% returns the matrix of the 1D cubic spline collocation linear system
% with general boundary conditions and general linear 2nd order DE operator
% on a general grid
% amidx is dummy argument, at least for second order problems

function T = sc32(n, gridx, amidx, extx, coefs)

numeq = n+3;
T = sptrid(1, 1, 1, numeq);

i = 1; px = gridx(1); ip = i;
bspl = bsplvd(extx, 4, px, ip+3);
T(i, 1:3) = (bspl(1:3, 1))'*coefs(i, 1) ...
          + (bspl(1:3, 2))'*coefs(i, 2) ...
          + (bspl(1:3, 3))'*coefs(i, 3);
for i = 2:n+2
    px = gridx(i-1); ip = i-1;
    bspl = bsplvd(extx, 4, px, ip+3);
%   T(i, i-1:i+1) = (bspl(1:3, 1))';         % Interpolation
%   [rhs, coefu, coefux, coefuxx] = pde(px); % do not call pde again - use
    T(i, i-1:i+1) = (bspl(1:3, 1))'*coefs(i, 1) ...
                  + (bspl(1:3, 2))'*coefs(i, 2) ...
                  + (bspl(1:3, 3))'*coefs(i, 3);
end
i = n+3; px = gridx(n+1); ip = i-2;
bspl = bsplvd(extx, 4, px, ip+3);
T(numeq, numeq-2:numeq) = (bspl(1:3, 1))'*coefs(i, 1) ...
                        + (bspl(1:3, 2))'*coefs(i, 2) ...
                        + (bspl(1:3, 3))'*coefs(i, 3);

