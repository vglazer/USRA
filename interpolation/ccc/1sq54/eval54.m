% function val = eval54(ext, p, grid, dof, ip)
%
% returns the values of the quintic b-spline approximation
% and derivatives (u, ux, uxx, uxxx, uxxxx) on p.
% ip optional

function val = eval54(ext, p, grid, dof, ip)

if nargin < 5
    ip = intrvl(p, grid);
end
bspl = bsplvd(ext, 6, p, ip+5, 5);
val  = bspl'*dof(ip:ip+5);
