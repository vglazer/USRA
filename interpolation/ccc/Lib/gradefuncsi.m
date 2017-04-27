% function [y, S] = gradefuncs(n, gridx, maxstep, tol, evalf, ax, bx, z)
%
% Find optimal placement of n collocation pts based on grading functions
% g = (u^(4))^{2/z} or g =(1 + (u')^2)^{1/2} within tol and maxstep

function [y, S] = gradefuncsi(n, gridx, maxstep, tol, evalf, ax, bx, z)

numeq = n+3; coefs = zeros(numeq, 3);
coefs(2:n+2, 1) = 1;
coefs(1, 2) = 1; coefs(n+3, 2) = 1;

N = n+1; avlen = 1/n; kbad = -1;
for k = 1:maxstep
    % Find approximating derivatives
    hx = gridx(2:N) - gridx(1:n);
    extx = bsplex(4, gridx, N);
    dof = si32(gridx);
    [d2, d1] = d21cs(n, gridx, gridx, dof, evalf, extx);
    [d4, d3] = d43csnu(n, d2, d1, hx);

    % Approximate integral values
    if (z == 1/2)
        [A, Smx, S, gval] = quadAcs(n, d1, hx, z); %z=1/2
    else
        [A, Smx, S, gval] = quadGcs(n, d4, hx, z); %z=1/7,1/8,1/9
    end
    drift(k) = abs(Smx - avlen*A);
    if drift(k) <= min(drift(1:k)), gridxopt = gridx; kopt = k;, end
    if (drift(k) < tol)
        break;
    end
    if (k > 1) & (drift(k) >= drift(k-1)), kbad = kbad+1;, end
    if kbad == 5, disp('5 bad iterations'), break, end

    % Compute new points x_j
    S1 = S(1); g = gval(1); p1 = gridx(2); j = 1; i = 2;
    while j < n
        if (S1 - j*avlen*A >= 0)
            %temp(j) = p0 + (j*avlen*A - S0)/g;
            temp(j) = p1 + (j*avlen*A - S1)/g;
            j = j+1;
        elseif i < N
            g = gval(i);
            S1 = S1 + S(i);
            i = i+1;
            p1 = gridx(i);
        end
    end
    gridx = [ax temp bx];
end
y = gridxopt;
disp(['nadaptsteps = ' num2str(k) '; kopt = ' num2str(kopt)]);
% drift
