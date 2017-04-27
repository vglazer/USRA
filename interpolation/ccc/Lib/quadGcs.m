% function [A, Smx, S, gval] = quadGcs(n, d4, hx, z)
%
% z should be 1/7, 1/9 or 1/8 (Deboor)
% A ~= Int_ax^bx g^z dx
% Smx = max interval integral
% S(i) = hi*gval(i) ~= Int_x_{i-1}^x_i g^z dx by trapezoidal rule
% Here g = (u^(4))^2

function [A, Smx, S, gval] = quadGcs(n, d4, hx, z)

for i = 1:n
    gval(i) = ((d4(i)^2)^z + (d4(i+1)^2)^z)/2;
    S(i) = hx(i)*gval(i);
end
A = sum(S); Smx = max(S);
