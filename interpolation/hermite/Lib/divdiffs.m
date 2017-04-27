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
if ndifs > n - 1
    disp(['ndifs value too large; reset to ' num2str(n-1)]);
    ndifs = n - 1;
end
diffs = zeros(ndifs,n-1);
diffs(1,:) = diff(y)./diff(x);
for i = 2:ndifs
    for k = 1:n - i
        diffs(i, k) = (diffs(i-1,k+1) - diffs(i-1,k))/(x(i+k) - x(k));
    end
end
