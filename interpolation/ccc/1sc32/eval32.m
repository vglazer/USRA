% function val = eval32(ext, p, grid, dof, ip)
%
% returns the values of the cubic b-spline approximation
% and derivatives (u, ux, uxx) on p.
% ip optional

function val = eval32(ext, p, grid, dof, ip)

% if the grid interval point p falls in is unspecified, determine it 
if nargin < 5
    ip = intrvl(p, grid);
end
bspl = bsplvd(ext, 4, p, ip+3, 3);
val  = bspl'*dof(ip:ip+3);
