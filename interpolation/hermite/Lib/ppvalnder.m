% SYNTAX
% ppvalnder(pp, xx, nder) 
% 
% DESCRIPTION
% ppvalnder returns an nder by length(xx) matrix whose rows are the respective 
% values of the piecewise polynomial contained in structure pp and its first 
% nder-1 derivatives at points xx. 
function vals = ppvalnder(pp, xx, nder)

numbreaks = length(pp.breaks); 
numpts    = length(xx);
vals      = zeros(1, numpts);
dvals     = zeros(1, numpts);
ddvals    = zeros(1, numpts);
for pt = 1:numpts
    x = xx(pt);
    % Abort if x lies outside of Domain(pp)
    if x > pp.breaks(numbreaks) | x < pp.breaks(1)
         disp(['ppval1: point ' num2str(x) ' out of range [' ... 
         num2str(pp.breaks(1)) ', ' num2str(pp.breaks(numbreaks)) ... 
         ']']); return;
    end

    % Determine which grid subinterval x belongs to (i.e. which 
    % polynomial piece should be used to evaluate pp at x)
    pnums = zeros(1, numpts);
    for brk = 2:numbreaks
        if x <= pp.breaks(brk) 
            pnum = brk - 1; 
            break 
        end
    end

    % Compute pp_super(n)(x) for n = 0, ..., nder - 1
    a = pp.breaks(pnum); 
    p = pp.coefs(pnum, :); 
    vals(1, pt) = polyval(p, x - a);
    for i = 2:nder
        p = polyder(p); 
        vals(i, pt) = polyval(p, x - a);
    end
end

