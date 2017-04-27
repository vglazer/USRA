% v = pqhint(x,y,appord,mconstr,constrtype,u) - DOESN'T WORK PROPERLY
function v = pqhint(x,y,appord,mconstr,constrtype,u)

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

   delta = u - x(k);
   for r = 1:m
      % Compute coefficients [see Dougherty, Edelman and Hyman (2.2)]. 
      s = diff(y(r,:))./h;
      if appord == 0
          fp  = [0.1507 ,-1.6031,-1.9998,-1.7646,-1.6327, 0.1005];
          fpp = [-3.9886,-2.3916,-0.0503, 1.8828, 2.3103, 3.9949];
      else 
          fp  = approxder(x,y(r,:),appord);
          fpp = approxsecder(x,y(r,:),3);
      end
      if mconstr == 1 
          fp       = perturbder(5,fp,x,y,constrtype);
          [fp,fpp] = perturbders(h,fp,fpp,s);
      end
      c3 = (fpp(2:n) - 3*fpp(1:n-1))./(2*h) + ...
           2*(5*s - 3*fp(1:n-1) - 2*fp(2:n))./h.^2;
      c4 = (3*fpp(1:n-1) - 2*fpp(2:n))./(2*h.^2) + ...
           (8*fp(1:n-1) + 7*fp(2:n) - 15*s)./h.^3;
      c5 = (fpp(2:n) - fpp(1:n-1))./(2*h.^3) + ...
           3*(2*s - fp(2:n) - fp(1:n-1))./h.^4;
   
      % Evaluate interpolant.
      v(m*(p-1)+r) = y(r,k) + delta.*(fp(k) + delta.*(fpp(k)/2 + ...
                     delta.*(c3(k) + delta.*(c4(k) + delta.*c5(k)))));
   end
else
   % Generate piecewise polynomial structure.
   coefs = zeros(6,m*(n-1));
   for r = 1:m
      s = diff(y(r,:))./h;
      if appord == 0
          [ignore,fp,fpp] = truevd(x);
      else 
          fp  = approxder(x,y(r,:),appord);
          fpp = approxsecder(x,y(r,:),3);
      end
      if mconstr == 1
          fp       = perturbder(5, fp, s, constrtype); 
          [fp,fpp] = perturbders(h,fp,fpp,s);
      end
      j = r:m:m*(n-1); 
      % See Dougherty, Edelman and Hyman (2.2).
      coefs(1,j) = (fpp(2:n) - fpp(1:n-1))./(2*h.^3) + ...
                   3*(2*s - fp(2:n) - fp(1:n-1))./h.^4;
      coefs(2,j) = (3*fpp(1:n-1) - 2*fpp(2:n))./(2*h.^2) + ...
                   (8*fp(1:n-1) + 7*fp(2:n) - 15*s)./h.^3;
      coefs(3,j) = (fpp(2:n) - 3*fpp(1:n-1))./(2*h) + ...
                   2*(5*s - 3*fp(1:n-1) - 2*fp(2:n))./h.^2;
      coefs(4,j) = fpp(1:n-1)/2;
      coefs(5,j) = fp(1:n-1);
      coefs(6,j) = y(r,1:n-1);
   end
   v.form = 'pp';
   v.breaks = x;
   v.coefs = coefs.';
   v.pieces = n-1;
   v.order = 6;
   v.dim = m;
end

