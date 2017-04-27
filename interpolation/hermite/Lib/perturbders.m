% [dper, ddper] = perturbders(h,d,dd,del) - DOESN'T WORK PROPERLY
function [dper,ddper] = perturbders(h,d,dd,del)
n = length(d);

ddper = dd;
dper  = d;
for i = 2:n-1 
    % Compute monotonicity intervals for the second derivative 
    if dper(i)*del(i) > 0
        dplus = dper(i);
    else 
        dplus = 0;
    end   
    if dper(i)*del(i-1) > 0
        dminus = dper(i);
    else
        dminus = 0;
    end
    a = max(0, dper(i-1)/del(i-1));
    b = max(0, dper(i+1)/del(i));
    A1 = (-7.9*dplus  - 0.26*dplus *b)/h(i);
    B2 = ( 7.9*dminus + 0.26*dminus*a)/h(i-1);
    A2 = (( 20 - 2*b)*del(i)   - 8*dplus  - 0.48*dplus *b)/h(i);
    B1 = ((-20 + 2*a)*del(i-1) + 8*dminus + 0.48*dminus*a)/h(i-1);

    % Flip endpoints as necessary
    if A1 > A2 
        temp = A2;
        A2 = A1;
        A1 = temp;
    end
    if B1 > B2 
        temp = B2;
        B2 = B1;
        B1 = temp;
    end

    % If intervals intersect, project second derivative to their intersection 
    if B1 < A2
        ddper(i) = median(ddper(i),B1,A2);

    % Otherwise, must further reduce first derivative
    else 
        % Reduce first derivative so that A2 = B1
        dper(i) = ((20 - 2*b)*del(i)/h(i) + (20 - 2*a)*del(i-1)/h(i-1))/ ...
                  ((8 + 0.48*b)/h(i) + (8 + 0.48*a)/h(i-1));

        % Project second derivative to the (now nonempty) intersection
        if dper(i)*del(i) > 0
            dplus = dper(i);
        else 
            dplus = 0;
        end   
        if dper(i)*del(i-1) > 0
            dminus = dper(i);
        else
            dminus = 0;
        end
        ddper(i) = ((20 - 2*b)*del(i) - 8*dplus - 0.48*dplus*b)/h(i);
    end
end

