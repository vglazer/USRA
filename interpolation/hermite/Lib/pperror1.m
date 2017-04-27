% SYNTAX
% pperror1(nder, ngrid, gridx, n, amidx, nconst, tx, gaussx, pp, nn, ... 
%          errg, errm, errt, errs, truef)
% 
% DESCRIPTION
% pperror1 computes the maximum approximation error for the 1D piecewise 
% polynomial and its nder-1 derivatives at the grid points, midpoints,
% t-points and s-points.
function [errg, errm, errt, errs] = ...
    pperror1(nder, ngrid, gridx, n, amidx, nconst, tx, gaussx, ...
           pp, nn, errg, errm, errt, errs, truef)

if nargin < 16, truef = 'truevd';, end

nconstt = size(tx, 2);
for i = 1:nconstt
    px = tx(i); 
    val = ppvalnder(pp, px, nder)';
    [true(1) true(2) true(3) true(4) true(5)] = feval(truef, px);
    true = true(1:nder);
    errt(:, nn) = max(errt(:, nn), abs(true - val)');
end
for i = 1:n
    px = gridx(i);
    val = ppvalnder(pp, px, nder)';
    [true(1) true(2) true(3) true(4) true(5)] = feval(truef, px);
    true = true(1:nder);
    errg(:, nn) = max(errg(:, nn), abs(true - val)');

    px = amidx(i);
    val = ppvalnder(pp, px, nder)';
    [true(1) true(2) true(3) true(4) true(5)] = feval(truef, px);
    true = true(1:nder);
    errm(:, nn) = max(errm(:, nn), abs(true - val)');

    px = gaussx(2*i-1); 
    val = ppvalnder(pp,px, nder)';
    [true(1) true(2) true(3) true(4) true(5)] = feval(truef, px);
    true = true(1:nder);
    errs(:, nn) = max(errs(:, nn), abs(true - val)');

    px = gaussx(2*i); 
    val = ppvalnder(pp,px, nder)';
    [true(1) true(2) true(3) true(4) true(5)] = feval(truef, px);
    true = true(1:nder);
    errs(:, nn) = max(errs(:, nn), abs(true - val)');
end
i = ngrid; px = gridx(i);
val = ppvalnder(pp,px, nder)';
[true(1) true(2) true(3) true(4) true(5)] = feval(truef, px);
true = true(1:nder);
errg(:, nn) = max(errg(:, nn), abs(true - val)');

