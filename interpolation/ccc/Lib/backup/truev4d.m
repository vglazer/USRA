% [true1, true2, true3, true4, true5] = TRUEV4D(x)
%
% Returns the values of the solution function, plus its first 
% four derivatives on x.

function [true1, true2, true3, true4, true5] = truevd(x)

global Uno Uname;
global etaA etaB etaC nu mu R eee;

o = ones(size(x)); z = zeros(size(x));

switch Uno
case {1003}
    Uname ='SP pg 390 ex 10.3 -- boundary layer at 0';
%from Ascher+M+R pg 390 ex 10.3 -- boundary layer at 0, when 0 <~ eee
%-1, 2+cos(pi*x), eee, [0, 1]
true1 = cos(pi*x) - exp(-3*x/eee); % + O(eee^2)
true2 = -pi*sin(pi*x) + 3*exp(-3*x/eee)/eee;
true3 = -pi*pi*cos(pi*x) - 9*exp(-3*x/eee)/eee^2;

case {1012}
    Uname ='SP pg 442 ex 10.12 -- boundary layers at -1 and 1';
%from Ascher+M+R pg 442 ex 10.12 -- boundary layers at -1 and 1, when 0 <~ eee
%-0.5, -x, eee, [-1, 1]
true1 = exp(-(x+1)/eee) + 2*exp((x-1)/eee); % + O(eee)
true2 = (-exp(-(x+1)/eee) + 2*exp((x-1)/eee))/eee;
true3 = true1/eee^2;

case {1092}
    Uname ='SP pg 371 ex 9.2 -- interior schock layer at 0';
%from Ascher+M+R pg 371 ex 9.2 -- interior schock layer at 0, when 0 <~ eee
%0, x, eee, [-1, 1]
t = erf(1/sqrt(2*eee));
true1 = cos(pi*x) + erf(x/sqrt(2*eee))/t;
w = exp(-x.^2/(2.*eee))*sqrt(2)/(sqrt(eee).*sqrt(pi).*t);
true2 = -sin(pi.*x).*pi + w;
true3 = -cos(pi.*x)*pi.^2 - w.*x/eee;

case {1004}
    Uname ='SP pg 394 ex 10.4 -- interior schock layer at 0';
%from Ascher+M+R pg 394 ex 10.4 -- interior schock layer at 0, when 0 <~ eee
% 0, 2*x, eee, [-1, 1]
true1 = erf(x/sqrt(eee));
true2 = 2*exp(-x^2/eee)/sqrt(pi*eee);
true3 = -2*x*true2/eee;

case {913}
    Uname ='PB ?? boundary?? layer at 0';
%from Carey+Dinh PB 3 -- layer at 0, when etaC > 0 and R < 0.
true1 = -(x + etaC)^R + (etaC^R*(1-x) + (1+etaC)^R*x);
true2 = -R*(x + etaC)^(R-1) - etaC^R + (1+etaC)^R;
true3 = -R*(R-1)*(x + etaC)^(R-2);

case {911}
    Uname ='PB ?? boundary layer at 1';
%from Carey+Dinh PB 1 -- boundary layer at 1, when 0 < etaC << 1
w = sinh(1/etaC);
true1 = sinh(x/etaC)/w;
true2 = cosh(x/etaC)/w/etaC;
true3 = true1/etaC^2;

case {906}
    Uname ='PB 6 -- nonlinear';
%PB 6 in [320] from Russell and Shampine -- nonlinear
c = 1.336056;
true1 = -log(2) + 2*log(c*sec(c*(x-.5)/2));
true2 = c*tan(c*(x-.5)/2);
true3 = c^2/2*(1 + true2.^2);

case {905}
    Uname ='PB 5 -- interior layer at mu';
%PB 5 in [320] from Carey and Dinh PB 2 -- interior layer at mu, when nu large
%coefu = 0; coefux = -2*nu*(x-mu); coefuxx = -1/nu - nu*(x-mu)^2;
w = 1 + nu^2*(x-mu)^2;
r = atan(nu*(x-mu)) + atan(nu*mu);
true1 = (1-x)*r;
true2 = -r+(1-x)*nu/w;
true3 = -2*nu/w -2*(1-x)*nu^3*(x-mu)/w^2;

case {904}
    Uname ='PB 4 -- boundary layers at 0 and 1';
%PB 4 in [320]
%adapted from Celia+Gray -- boundary layers at 0 and 1, when etaB large
%coefu =-1; coefux = 1; coefuxx = 1;
r = etaB/etaA; p = 1+r*x; q = 1+r*(1-x); w = log(p); v = log(q);
c = 1/(log(1+r))^2;
true1 = c*w*v;
true2 = c*r*(v/p - w/q);
true3 = -c*r^2*(v/p^2 + 2/(p*q) + w/q^2);

case {903}
    Uname ='PB 3 -- boundary layer at 0';
%PB 3 in [320] from Celia+Gray pg 180 -- boundary layer at 0, when etaB large
%coefu = 0; coefux = etaB; coefuxx = etaA+etaB*x;
r = etaB/etaA; c = log(1+r); v = 1+r*x;
true1 = log(v)/c; true2 = r/v/c; true3 = -r^2/v^2/c;
%true1 = log(1+etaB*x/etaA)/log(1+etaB/etaA);
%true2 = etaB/(log(1+etaB/etaA)*(1+etaB*x/etaA)*etaA);
%true3 = -(etaB/etaA)^2/(log(1+etaB/etaA)*(1+etaB*x/etaA)^2);

% from here on this file needs more work!!!

case {166}
    Uname =    'x^(13/2) -    2 * x^(11/2) +        x^(9/2)';
true1 =         x^(13/2) -    2 * x^(11/2) +        x^(9/2);
true2 =  13/2 * x^(11/2) -   11 * x^(9/2)  +  9/2 * x^(7/2);
true3 = 143/4 * x^(9/2)  - 99/2 * x^(7/2)  + 63/4 * x^(5/2);

%a = 3;
%true1 = x^a;       true2 = a*x^(a-1);     true3 = a*(a-1)*x^(a-2);

case {165}
    Uname ='x.^(13/2)';
true1 = x.^(13/2);  true2 = 13/2*x.^(11/2); true3 = 143/4*x.^(9/2);
true4 =1287/8*x.^(7/2); true5 =9009/16*x.^(5/2);

case {155}
    Uname ='x.^(11/2)';
true1 = x.^(11/2);  true2 = 11/2*x.^(9/2);  true3 = 99/4*x.^(7/2);
true4 =693/8*x.^(5/2); true5 =3465/16*x.^(3/2);

case {145}
    Uname ='x.^(9/2)';
true1 = x.^(9/2);   true2 = 9/2*x.^(7/2);   true3 = 63/4*x.^(5/2);
true4 =105/8*x.^(3/2); true5 =105/16*x.^(1/2);

case {135}
    Uname ='x.^(7/2)';
true1 = x.^(7/2);   true2 = 7/2*x.^(5/2);   true3 = 35/4*x.^(3/2);
true4 =105/8*x.^(1/2); true5 =105/16*x.^(-1/2);

case {125}
    Uname ='x.^(5/2)';
true1 = x.^(5/2);   true2 = 5/2*x.^(3/2);   true3 = 15/4*x.^(1/2);
true4 =15/8*x.^(-1/2); true5 =-15/16*x.^(-3/2);

case {115}
    Uname ='x.^(3/2)';
true1 = x.^(3/2);   true2 = 3/2*x.^(1/2);   true3 =  3/4*x.^(-1/2);
true4 =-3/8*x.^(-3/2); true5 = 9/16*x.^(-5/2);

case {109}
    Uname ='exp(x)';
true1 = exp(x);    true2 = exp(x);      true3 = exp(x);
true4 = exp(x);    true5 = exp(x);

case {101}
    Uname ='cos(x)';
true1 = cos(x);    true2 =-sin(x);      true3 =-cos(x);
true4 = sin(x);    true5 = cos(x);

case {100}
    Uname ='sin(x)';
true1 = sin(x);    true2 = cos(x);      true3 =-sin(x);
true4 =-cos(x);    true5 = sin(x);

%true1 = sin(x*pi/2); true2 = pi/2*cos(x*pi/2); true3 =-pi^2/4*sin(x*pi/2);
%true1 = sin(2*pi*x); true2 = 2*pi*cos(2*pi*x); true3 =-(2*pi)^2*sin(2*pi*x);

%u^(3) = 0, u^(4) = 0 at x = 0, x = 1
%true1 = x^7/210 - x^6/60 + x^5/60;
%true2 = x^6/30  - x^5/10 + x^4/12;
%true3 = x^5/5   - x^4/2  + x^3/3;

case {61}
    Uname ='x^7';
true1 = x.^7;       true2 = 7*x.^6;       true3 = 42*x.^5;
true4 =210*x.^4;    true5 = 840*x.^3;

case {51}
    Uname ='x^6';
true1 = x.^6;       true2 = 6*x.^5;       true3 = 30*x.^4;
true4 =120*x.^3;    true5 = 360*x.^2;
%u = 0 on x = 0, 1
%true1 = x^6 - x;   true2 = 6*x^5 - 1;   true3 = 30*x^4;
%u = 0, u' = 0 on x = 0, 1
%true1 = x^6 - x^2; true2 = 6*x^5 - 2*x; true3 = 30*x^4 -2;
%u'''' = 0 on x = 0, 1
%true1 = x^6 - 3*x^5; true2 = 6*x^5 - 15*x^4; true3 = 30*x^4 - 60*x^3;

case {41}
    Uname ='x^5';
true1 = x.^5;       true2 = 5*x.^4;       true3 = 20*x.^3;
true4 = 60*x.^2;    true5 = 120*x;
%u = 0 on x = 0, 1
%true1 = x.^5 - x;   true2 = 5*x.^4 - 1;   true3 = 20*x.^3;

case {31}
    Uname ='x^4';
true1 = x.^4;       true2 = 4*x.^3;       true3 = 12*x.*x;
true4 = 24*x;       true5 = 24*o;
%u = 0 on x = 0, 1
%true1 = x.^4 - x;   true2 = 4*x.^3 - 1;   true3 = 12*x.*x;
%u = 0, u' = 0 on x = 0, 1
%true1 = x.^2.*(x-1).^2; true2 = 4*x.^3 - 6*x.^2 + 2*x; true3 = 12*x^2 - 12*x + 2;

case {23}
%u' = 0
    Uname ='x.^3/3 - x.*x/2';
true1 = x.^3/3 - x.*x/2; true2 = x.*x - x;  true3 = 2*x-1;
true4 = 2*o;       true5 = z;
case {22}
    Uname ='x.^3 - x.*x';
true1 = x^3 - x*x; true2 = 3*x*x - 2*x; true3 = 6*x-2;
true4 = 6*o;       true5 = z;
case {21}
    Uname ='x.^3';
true1 = x.^3;      true2 = 3*x.*x;       true3 = 6*x;
true4 = 6*o;       true5 = z;

case {12}
    Uname ='x.*x - x';
true1 = x.*x - x;  true2 = 2*x - 1;     true3 = 2*o;
true4 = z;         true5 = z;
case {11}
    Uname ='x.*x';
true1 = x.*x;      true2 = 2*x;         true3 = 2*o;
true4 = z;         true5 = z;

case {1}
    Uname ='x';
true1 = x;         true2 = o;           true3 = z;
true4 = z;         true5 = z;

case {0}
    Uname ='1';
true1 = o;         true2 = z;           true3 = z;
true4 = z;         true5 = z;

otherwise
    error(['truevd: no such function ' num2str(Uno)])
end
