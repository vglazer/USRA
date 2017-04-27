% function intrvl = intrvl(p, grid)
%
% returns the interval index which p belongs to.
% grid(intrvl) <= p < grid(intrvl+1) .
% intrvl = ngrid-1 for the right end grid point

function intrvl = intrvl(p, grid)

ngrid = length(grid); % max(size(grid, 2), size(grid, 1));
if p < grid(1) | grid(ngrid) < p
    %disp(['intrvl: point ' num2str(p) ' out of range ' num2str(grid(1)) ' ' num2str(grid(ngrid))]);
    if p < grid(1), intrvl = -10000;, else, intrvl = -20000;, end
else
    for i = 2:ngrid
        if p < grid(i), break, end
    end
    intrvl = i-1;
%   if p == grid(ngrid) , intrvl = ngrid; , end  %do not uncomment this
end
