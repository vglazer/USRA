% function [errg, errm, errt, errs] = ...
%     error1(ngrid, gridx, n, amidx, nconst, tx, gaussx, ...
%            dof, nn, errg, errm, errt, errs, evalfunc, extx, truef)
%
% compute the max. error of the 1D spline approx. and derivatives (u, ux, uxx)
% at the grid points, midpoints, the "arbitrary" constant points and
% the Gauss points.

function [errg, errm, errt, errs] = ...
    error1(ngrid, gridx, n, amidx, nconst, tx, gaussx, ...
           dof, nn, errg, errm, errt, errs, evalfunc, extx, truef)

%nderv = 3;   % number of derivatives to evaluate: u, ux, uxx
%errt(:, nn) = zeros(nderv, 1);
%errm(:, nn) = zeros(nderv, 1);
%errg(:, nn) = zeros(nderv, 1);
%errs(:, nn) = zeros(nderv, 1);

if nargin < 16, truef = 'truevd';, end

nconstt = size(tx, 2);
for i = 1:nconstt
    px = tx(i);
    val = feval(evalfunc, extx, px, gridx, dof);
    val = val(1:3, 1);
    [true(1) true(2) true(3)] = feval(truef, px);
    errt(:, nn) = max(errt(:, nn), abs(true'-val));
end
for i = 1:n
    px = gridx(i);
    val = feval(evalfunc, extx, px, gridx, dof, i);
    val = val(1:3, 1);
    [true(1) true(2) true(3)] = feval(truef, px);
    errg(:, nn) = max(errg(:, nn), abs(true'-val));
    px = amidx(i);
    val = feval(evalfunc, extx, px, gridx, dof, i);
    val = val(1:3, 1);
    [true(1) true(2) true(3)] = feval(truef, px);
    errm(:, nn) = max(errm(:, nn), abs(true'-val));
    px = gaussx(2*i-1);
    val = feval(evalfunc, extx, px, gridx, dof, i);
    val = val(1:3, 1);
    [true(1) true(2) true(3)] = feval(truef, px);
    errs(:, nn) = max(errs(:, nn), abs(true'-val));
    px = gaussx(2*i);
    val = feval(evalfunc, extx, px, gridx, dof, i);
    val = val(1:3, 1);
    [true(1) true(2) true(3)] = feval(truef, px);
    errs(:, nn) = max(errs(:, nn), abs(true'-val));
end
i = ngrid; px = gridx(i);
val = feval(evalfunc, extx, px, gridx, dof, i-1);
val = val(1:3, 1);
[true(1) true(2) true(3)] = feval(truef, px);
errg(:, nn) = max(errg(:, nn), abs(true'-val));
