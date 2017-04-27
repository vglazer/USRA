% SYNTAX
% testphint(testfno, plots, adap)
%   
% DESCRIPTION
% testphint computes the absolute error and rate of convergence of the 
% specified piecewise Hermite interpolant at the gridpoints, midpoints, 
% t-points and s-points. 
%
% PARAMETERS
% testfno determines the function used to generate the test data. Some 
% representative options are 21, 31 and 41 (for uniform grids) and 903, 
% 904, 905, 1003, 1004, 1012 and 1092 (for adaptive grids). 
% See truevd.m for a complete list. testfno must be specified.
%
% Set plots to 1 in order to display a split plot of the test function
% and the uniform grid versus the adaptive grid (for uniform grids, only
% the first plot is displayed). No plots are displayed by default.
%
% Set adap to 0 to use a uniform grid instead of the default adaptive one. 
%
% EXAMPLES
% testphint(903, 1) - requesting plots
% testphint(31, [], 0) - using a uniform grid
function testphint(testfno, plots, adap)

format compact;
format short e;

% Default argument values
if nargin < 3, adap = 1;, end
if nargin < 2, plots = 0;, end

global Uno Uname;
Uno = testfno;
Uname = ''; % 903 904 905 1004 1092 1012 1003
ax = 0; bx = 1;
if (Uno == 1004) | (Uno == 1092) | (Uno == 1012), ax = -1;, end;
ntimes = 4;  % number of grid sizes to run
errt = zeros(3, ntimes);
errm = zeros(3, ntimes);
errg = zeros(3, ntimes);
errs = zeros(3, ntimes);
errt2 = zeros(3, ntimes);
errm2 = zeros(3, ntimes);
errg2 = zeros(3, ntimes);
errs2 = zeros(3, ntimes);
nconst = 1002; % number of sample points for Uname
tx = ax + (bx-ax)/(nconst-1)*[0:nconst-1]; % map [0,1001] to [ax,bx] 
C = 1/384; ord = 4; invord = 1/ord;

global etaA etaB etaC nu mu R eee;
etaA = 1; etaB = 10000;
mu = 0.5*(ax+bx); nu = 100;
etaC = 1e-2; R = -1/4;
eee = 1e-4;

[udummy] = truevd(ax);

if adap == 0 
    ada = 'no';
else 
    ada = 'yes';
end

disp(['Test function: ' num2str(Uno) ' <=> ' Uname])
disp(['Domain: [' num2str(ax)  ', ' num2str(bx) ']'])
disp(['Adaptive grid: ' ada]);

for nn = 1:ntimes
    n = 2^(nn+5);
    disp([12 'n = ' num2str(n)]);
    ngrid = n+1; nint(1, nn) = n;
    neq = n+3; numeq = neq;
    [gridx, amidx, gaussx, hx, ngrid] = setgrid(ngrid, ax, bx, 1);

    pp = phint(gridx, truevd(gridx));

    [errg, errm, errt, errs] ...
        = pperror1(3, ngrid, gridx, n, amidx, nconst, tx, gaussx, ...
                   pp, nn, errg, errm, errt, errs);
    if adap ~= 0
        nugridx = gradefuncsi(n, gridx, 20, 1e-2, 'eval32', ax, bx, 1/8);
        ppc = pchip(gridx, nugridx);
        nuamidx = ppval(ppc, amidx);
        nugaussx= ppval(ppc, gaussx);

        pp = phint(nugridx, truevd(nugridx));

        [errg2, errm2, errt2, errs2] ...
            = pperror1(3, ngrid, nugridx, n, nuamidx, nconst, tx, ...
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
