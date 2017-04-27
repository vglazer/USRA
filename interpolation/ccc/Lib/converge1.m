% function converge1(nint, ntimes, errg, errm, errt, errs, flagplot)
function converge1(nint, ntimes, errg, errm, errt, errs, flagplot)

%defaults
if nargin < 7, flagplot = 0;, end;
format short e
format compact
errg
errm
errt
errs

if ntimes > 1
    format short
    nderv = size(errt, 1);
    LogNintRatio = log(nint(1, 2:ntimes)./nint(1, 1:ntimes-1));
    LogNintRatioMat = repmat(LogNintRatio, nderv, 1);

    %for the purpose of studying the order of convergence,
    %zero errors are avoided, because they cause exceptions
    %ignore any orders <=~ 0
    errg(:, :) = max(errg(:, :),  0.222044604925e-15);
    errm(:, :) = max(errm(:, :),  0.222044604925e-15);
    errt(:, :) = max(errt(:, :),  0.222044604925e-15);
    errs(:, :) = max(errs(:, :),  0.222044604925e-15);

    convg = log(errg(:, 1:ntimes-1)./errg(:, 2:ntimes))./LogNintRatioMat
    convm = log(errm(:, 1:ntimes-1)./errm(:, 2:ntimes))./LogNintRatioMat
    convt = log(errt(:, 1:ntimes-1)./errt(:, 2:ntimes))./LogNintRatioMat
    convs = log(errs(:, 1:ntimes-1)./errs(:, 2:ntimes))./LogNintRatioMat

    if flagplot
        loglog(nint, errg(1, :), 'x', nint, errg(1, :), 'g-', ...
               nint, errt(1, :), 'o', nint, errt(1, :), 'g-', ...
               nint, errs(2, :), '.', nint, errs(2, :), 'g-', ...
               nint, errm(2, :), '*', nint, errm(2, :), 'g-', ...
               nint, errm(3, :), '+', nint, errm(3, :), 'g-')
        xlabel('grid size'); ylabel('error');
        title('x -> errg1, o -> errt1, . -> errs2, * -> errm2, + -> errm3');
    end
end

