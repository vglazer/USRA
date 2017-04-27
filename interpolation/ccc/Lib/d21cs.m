% function [d2, d1, d0, d2m, d1m, d0m] = d21cs(n, gridx, amidx, dof, evalfunc, extx)
%
% compute approximations to the second and first derivatives of
% the cubic spline approximation at the gridpoints
% amidx is dummy argument, at least for second order problems
% can return d0, d2m, d1m, d0m too, if some statements are uncommented.

function [d2, d1, d0, d2m, d1m, d0m] = d21cs(n, gridx, amidx, dof, evalfunc, extx)

d0 = []; d2m = []; d1m = []; d0m = [];
%hx = gridx(2) - gridx(1);             % assume uniform grid
for i = 1:n+1
    px = gridx(i);
    ip = i; if i == n+1, ip = n;, end;
    val = feval(evalfunc, extx, px, gridx, dof, ip);
%   d0(i) = val(1);
    d1(i) = val(2);
    d2(i) = val(3);
%   if (i <= n)
%       px = amidx(i);
%       val = feval(evalfunc, extx, px, gridx, dof, ip);
%       d0m(i) = val(1);
%       d1m(i) = val(2);
%       d2m(i) = val(3);
%   end
end
