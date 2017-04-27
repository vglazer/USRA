% SYNTAX
% testpcqhint(nder, appord, testfno, monconstr, constrtype, plots, adap)
%   
% DESCRIPTION
% testphint computes the absolute error and rate of convergence of the 
% specified piecewise Hermite interpolant at the gridpoints, midpoints, 
% t-points and s-points. 
%
% PARAMETERS
% nder is the desired interpolant degree. The supported options are 3 and 5.
% nder must be specified.
%
% testfno determines the function used to generate the test data. Some 
% representative options are 21, 31 and 41 (for uniform grids) and 903, 
% 904, 905, 1003, 1004, 1012 and 1092 (for adaptive grids). 
% See truevd.m for a complete list. testfno must be specified.
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
% Newton O(h^3) formulas (32) perform best overall. appord must be specified.
%
% Set monconstr to 0 to turn off monotonicity constraints. They are on by
% default.
%
% constrtype is the monotonicity constraint to be used. The supported 
% options are:
%   'MP' - a basic second order constraint [Fritsch and Carlson]
%   'MH' - a marginally better second order constraint [Hyman]
%   'M3' - a uniform third order constraint [Huynh]
%   'M4' - a uniform fourth order constraint [Huynh]
% The default constraint is 'M4'. constrtype is ignored when monconstr = 0. 
%
% Set plots to 1 in order to display a split plot of the test function
% and the uniform grid versus the adaptive grid (for uniform grids, only
% the first plot is displayed). No plots are displayed by default.
%
% Set adap to 0 to use a uniform grid instead of the default adaptive one. 
%
% EXAMPLES
% testpcqhint(3, 32, 1012) - using default values
% testpcqhint(3, 44, 1092, 0) - turning off monotonicity constraints 
% testpcqhint(3, 21, 903, 1, 'M3') - selecting a different constraint type
% testpcqhint(3, 31, 905, 0, [], 1) - requesting plots
% testpcqhint(3, 4, 31, 1, 'MH', [], 0) - using a uniform grid
function testpcqhint(nder, appord, testfno, monconstr, constrtype, plots, adap)

format compact;
format short e;

% Default argument values
if nargin < 7, adap = 1;, end
if nargin < 6, plots = 0;, end
if nargin < 5, constrtype = 'M4';, end
if nargin < 4, monconstr = 1;, end 

global Uno Uname;
Uno = testfno;
Uname = ''; % 903 904 905 1004 1092 1012 1003
ax = 0; bx = 1;
if (Uno == 1004) | (Uno == 1092) | (Uno == 1012), ax = -1;, end;
ntimes = 4;  % number of grid sizes to run
errt = zeros(nder, ntimes);
errm = zeros(nder, ntimes);
errg = zeros(nder, ntimes);
errs = zeros(nder, ntimes);
errt2 = zeros(nder, ntimes);
errm2 = zeros(nder, ntimes);
errg2 = zeros(nder, ntimes);
errs2 = zeros(nder, ntimes);
nconst = 1002; % number of sample points for Uname
tx = ax + (bx-ax)/(nconst-1)*[0:nconst-1]; % map [0,1001] to [ax,bx] 
C = 1/384; ord = 4; invord = 1/ord;

global etaA etaB etaC nu mu R eee;
etaA = 1; etaB = 10000;
mu = 0.5*(ax+bx); nu = 100;
etaC = 1e-2; R = -1/4;
eee = 1e-4;

[udummy] = truevd(ax);

if nder == 3
    pptype = 'pchint';
elseif nder == 5 
    pptype = 'pqhint';
end
   
if appord == 0
    aord = 'true values';
else
    aord = num2str(appord);
end
if monconstr ~= 0 
    mconstr = 'yes';
else
    mconstr = 'no';
end
if adap == 0 
    ada = 'no';
else 
    ada = 'yes';
end
if monconstr ~= 0
    constrtp = constrtype;
else 
    constrtp = 'NA';
end

disp(['Interpolant type: ' pptype]);
disp(['Finite difference formula: ' aord]);
disp(['Monotonicity constraint: ' mconstr]);
disp(['Constraint type: ' constrtp]);
disp(['Test function: ' num2str(Uno) ' <=> ' Uname])
disp(['Domain: [' num2str(ax)  ', ' num2str(bx) ']'])
disp(['Adaptive grid: ' ada]);

for nn = 1:ntimes
    n = 2^(nn+5);
    disp([12 'n = ' num2str(n)]);
    ngrid = n+1; nint(1, nn) = n;
    neq = n+3; numeq = neq;
    [gridx, amidx, gaussx, hx, ngrid] = setgrid(ngrid, ax, bx, 1);

    pp = feval(pptype, gridx, truevd(gridx), appord, monconstr, constrtype);

    [errg, errm, errt, errs] ...
        = pperror1(nder, ngrid, gridx, n, amidx, nconst, tx, gaussx, ...
                   pp, nn, errg, errm, errt, errs);
    if adap ~= 0
        nugridx = gradefuncsi(n, gridx, 20, 1e-2, 'eval32', ax, bx, 1/8);
        ppc = pchip(gridx, nugridx);
        nuamidx = ppval(ppc, amidx);
        nugaussx= ppval(ppc, gaussx);

        pp = feval(pptype, nugridx, truevd(nugridx), appord, ... 
                   monconstr, constrtype);

        [errg2, errm2, errt2, errs2] ...
            = pperror1(nder, ngrid, nugridx, n, nuamidx, nconst, tx, ...
                       nugaussx, pp, nn, errg2, errm2, errt2, errs2);
    end 
end
disp(['Error and convergence on uniform grid:'  12]);
disp(['grid sizes: ' num2str(nint)]);
converge1(nint, ntimes, errg, errm, errt, errs);
if plots == 1
    plot(gridx, ppvalnder(pp,gridx,1));
    title(['Test Function: ' Uname]);
end

if adap ~= 0
    disp([12 'Error and convergence on adaptive grid:'  12]);
    disp(['grid sizes: ' num2str(nint)]);
    converge1(nint, ntimes, errg2, errm2, errt2, errs2);
    if plots == 1
        subplot(1,2,1);
        plot(nugridx, ppvalnder(pp,nugridx,1));
        title(['Test Function: ' Uname]);
        subplot(1,2,2);
        plot(gridx, nugridx);
        title('Uniform grid VS Adaptive grid');
    end
end
