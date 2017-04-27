% SYNTAX
% pchint(x, y, appord, mconstr, constrtype, u)
%
% DESCRIPTION
% pchint constructs a monotonicity-preserving piecewise cubic Hermite 
% interpolant for the dataset {x,y}, and returns either the interpolant
% itself (as a pp structure) or its values at some specified point vector.
%
% PARAMETERS
% x is the knot vector. x must be specified.
%
% y is the data vector. y must be specified.
%
% appord is the fd formula to be used for approximating f'(x). The supported 
% options are: 
%   2  - uniform O(h^2) formulas
%   21 - nonuniform O(h^2) formulas
%   31 - nonuniform O(h^3) formulas [Lagrange form]
%   32 - nonuniform O(h^3) formulas [Newton form]
%   4  - uniform O(h^4) formulas
%   41 - nonuniform O(h^4) formulas [Lagrange form]
%   42 - Hyman's nonuniform "O(h^4)" formulas
%   43 - A modified version of Hyman's nonuniform "O(h^4)" formulas
%   44 - nonuniform O(h^4) formulas [Newton form]
% appord must be specified. 
% 
% If monconstr is not 0 the approximate derivative values are perturbed
% to preserve monotonicity. Otherwise (i.e. if monconstr = 0) they are
% left unchanged. monconstr must be specified.
% 
% constrtype is the monotonicity constraint to be used. The supported 
% options are:
%   'MP' - a basic second order constraint [Fritsch and Carlson]
%   'MH' - a marginally better second order constraint [Hyman]
%   'M3' - a uniform third order constraint [Huynh]
%   'M4' - a uniform fourth order constraint [Huynh]
% Note that constrtype is ignored when monconstr = 0. constrtype must be 
% specified.
%
% If no point vector u is specified, pchint returns a pp structure containing 
% the interpolant, otherwise it evaluates the interpolant at u and returns 
% the resulting vector.
%
% EXAMPLES
% pchint(x, y, 4, 0, []) 
%   use uniform 4th order formulas to approximate derivative values, don't 
%   constrain them for monotonicity, return a pp structure (no point vector 
%   specified) 
%
% pchint(x, y, 32, 1, 'M4') 
%   use third order nonuniform formulas (in Newton form) to approximate 
%   derivative values, constrain them using a uniform fourth order constraint
%   (i.e. one that preserves third-order approxmiations everywhere), return a 
%   pp structure 
%
% pchint(x, y, 21, 1, 'M3', pts) 
%   use second order nonuniform formulas to approximate the derivative values,
%   constrain them using a uniform third order constraint, return the values 
%   of the resulting interpolant at pts
function v = pchint(x,y,appord,mconstr,constrtype,u)

if size(y,2) == 1, y = y.'; end
[m,n] = size(y);
if length(x) ~= n
   error('Y should have length(X) columns.')
end
if n <= 4
   error('There should be at least five data points.')
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

if nargin == 6
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
      if appord == 0
          [ignore, d] = truevd(x);
      else
          d = approxder(x,y(r,:),appord);
      end
      if mconstr ~= 0, d = perturbder(3, d, x, y(r,:), constrtype);, end
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
      if appord == 0
          [ignore, d] = truevd(x);
      else 
          d = approxder(x,y(r,:),appord);
      end
      if mconstr ~= 0, d = perturbder(3, d, x, y(r,:), constrtype);, end
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

