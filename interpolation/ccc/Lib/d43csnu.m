% function [d4, d3] = d43csnu(n, d2, d1, hx)
%
% compute approximations to the fourth and third derivatives of
% the cubic spline approximation at the gridpoints

function [d4, d3] = d43csnu(n, d2, d1, hx)

for i = 2:n
    hh = hx(i-1) + hx(i);
    hE = hx(i);
    hW = hx(i-1);
    d3(i, 1) = 2*(hE*d1(i-1)-hh*d1(i) + hW*d1(i+1))/(hE*hh*hW);
    d4(i, 1) = 2*(hE*d2(i-1)-hh*d2(i) + hW*d2(i+1))/(hE*hh*hW);
%   d3(i, 1) = (d1(i-1) - 2*d1(i) + d1(i+1))/hh^2;
%   d4(i, 1) = (d2(i-1) - 2*d2(i) + d2(i+1))/hh^2;
end
%d3(1,   1) = 2*d3(2, 1) - d3(3,   1);
%d3(n+1, 1) = 2*d3(n, 1) - d3(n-1, 1);
%d4(1,   1) = 2*d4(2, 1) - d4(3,   1);
%d4(n+1, 1) = 2*d4(n, 1) - d4(n-1, 1);
d3(1,   1) = ((hx(1) + hx(2)  )*d3(2, 1) - hx(1)*d3(3,   1))/hx(2);
d3(n+1, 1) = ((hx(n) + hx(n-1))*d3(n, 1) - hx(n)*d3(n-1, 1))/hx(n-1);
d4(1,   1) = ((hx(1) + hx(2)  )*d4(2, 1) - hx(1)*d4(3,   1))/hx(2);
d4(n+1, 1) = ((hx(n) + hx(n-1))*d4(n, 1) - hx(n)*d4(n-1, 1))/hx(n-1);
