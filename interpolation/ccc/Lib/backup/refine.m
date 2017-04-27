function [ngrid, grid, h] = refine(ngrid0, a, b, ic, minh)
 
% defaults
if nargin < 5, minh = 1/512;, end;
if nargin < 4, ic = 1;, end;
if nargin < 3, b  = 1;, end;
if nargin < 2, a  = 0;, end;
 
n = ngrid0-1;
hh = (b-a)/n;
if hh <= minh
    ngrid = ngrid0;
    grid = a + hh*[0:n];
    h = hh*ones(1, n);
elseif ic == 1
    grid1(1:n/2+1) = a + hh*[0:n/2];
    h1(1:n/2) = hh*ones(1, n/2);
    ngrid1 = n/2 + 1;
    a = grid1(ngrid1);
    [ngrid, grid, h] = refine(ngrid0, a, b, ic, minh);
    grid = [grid1 grid(2:ngrid)];
    h = [h1 h];
    ngrid = ngrid1 + ngrid - 1;
else
    grid1(1:n/2+1) = (a+b)/2 + hh*[0:n/2];
    h1(1:n/2) = hh*ones(1, n/2);
    ngrid1 = n/2 + 1;
    b = grid1(1);
    [ngrid, grid, h] = refine(ngrid0, a, b, ic, minh);
    grid = [grid(1:ngrid-1) grid1];
    h = [h h1];
    ngrid = ngrid1 + ngrid - 1;
end
