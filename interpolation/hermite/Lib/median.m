% SYNTAX
% median(x, y, z) 
% 
% DESCRIPTION
% Conceptually, median sorts the list [x, y, z] and return the middle element.
%
% EXAMPLES
% median(10, -5, 2) sorts the input to get [-5, 2, 10] and returns 2
function med = median(x,y,z)

med = x + minmod(y - x, z - x);
