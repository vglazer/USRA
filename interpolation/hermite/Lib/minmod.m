% SYNTAX 
% minmod(x, y) 
%
% DESCRIPTION
% Conceptually, minmod(x,y) simply returns the result of median(x, y, 0). In
% other words, it returns 0 if x and y are of opposite sign and the smaller of
% the two in absolute value otherwise.
%
% EXAMPLES
% minmod(-1, 5) returns 0 since x and y have opposite signs
% minmod(1, 5) returns 1 
% minmod(-1, -5) returns -1
function mm = minmod(x,y)

mm = 0.5*(sign(x) + sign(y))*min(abs(x),abs(y));
