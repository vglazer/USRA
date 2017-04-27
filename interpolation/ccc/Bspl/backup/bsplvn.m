% function [vnikx, j, deltam, deltap] = ...
%           bsplvn(xt, jhigh, index, x, ileft, vnikx, j, deltam, deltap)
%
% returns vnikx as a 1 x 1 or 2 x 1 or ... or kord x 1 array to bsplvd

function [vnikx, j, deltam, deltap] = ...
          bsplvn(xt, jhigh, index, x, ileft, vnikx, j, deltam, deltap)

if index ~= 2
    j = 1;
    vnikx(1) = 1;
end
while ((j >= 1) & (index == 2)) | ((j < jhigh) & (index ~= 2))
    ipj = ileft+j;
    deltap(j) = xt(ipj) - x;
    imjp1 = ileft-j+1;
    deltam(j) = x - xt(imjp1);
    vmprev = 0;
    jp1 = j+1;
    for l = 1:j
        jp1ml = jp1-l;
        vm = vnikx(l)/(deltap(l) + deltam(jp1ml));
        vnikx(l) = vm*deltap(l) + vmprev;
        vmprev = vm*deltam(jp1ml);
    end
    vnikx(jp1) = vmprev;
    j = jp1;
    if j >= jhigh, break, end
end
