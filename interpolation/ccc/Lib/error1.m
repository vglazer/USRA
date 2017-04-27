% function [errg, errm, errt, errs] = ...
%     error1(ngrid, gridx, n, amidx, nconst, tx, gaussx, ...
%            dof, nn, errg, errm, errt, errs, evalfunc, extx, nderv, truef)
%
% compute the max. error of the 1D spline approx. and nderv derivatives
% (u, ux, uxx, ...)
% at the grid points, midpoints, the "arbitrary" constant points and
% the Gauss points.
% truef defaults to 'truevd', nderv to 3

function [errg, errm, errt, errs] = ...
    error1(ngrid, gridx, n, amidx, nconst, tx, gaussx, ...
           dof, nn, errg, errm, errt, errs, evalfunc, extx, nderv, truef)

%nderv = 3;   % number of derivatives to evaluate: u, ux, uxx
%errt(:, nn) = zeros(nderv, 1);
%errm(:, nn) = zeros(nderv, 1);
%errg(:, nn) = zeros(nderv, 1);
%errs(:, nn) = zeros(nderv, 1);

if nargin < 17, truef = 'truevd';, end
if nargin < 16, nderv = 3;, end

nconstt = size(tx, 2);
for i = 1:nconstt
    px = tx(i);
    val = feval(evalfunc, extx, px, gridx, dof);
    val = val(1:nderv, 1);
    [true(1) true(2) true(3) true(4) true(5)] = feval(truef, px);
    true = true(1:nderv);
    errt(:, nn) = max(errt(:, nn), abs(true'-val));
end
for i = 1:n
    px = gridx(i);
    val = feval(evalfunc, extx, px, gridx, dof, i);
    val = val(1:nderv, 1);
    [true(1) true(2) true(3) true(4) true(5)] = feval(truef, px);
    true = true(1:nderv);
    errg(:, nn) = max(errg(:, nn), abs(true'-val));
    %fprintf('grid %3d %9f %9f\n', i, px, true(3)-val(3));
    px = amidx(i); % - (gridx(i+1)-gridx(i))/4;
    val = feval(evalfunc, extx, px, gridx, dof, i);
    val = val(1:nderv, 1);
    [true(1) true(2) true(3) true(4) true(5)] = feval(truef, px);
    true = true(1:nderv);
    errm(:, nn) = max(errm(:, nn), abs(true'-val));
    %fprintf('quar %3d %9f %9f\n', i, px, true(3)-val(3));
    px = gaussx(2*i-1);
    val = feval(evalfunc, extx, px, gridx, dof, i);
    val = val(1:nderv, 1);
    [true(1) true(2) true(3) true(4) true(5)] = feval(truef, px);
    true = true(1:nderv);
    errs(:, nn) = max(errs(:, nn), abs(true'-val));
    px = gaussx(2*i);
    val = feval(evalfunc, extx, px, gridx, dof, i);
    val = val(1:nderv, 1);
    [true(1) true(2) true(3) true(4) true(5)] = feval(truef, px);
    true = true(1:nderv);
    errs(:, nn) = max(errs(:, nn), abs(true'-val));
end
i = ngrid; px = gridx(i);
val = feval(evalfunc, extx, px, gridx, dof, i-1);
val = val(1:nderv, 1);
[true(1) true(2) true(3) true(4) true(5)] = feval(truef, px);
true = true(1:nderv);
errg(:, nn) = max(errg(:, nn), abs(true'-val));
%fprintf('grid %3d %9f %9f\n', i, px, true(3)-val(3));
