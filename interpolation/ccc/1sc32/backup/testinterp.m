format short e, format compact
global Uno Uname;
Uno = 31; Uname = ''; % 903 904 905 1004 1092 1012 1003
ax = 0; bx = 1;
if (Uno == 1004) | (Uno == 1092) | (Uno == 1012), ax = -1;, end;
ntimes = 4;  % number of grid sizes to run
nderv  = 3;  % number of derivatives to evaluate: u, ux, uxx
evalf = 'eval32';
errt = zeros(nderv, ntimes);
errm = zeros(nderv, ntimes);
errg = zeros(nderv, ntimes);
errs = zeros(nderv, ntimes);
nconst = 1002; % number of sample points for Uname
tx = ax + (bx-ax)/(nconst-1)*[0:nconst-1]; % map [0,1001] to [ax,bx] 
C = 1/384; ord = 4; invord = 1/ord;

global etaA etaB etaC nu mu R eee;
etaA = 1; etaB = 10000;
mu = 0.5*(ax+bx); nu = 100;
etaC = 1e-2; R = -1/4;
eee = 1e-4;

[udummy] = truevd(ax);
disp(['U = ' Uname ' = {' num2str(Uno) '}'])
disp(['domain [' num2str(ax)  ', ' num2str(bx) ']'])

for nn = 1:ntimes
    n = 2^(nn+3);
    ngrid = n+1; nint(1, nn) = n
    neq = n+3; numeq = neq;
    [gridx, amidx, gaussx, hx, ngrid] = setgrid(ngrid, ax, bx, 1);

    n = ngrid-1; nint(1, nn) = n;
    neq = n+3; numeq = neq;
    extx = bsplex(4, gridx, ngrid);

    dof = si32(gridx);

    [errg, errm, errt, errs] ...
        = error1(ngrid, gridx, n, amidx, nconst, tx, gaussx, ...
                 dof, nn, errg, errm, errt, errs, evalf, extx);

end

format compact
display('error and convergence of standard method')
converge1(nint, ntimes, errg, errm, errt, errs);
nint
