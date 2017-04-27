% SYNTAX
% vecdiffs(x, y)
% 
% DESCRIPTION
% vecdiffs returns four vectors, s, d, e and f, which are just the respective 
% rows of divdiffs(x, y, 4), i.e. the divided differences of x and y of
% orders 1 through 4
%
% PARAMETERS
% x is the knot vector. x must be specified.
%
% y is the data vector. y must be specified.
function [s,d,e,f] = vecdiffs(x,y)
n = length(y);
diffs = divdiffs(x,y,4);

s = diffs(1,:);
d = diffs(2,1:n-2);
e = diffs(3,1:n-3);
f = diffs(4,1:n-4);
