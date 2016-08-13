% SYNTAX
% perturbder(nder, d, x, y, constrtype)
%
% DESCRIPTION
% perturbder perturbs the derivative values d to ensure monotonicity. 
%
% PARAMETERS
% nder is the desired interpolant degree. The supported options are 3 and 5.
% nder must be specified.
%
% d is the vector of approximate derivative values. d must be specified.
%
% x is the knot vector. x must be specified.
% 
% y is the data vector. y must be specified.
%
% constrtype is the monotonicity constraint to be used. The supported 
% options are:
%   'MP' - a basic second order constraint [Fritsch and Carlson]
%   'MH' - a marginally better second order constraint [Hyman]
%   'M3' - a uniform third order constraint [Huynh]
%   'M4' - a uniform fourth order constraint [Huynh]
% constrtype must be specified.
%
% EXAMPLES
% perturbder(3, d, x, y, 'M3') - cubic interpolant, third order constraint
function dper = perturbder(nder, d, x, y, constrtype)
n = length(d);
dper = d;

switch constrtype
    case 'MP' % The edelman constraint expressed using the minmod
              % function
    s = diff(y)./diff(x);
    dper(1) = minmod(d(1), nder*s(1));
    dper(n) = minmod(d(n), nder*s(n-1));

    for j = 2:n-1
        dper(j) = minmod(d(j), nder*minmod(s(j-1),s(j)));
    end

    case 'MH' % The hyman constraint expressed using the median
              % function
    s = diff(y)./diff(x);
    dper(1) = minmod(d(1), nder*s(1));
    dper(n) = minmod(d(n), nder*s(n-1));

    for j = 2:n-1
        dper(j) = sign(d(j))*min([abs(d(j)), ...
                                  nder*abs(s(j-1)), nder*abs(s(j))]);
    end

    case 'M3'
    % Compute first and second divided differences
    [s,ds] = vecdiffs(x,y);

    % Compute minmods of divided differences
    smin = zeros(1,n-2);
    for k = 1:n-2
        smin(k) = minmod(s(k),s(k+1));
    end
    dmin = zeros(1,n-3);
    for k = 1:n-3
        dmin(k) = minmod(ds(k),ds(k+1));
    end

    % Apply basic monotonicity constraint at and near the endpoints
    dper(1)   = minmod(d(1),   nder*s(1));
    dper(2)   = minmod(d(2),   nder*minmod(s(1), s(2)));
    dper(n)   = minmod(d(n),   nder*s(n-1));
    dper(n-1) = minmod(d(n-1), nder*minmod(s(n-2), s(n-1)));

    %dper(2)   = sign(d(2))  *min([abs(d(2)), nder*abs(s(1)), nder*abs(s(2))]);
    %dper(n-1) = sign(d(n-1))*min([abs(d(n-1)), ...
    %                              nder*abs(s(n-2)), nder*abs(s(n-1))]);

    % Apply M3 constraint to original derivative approximations 
    % at interior points
    for k = 3:n-2
        p1 = s(k-1) + dmin(k-2)*(x(k) - x(k-1));
        p2 = s(k)   + dmin(k-1)*(x(k) - x(k+1));
        t = minmod(p1,p2);
        tmax = sign(t)*max(nder*abs(smin(k-1)), (nder/2)*abs(t)); 
        dper(k) = minmod(d(k),tmax);
    end

    case 'M3-A'
    % Compute first and second divided differences
    [s,ds] = vecdiffs(x,y);

    % Compute minmods of divided differences
    smin = zeros(1,n-2);
    for k = 1:n-2
        smin(k) = minmod(s(k),s(k+1));
    end
    dmin = zeros(1,n-3);
    for k = 1:n-3
        dmin(k) = minmod(ds(k),ds(k+1));
    end

    % Apply MP constraint to original derivative appriximations near boundary,
    % basic monotonicity constraint at the endpoints
    dper(1) = minmod(d(1), nder*s(1));
    dper(n) = minmod(d(n), nder*s(n-1));

    dper(2)   = sign(d(2))  *min([abs(d(2)), nder*abs(s(1)), nder*abs(s(2))]);
    dper(n-1) = sign(d(n-1))*min([abs(d(n-1)), ...
                                  nder*abs(s(n-2)), nder*abs(s(n-1))]);

    % Apply M3 constraint to limiter function approximations at interior 
    % points
    for k = 3:n-2
        p1 = s(k-1) + dmin(k-2)*(x(k) - x(k-1));
        p2 = s(k)   + dmin(k-1)*(x(k) - x(k+1));
        t = minmod(p1,p2);
        % Notice that d(k) is _not_ used
        dper(k) = sign(t)*min(0.5*abs(p1+p2), ...
                              max(nder*abs(smin(k-1)), (nder/2)*abs(t)));
    end

    case 'M4'
    % Compute first, second and third divided differences
    [s,ds,e] = vecdiffs(x,y); h = diff(x);

    % Compute minmods of divided differences
    smin = zeros(1,n-2);
    for k = 1:n-2
        smin(k) = minmod(s(k),s(k+1));
    end
    dmin = zeros(1,n-3);
    for k = 1:n-3
        dmin(k) = minmod(ds(k),ds(k+1));
    end
    emin = zeros(1,n-4);
    for k = 1:n-4
        emin(k) = minmod(e(k),e(k+1));
    end

    % Apply MP and M3 constraints to original derivative appriximations near 
    % boundary, basic monotonicity constraint at the endpoints
    dper(1) = minmod(d(1), nder*s(1));
    dper(n) = minmod(d(n), nder*s(n-1));

    dper(2)   = sign(d(2))  *min([abs(d(2)), nder*abs(s(1)), nder*abs(s(2))]);
    dper(n-1) = sign(d(n-1))*min([abs(d(n-1)), ...
                                  nder*abs(s(n-2)), nder*abs(s(n-1))]);
    t = minmod(s(2) + dmin(1)*(x(3) - x(2)), s(3) + dmin(2)*(x(3) - x(4)));
    tmax = sign(t)*max(nder*abs(smin(2)), (nder/2)*abs(t)); 
    dper(3)   = minmod(d(3),  tmax);
    t = minmod(s(n-3) + dmin(n-4)*(x(n-2) - x(n-3)), ...
               s(n-2) + dmin(n-3)*(x(n-2) - x(n-1)));
    tmax = sign(t)*max(nder*abs(smin(n-3)), (nder/2)*abs(t)); 
    dper(n-2) = minmod(d(n-2),tmax);

    % Apply M4 constraint to original derivative approximations 
    % at interior points
    for k = 4:n-3
        p1 = s(k-1) + dmin(k-2)*(x(k) - x(k-1));
        p2 = s(k)   + dmin(k-1)*(x(k) - x(k+1));
        q1 = s(k-1) - h(k-1)*minmod(ds(k-2) + emin(k-3)*(x(k-1) - x(k-2)), ...
                                    ds(k-1) + emin(k-2)*(x(k-1) - x(k+1)));
        q2 = s(k)   - h(k)  *minmod(ds(k-1) + emin(k-2)*(x(k)   - x(k-1)), ...
                                    ds(k)   + emin(k-1)*(x(k)   - x(k+2))); 
        t  = minmod(p1,p2); tt = minmod(q1,q2); 
        vec = [0, nder*smin(k-1), (nder/2)*t, tt];
        dper(k) = d(k) + minmod(min(vec) - d(k), max(vec) - d(k));
    end

    otherwise % Catch errors
        error('MATLAB:badopt','unrecognised constraint type!');
end
