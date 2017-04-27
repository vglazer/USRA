% [T] = SPPENTAD(l2, l1, d, u1, u2, n)

function [T] = sppentad(l2, l1, d, u1, u2, n)

T = spdiags([l2*ones(n, 1), l1*ones(n, 1), d*ones(n, 1), ...
            u1*ones(n, 1), u2*ones(n, 1)], [-2, -1, 0, 1, 2], n, n);

