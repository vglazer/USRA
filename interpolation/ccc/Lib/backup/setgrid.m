% function [grid, amid, gauss, h, ngrid, gauss3, gauss4] = ...
%     setgrid (ngrid, a, b, ic, minh)
function [grid, amid, gauss, h, ngrid, gauss3, gauss4] = ...
    setgrid (ngrid, a, b, ic, minh)

% defaults
if nargin < 5, minh = 1/512;, end;
if nargin < 4, ic = 1;, end;
if nargin < 3, b  = 1;, end;
if nargin < 2, a  = 0;, end;

alambda1 = (3 + sqrt(3))/6; alambda2 = (3 - sqrt(3))/6;
n = ngrid-1;
hh = (b-a)/n;

if ic == 1
    h = hh*ones(1, n);
    grid = a + hh*[0:n];
elseif ic == 2
    h = [4/3*hh*ones(1, n/2) 2/3*hh*ones(1, n/2)];
elseif ic == 3
    h = [48/25*hh*ones(1, n/4) 48/50*hh*ones(1, n/4) ...
         48/75*hh*ones(1, n/4) 48/100*hh*ones(1, n/4)];
elseif ic == 4
    h = [2/3*hh*ones(1, n/4) 4/3*hh*ones(1, n/4) ...
         4/3*hh*ones(1, n/4) 2/3*hh*ones(1, n/4)];
elseif ic == 5
    [ngrid, grid, h] = refine(ngrid, a, b, 1, minh);
    n = ngrid-1;
elseif ic == 6
    [ngrid, grid, h] = refine(ngrid, a, b, 2, minh);
    n = ngrid-1;
end
if (ic ~= 1) & (ic ~= 5) & (ic ~= 6)
    grid(1) = a;
    for i = 2:ngrid-1
        grid(i) = grid(i-1) + h(i-1);
    end
    grid(ngrid) = b;
end
amid = (grid(1:ngrid-1) + grid(2:ngrid))/2;
gauss(1:2:2*n-1) = grid(2:n+1) - alambda1*h(1:n);
gauss(2:2:2*n  ) = grid(2:n+1) - alambda2*h(1:n);

% points (nodes) of the 3-point Gauss rule
alambda1 = (1 + sqrt(3/5))/2; alambda2 = (1 - sqrt(3/5))/2;
gauss3(1:3:3*n-2) = grid(2:n+1) - alambda1*h(1:n);
gauss3(2:3:3*n-1) = amid(1:n);
gauss3(3:3:3*n  ) = grid(2:n+1) - alambda2*h(1:n);

% points (nodes) of the 4-point Gauss rule
alambda1 = (1+0.861136311594052)/2;
alambda2 = (1-0.861136311594052)/2;
amu1 = (1+0.339981043584856)/2;
amu2 = (1-0.339981043584856)/2;
gauss4(1:4:4*n-3) = grid(2:n+1) - alambda1*h(1:n);
gauss4(2:4:4*n-2) = grid(2:n+1) -     amu1*h(1:n);
gauss4(3:4:4*n-1) = grid(2:n+1) -     amu2*h(1:n);
gauss4(4:4:4*n  ) = grid(2:n+1) - alambda2*h(1:n);
