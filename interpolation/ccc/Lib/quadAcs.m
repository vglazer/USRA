% function [A, Smx, S, gval] = quadAcs(n, d1, hx, z)
%
% z should be 1/2
% A ~= Int_ax^bx g^z dx
% Smx = max interval integral
% S(i) = hi*gval(i) ~= Int_x_{i-1}^x_i g^z dx by trapezoidal rule
% Here g = 1 + (u')^2

function [A, Smx, S, gval] = quadAcs(n, d1, hx, z)

z = 1/2;
for i = 1:n
    gval(i) = ((1+d1(i)^2)^z + (1+d1(i+1)^2)^z)/2;
    S(i) = hx(i)*gval(i);
end
A = sum(S); Smx = max(S);
