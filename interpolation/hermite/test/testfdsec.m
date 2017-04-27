% SYNTAX
% testfdsec(appord, testfno, ntimes, thresh)
%
% DESCRIPTION
% testfd is used to test the convergence properties of the finite difference 
% formulas for the second derivative found in approxsecder. 
%
% PARAMETERS
% appord is the fd formula to be tested. The supported options are: 
%   1 - nonuniform O(h) formulas
%   3 - nonuniform O(h^3) formulas [Lagrange form]
% appord must be specified. 
%
% testfno is the function the formula will be tested on (see truevd for a 
% complete list). testfno must be specified.  
%
% ntimes determines the number of test grids and their size via the 
% following relationship: gridsize_i = 2^(i+5), i = 1,...,ntimes.
% ntimes must be specified. 
%
% thresh is the desired error threshold: gridpoints where the true error 
% differs from the expected error by more than 10^thresh are flagged when the 
% function is subsequently plotted. The default value for thresh is 0.
%
% EXAMPLES
% testfdsec(1,31,4)
%   test the nonuniform O(h) formulas on x^4 using four grids of sizes 64, 
%   128, 256 and 512. Use the default error threshhold, i.e. flag gridpoints 
%   where the error is > 10^0 = 1.
%
% testfdsec(3,1004,5,-3) 
%   test the Lagrange form of the nonuniform O(h^3) formulas on function 
%   1004 using five grids of sizes 64-1024. Flag gridpoints where the error 
%   is > 10^(-3) = 0.001.
function testfdsec(appord, testfno, ntimes, thresh)

if nargin < 4, thresh = 0;, end

global Uno Uname;
Uno = testfno;
Uname = ''; 
ax = 0; bx = 1;
if (Uno == 1004) | (Uno == 1092) | (Uno == 1012), ax = -1;, end;
nconst = 1002; % number of sample points for Uname
tx = ax + (bx-ax)/(nconst-1)*[0:nconst-1]; % map [0,1001] to [ax,bx] 
C = 1/384; ord = 4; invord = 1/ord;

global etaA etaB etaC nu mu R eee;
etaA = 1; etaB = 10000;
mu = 0.5*(ax+bx); nu = 100;
etaC = 1e-2; R = -1/4;
eee = 1e-4;
[udummy] = truevd(ax);

disp(['Order of derivative approximation: ' num2str(appord)]);
disp(['Test function: ' num2str(Uno) ' <=> ' Uname])
disp(['Domain: [' num2str(ax)  ', ' num2str(bx) ']'])
disp(['Error threshhold: ' num2str(10^thresh)]);

if appord < 10
    fixord = appord;
else
    fixord = floor(appord/10);
end
for nn = 1:ntimes
    n = 2^(nn+5);
    disp([12 'n = ' num2str(n)]);
    ngrid = n+1; nint(1, nn) = n;
    neq = n+3; numeq = neq;

    % set adaptive grid
    gridx = setgrid(ngrid, ax, bx, 1);
    nugridx = gradefuncsi(n, gridx, 20, 1e-2, 'eval32', ax, bx, 1/8);

    % compute actual error
    [truevals,dummy,secdervals] = truevd(nugridx);
    appvals = approxsecder(nugridx,truevals,appord);
    errvals = abs(secdervals - appvals);
    maxerr = max(errvals);
    disp(['actual error = ' num2str(maxerr)]);

    % computed expected error based on specified order of convergence 
    if nn > 1
        % orders such as 4x are converted to 4, etc.
        experr = 2^(-fixord)*preverr;
        disp(['expected error = ' num2str(experr)]);
    end
    preverr = maxerr;
end

badpts = zeros(1,n);
ind = 0;
for k = 1:n
    if errvals(k) > 10^thresh
        badpts(ind + 1) = nugridx(k);
        ind = ind + 1;
    end
end
% bad points information
disp([12 num2str(ind) '/' num2str(n)  ' = ' num2str(ind/n*100) '% points ' ... 
     'where error in second derivative approximation > ' num2str(10^thresh)]);
clf;
hold on;
if (ind > 1), plot(badpts,truevd(badpts),'o');, end
plot(nugridx,truevd(nugridx));
title(['Points where error in second derivative approximation > ' ...
      num2str(10^thresh)]);
hold off;
