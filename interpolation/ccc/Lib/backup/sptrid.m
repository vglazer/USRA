% function [T] = sptrid(l, d, u, n)
% T = spdiags([l*ones(n, 1), d*ones(n, 1), u*ones(n, 1)], [-1, 0, 1], n, n);

function [T] = sptrid(l, d, u, n)

T = spdiags([l*ones(n, 1), d*ones(n, 1), u*ones(n, 1)], [-1, 0, 1], n, n);
