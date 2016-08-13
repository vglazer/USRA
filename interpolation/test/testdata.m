% This script loads three rough-grid datasets commonly used for comparing
% monotone interpolants into the workspace. It also generates smooth grids 
% to be used for plotting the resulting interpolans. The datasets are:
%   RPN14 [Fritsch and Carlson] - loaded into knots1, vals1, pts1
%   AKIMA3 [Akima] - loaded into knots2, vals2, pts2
%   Titanium [Dougherty, Edelman and Hyman] - loaded into knots3, vals3, pts3

% RPN14 data from Monotone Piecewise Cubic Interpolation by Fritsch and
% Carlson
knots1 =  [7.99 8.09 8.19 8.7 9.2 10 12 15 20];
vals1  =  [0 2.76429e-5 4.37498e-2 0.169183 0.469428 0.943740 ...
           0.998636 0.999919 0.999994];
pts1   = linspace(7.99,20,1001);
disp('{knots,vals,pts}1: RPN14 data [Fritsch and Carlson] loaded.');

% AKIMA3 data from A New Method Of Interpolation And Smooth Curve Fitting
% Based On Local Procedures by Akima
knots2 = [3 5 6 8 9 11 12 14 15];
vals2  = [10 10 10 10 10.5 15 50 60 85];
pts2   = linspace(3,15,1001);
disp('{knots,vals,pts}5: AKIMA3 data [Akima] loaded.');

% Titanium data from Dougherty, Edelman and Hyman
knots3 =  [595 635 695 795 855 875 895 915 935 985 1035 1075];
vals3  =  [0.644 0.652 0.644 0.694 0.907 1.336 2.169 1.598 ...
           0.916 0.607 0.603 0.608];
pts3   = linspace(595,1075,1001);
disp('{knots,vals,pts}2: Titanium data [Dougherty, Edelman and Hyman] loaded.');

