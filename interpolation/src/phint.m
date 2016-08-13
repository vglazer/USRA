% SYNTAX
% phint(x, y, u)
%
% DESCRIPTION
% phint constructs a monotonicity-preserving piecewise cubic Hermite 
% interpolant for the dataset {x,y}, and returns either the interpolant
% itself (as a pp structure) or its values at some specified point vector.
%
% PARAMETERS
% x is the knot vector. x must be specified.
%
% y is the data vector. y must be specified.
%
% If no point vector u is specified, phint returns a pp structure containing 
% the interpolant, otherwise it evaluates the interpolant at u and returns 
% the resulting vector.
% 
% REFERENCES
% Hung T. Huynh, Accurate Monotone Cubic Interpolation, SIAM Journal on
% Numerical Analysis, Volume 30, Number 1, pp. 57-100, February 1993 
function v = phint(x, y, u)

if size(y,2) == 1, y = y.'; end
[m,n] = size(y);
if length(x) ~= n
   error('Y should have length(X) columns.')
end
if n <= 3
   error('There should be at least four data points.')
end
if ~isreal(x)
   error('The data abscissae should be real.')
end
x = x(:)';
h = diff(x);
if any(h < 0)
   [x,p] = sort(x);
   y = y(:,p);
   h = diff(x);
end
if any(h == 0)
   error('The data abscissae should be distinct.');
end

if nargin == 3
   if ~isreal(u)
      error('The interpolation points should be real.')
   end
   v = zeros(m*size(u,1),size(u,2));
   u = u(:)';
   q = length(u);
   if any(diff(u) < 0)
      [u,p] = sort(u);
   else
      p = 1:q;
   end

   % Find indices of subintervals, x(k) <= u < x(k+1).
   if isempty(u)
      k = u;
   else
      [ignore,k] = histc(u,x);
      k(u<x(1) | ~isfinite(u)) = 1;
      k(u>=x(n)) = n-1;
   end

   s = u - x(k);
   for r = 1:m
      % Compute slopes and other coefficients.
      del = diff(y(r,:))./h;
      d = approxder(x,y(r,:));
      d = perturbder(d, x, y(r,:));
      c = (3*del - 2*d(1:n-1) - d(2:n))./h;
      b = (d(1:n-1) - 2*del + d(2:n))./h.^2;
   
      % Evaluate interpolant.
      v(m*(p-1)+r) = y(r,k) + s.*(d(k) + s.*(c(k) + s.*b(k)));
   end
else
   % Generate piecewise polynomial structure.
   coefs = zeros(4,m*(n-1));
   for r = 1:m
      del = diff(y(r,:))./h;
      d = approxder(x,y(r,:));
      d = perturbder(d, x, y(r,:));
      j = r:m:m*(n-1);
      coefs(1,j) = (d(1:n-1) - 2*del + d(2:n))./h.^2;
      coefs(2,j) = (3*del - 2*d(1:n-1) - d(2:n))./h;
      coefs(3,j) = d(1:n-1);
      coefs(4,j) = y(r,1:n-1);
   end
   v.form = 'pp';
   v.breaks = x;
   v.coefs = coefs.';
   v.pieces = n-1;
   v.order = 4;
   v.dim = m;
end

%--------------------------------------------------------------------------
% SYNTAX
% divdiffs(x, y, ndifs)
%
% DESCRIPTION
% divdiffs returns a length(x)-1 by length(x)-1 triangular matrix whose nth 
% row is the nth divided difference of x and y = f(x)
%
% PARAMETERS
% x is the knot vector. x must be specified.
%
% y is the data vector. y must be specified.
%
% ndifs is the number of divided differences to compute (ndifs <= n - 1).
% ndifs must be specified.
function diffs = divdiffs(x, y, ndifs)

n = length(y);
diffs = zeros(ndifs,n-1);
diffs(1,:) = diff(y)./diff(x);
for i = 2:ndifs
    for k = 1:n - i
        diffs(i, k) = (diffs(i-1,k+1) - diffs(i-1,k))/(x(i+k) - x(k));
    end
end

%-----------------------------------------------------------------------
% SYNTAX
% vecdiffs(x, y)
% 
% DESCRIPTION
% vecdiffs returns the first three rows of the matrix divdiffs(x,y,3) as 
% row vectors s, d and e.
%
% PARAMETERS
% x is the knot vector. x must be specified.
%
% y is the data vector. y must be specified.
function [s,d,e] = vecdiffs(x,y)
n = length(y);
diffs = divdiffs(x,y,3);

s = diffs(1,:);
d = diffs(2,1:n-2);
e = diffs(3,1:n-3);

%--------------------------------------------------------------------------
% SYNTAX 
% approxder(x, y) 
%
% DESCRIPTION
% approxder approximates the derivative values of the function x |-> y 
% using third order nonuniform finite difference formulae [in Newton form]. 
% 
% PARAMETERS
% x is the knot vector. x must be specified.
% 
% y is the data vector. y must be specified.
function d = approxder(x, y)
n = length(y);
d = zeros(1,n);

% Compute the first, second and third divided differences 
[s,ds,e] = vecdiffs(x,y);

% Approximate derivative values at the left boundary and interior points
for k = 1:n-3
    d(k) = s(k) + ds(k)*(x(k) - x(k+1)) + ...
           e(k)*(x(k)^2 + x(k+1)*x(k+2) - x(k)*x(k+1) - x(k)*x(k+2));
end

% Approximate derivative values at the right boundary 
w1 = 3*e(n-3);
w2 = 2*(ds(n-3) - e(n-3)*(x(n-3) + x(n-2) + x(n-1)));
rest = s(n-3) - ds(n-3)*(x(n-3) + x(n-2)) + ...
       e(n-3)*(x(n-3)*x(n-2) + x(n-3)*x(n-1) + x(n-2)*x(n-1));
d(n-2) = w1*x(n-2)^2 + w2*x(n-2) + rest; 
d(n-1) = w1*x(n-1)^2 + w2*x(n-1) + rest;
d(n)   = w1*x(n)  ^2 + w2*x(n)   + rest;

%-----------------------------------------------------------------------
% SYNTAX
% perturbder(d, x, y)
%
% DESCRIPTION
% perturbder perturbs the derivative values d to ensure monotonicity. 
%
% PARAMETERS
% d is the vector of approximate derivative values. d must be specified.
%
% x is the knot vector. x must be specified.
% 
% y is the data vector. y must be specified.
function dper = perturbder(d, x, y)
n = length(d);
dper = d;

% Compute first and second divided differences
[s,ds] = vecdiffs(x,y);

% Compute minmods of divided differences
smin = zeros(1,n-2);
for k = 1:n-2
    smin(k) = minmod(s(k),s(k+1));
end
dmin = zeros(1,n-3);
for k = 1:n-3
    dmin(k) = minmod(ds(k),ds(k+1));
end

% Apply basic monotonicity constraints at and near the boundary
dper(1)   = minmod(d(1),   3*s(1));
dper(2)   = minmod(d(2),   3*minmod(s(1), s(2)));
dper(n)   = minmod(d(n),   3*s(n-1));
dper(n-1) = minmod(d(n-1), 3*minmod(s(n-2), s(n-1)));

% Apply M3 constraint to original derivative approximations 
% at interior points
for k = 3:n-2
    p1 = s(k-1) + dmin(k-2)*(x(k) - x(k-1));
    p2 = s(k)   + dmin(k-1)*(x(k) - x(k+1));
    t = minmod(p1,p2);
    tmax = sign(t)*max(3*abs(smin(k-1)), (3/2)*abs(t)); 
    dper(k) = minmod(d(k),tmax);
end

%-----------------------------------------------------------------------------
% SYNTAX 
% minmod(x, y) 
%
% DESCRIPTION
% Conceptually, minmod(x,y) simply returns the result of median(x, y, 0). In
% other words, it returns 0 if x and y are of opposite sign and the smaller of
% the two in absolute value otherwise.
function mm = minmod(x, y)

mm = 0.5*(sign(x) + sign(y))*min(abs(x),abs(y));

%-----------------------------------------------------------------------------
% SYNTAX
% median(x, y, z) 
% 
% DESCRIPTION
% Conceptually, median sorts the list [x, y, z] and return the middle element.
function med = median(x, y, z)

med = x + minmod(y - x, z - x);

