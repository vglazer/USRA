format short e, format compact
global Uno Uname;
Uno = 905; Uname = ''; % 903 904 905 1004 1092 1012 1003
ax = 0; bx = 1;
if (Uno == 1004) | (Uno == 1092) | (Uno == 1012), ax = -1;, end;
ntimes = 4;  % number of grid sizes to run
nderv  = 3;  % number of derivatives to evaluate: u, ux, uxx
evalf = 'eval32';
errt = zeros(nderv, ntimes);
errm = zeros(nderv, ntimes);
errg = zeros(nderv, ntimes);
errs = zeros(nderv, ntimes);
errt2 = zeros(nderv, ntimes);
errm2 = zeros(nderv, ntimes);
errg2 = zeros(nderv, ntimes);
errs2 = zeros(nderv, ntimes);
nconst = 1002;
tx = ax + (bx-ax)/(nconst-1)*[0:nconst-1];
C = 1/384; ord = 4; invord = 1/ord;

global etaA etaB etaC nu mu R eee;
etaA = 1; etaB = 10000;
mu = 0.5*(ax+bx); nu = 100;
etaC = 1e-2; R = -1/4;
eee = 1e-4;
maxnu = 20; tolnu = 1e-2;

[udummy] = truevd(ax);
disp(['U = ' Uname ' = {' num2str(Uno) '}'])
disp(['domain [' num2str(ax)  ', ' num2str(bx) ']'])

for nn = 1:ntimes
    n = 2^(nn+3);
    ngrid = n+1; nint(1, nn) = n;
    neq = n+3; numeq = neq;
    [gridx, amidx, gaussx, hx, ngrid] = setgrid(ngrid, ax, bx, 1);
    n = ngrid-1; nint(1, nn) = n;
    neq = n+3; numeq = neq;
    extx = bsplex(4, gridx, ngrid);

    dof = si32(gridx);
    [errg, errm, errt, errs] ...
        = error1(ngrid, gridx, n, amidx, nconst, tx, gaussx, ...
                 dof, nn, errg, errm, errt, errs, evalf, extx);

    [nugridx, S] = gradefuncsi(n, gridx, maxnu, tolnu, evalf, ax, bx, 1/8);
    nuextx = bsplex(4, nugridx, ngrid);
% the following 3 lines are not necessary for the method itself
% you can ignore them
    pp = pchip(gridx, nugridx);
    nuamidx = ppval(pp, amidx);
    nugaussx= ppval(pp, gaussx);

    dof = si32(nugridx);
    [errg2, errm2, errt2, errs2] ...
        = error1(ngrid, nugridx, n, nuamidx, nconst, tx, nugaussx, ...
                 dof, nn, errg2, errm2, errt2, errs2, evalf, nuextx);
end

format compact
display('error and convergence of standard method')
converge1(nint, ntimes, errg, errm, errt, errs);
display('error and convergence of standard method on adaptive grid')
converge1(nint, ntimes, errg2, errm2, errt2, errs2);
nint
% visualize mapping between uniform and nonuniform grid
plot(gridx, nugridx)
