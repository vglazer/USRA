% function vnikx = bsplvd(xt, k, x, ileft, nderiv)
%
% returns the values of the non-zero order k b-splines
% and the first nderiv-1 derivatives on x.
% xt is the (extended) gridpoint sequence.
% vnikx is k X nderiv.
% ileft is the index of the xt gridpoint to the left of x, starting with 1.
% If x is a gridpoint, ileft is its index.
% bspl(i, j) is the value of the j-1st deriv. of the i-th non-zero spline

function vnikx = bsplvd(xt, k, x, ileft, nderiv)

if nargin < 5
    nderiv = k;
end
vnikx = zeros(k, nderiv);
jj = 1;
deltam = zeros(1, 20);
deltap = zeros(1, 20);

ko = k + 1 - nderiv;
vnt = vnikx(nderiv:k, nderiv);
[vnt, jj, deltam, deltap] = bsplvn(xt, ko, 1, x, ileft, vnt, jj, deltam, deltap);
vnikx(nderiv:k, nderiv) = vnt;
if nderiv > 1
    ideriv = nderiv;
    for i = 2:nderiv
        idervm = ideriv-1;
        for j = ideriv:k
            vnikx(j-1, idervm) = vnikx(j, ideriv);
        end
        ideriv = idervm;
        vnt = vnikx(ideriv:k, ideriv);
        [vnt, jj, deltam, deltap] = bsplvn(xt, 0, 2, x, ileft, vnt, jj, deltam, deltap);
        vnikx(ideriv:k, ideriv) = vnt;
    end

    a = eye(k, k);

    kmd = k;
    for m = 2:nderiv
        kmd = kmd - 1;
        i = ileft;
        for j = k:-1:1
            jm1 = j-1;
            ipkmd = i + kmd;
            diff = xt(ipkmd) - xt(i);
            if jm1 == 0, break, end
            if diff ~= 0
                for l = 1:j
                    a(l, j) = (a(l, j) - a(l, j-1))/diff * kmd;
                end
            end
            i = i - 1;
        end
        if diff ~= 0
            a(1, 1) = a(1, 1)/diff * kmd;
        end
        for i = 1:k
            v = 0;
            jlow = max(i, m);
            for j = jlow:k
                v = a(i, j)*vnikx(j, m) + v;
            end
            vnikx(i, m) = v;
        end
    end
end
