function dd = approxsecder(x, y, appord)
n = length(y);

switch appord 
    case 1
    h = diff(x);
    k = 2:n-1;
    dd(k) = 2*(y(k-1)./(h(k-1).*(h(k-1)+h(k))) - y(k)./(h(k-1).*h(k)) + ...
               y(k+1)./(h(k).*(h(k-1)+h(k))));
    dd(1) = 2*(y(1)/(h(1)*(h(1)+h(2))) - y(2)/(h(1)*h(2)) + ...
               y(3)/(h(2)*(h(1)+h(2))));
    dd(n) = 2*(y(n)/(h(n-1)*(h(n-1)+h(n-2))) - y(n-1)/(h(n-1)*h(n-2)) + ...
               y(n-2)/(h(n-2)*(h(n-1)+h(n-2))));

    case 3
    xis = zeros(5,5);
    for i = 1:5
        for j = 1:5
            xis(i,j) = x(i)*x(j);
        end
    end

    w1 = (12*xis(1,1) - 6*(x(2) + x(3) + x(4) + x(5))*x(1) + ...
          2*(xis(2,3) + xis(2,4) + xis(2,5) + xis(3,4) + xis(3,5) + ...
             xis(4,5)))/((x(1) - x(2))*(x(1) - x(3))*...
                         (x(1) - x(4))*(x(1) - x(5)));
    w2 = (12*xis(1,1) - 6*(x(1) + x(3) + x(4) + x(5))*x(1) + ...
          2*(xis(1,3) + xis(1,4) + xis(1,5) + xis(3,4) + xis(3,5) + ...
             xis(4,5)))/((x(2) - x(1))*(x(2) - x(3))*...
                         (x(2) - x(4))*(x(2) - x(5)));
    w3 = (12*xis(1,1) - 6*(x(1) + x(2) + x(4) + x(5))*x(1) + ...
          2*(xis(1,2) + xis(1,4) + xis(1,5) + xis(2,4) + xis(2,5) + ...
             xis(4,5)))/((x(3) - x(1))*(x(3) - x(2))*...
                         (x(3) - x(4))*(x(3) - x(5)));
    w4 = (12*xis(1,1) - 6*(x(1) + x(2) + x(3) + x(5))*x(1) + ...
          2*(xis(1,2) + xis(1,3) + xis(1,5) + xis(2,3) + xis(2,5) + ...
             xis(3,5)))/((x(4) - x(1))*(x(4) - x(2))*...
                         (x(4) - x(3))*(x(4) - x(5)));
    w5 = (12*xis(1,1) - 6*(x(1) + x(2) + x(3) + x(4))*x(1) + ...
          2*(xis(1,2) + xis(1,3) + xis(1,4) + xis(2,3) + xis(2,4) + ...
             xis(3,4)))/((x(5) - x(1))*(x(5) - x(2))*...
                         (x(5) - x(3))*(x(5) - x(4)));
    dd(1) = w1*y(1) + w2*y(2) + w3*y(3) + w4*y(4) + w5*y(5);

    w1 = (12*xis(2,2) - 6*(x(2) + x(3) + x(4) + x(5))*x(2) + ...
          2*(xis(2,3) + xis(2,4) + xis(2,5) + xis(3,4) + xis(3,5) + ...
             xis(4,5)))/((x(1) - x(2))*(x(1) - x(3))*...
                         (x(1) - x(4))*(x(1) - x(5)));
    w2 = (12*xis(2,2) - 6*(x(1) + x(3) + x(4) + x(5))*x(2) + ...
          2*(xis(1,3) + xis(1,4) + xis(1,5) + xis(3,4) + xis(3,5) + ...
             xis(4,5)))/((x(2) - x(1))*(x(2) - x(3))*...
                         (x(2) - x(4))*(x(2) - x(5)));
    w3 = (12*xis(2,2) - 6*(x(1) + x(2) + x(4) + x(5))*x(2) + ...
          2*(xis(1,2) + xis(1,4) + xis(1,5) + xis(2,4) + xis(2,5) + ...
             xis(4,5)))/((x(3) - x(1))*(x(3) - x(2))*...
                         (x(3) - x(4))*(x(3) - x(5)));
    w4 = (12*xis(2,2) - 6*(x(1) + x(2) + x(3) + x(5))*x(2) + ...
          2*(xis(1,2) + xis(1,3) + xis(1,5) + xis(2,3) + xis(2,5) + ...
             xis(3,5)))/((x(4) - x(1))*(x(4) - x(2))*...
                         (x(4) - x(3))*(x(4) - x(5)));
    w5 = (12*xis(2,2) - 6*(x(1) + x(2) + x(3) + x(4))*x(2) + ...
          2*(xis(1,2) + xis(1,3) + xis(1,4) + xis(2,3) + xis(2,4) + ...
             xis(3,4)))/((x(5) - x(1))*(x(5) - x(2))*...
                         (x(5) - x(3))*(x(5) - x(4)));
    dd(2) = w1*y(1) + w2*y(2) + w3*y(3) + w4*y(4) + w5*y(5);

    for k = 3:n-2
        for i = 1:5
            for j = 1:5
                xis(i,j) = x(k-3+i)*x(k-3+j);
            end
        end 

        w1 = (12*xis(3,3) - 6*(x(k-1) + x(k) + x(k+1) + x(k+2))*x(k) + ...
              2*(xis(2,3) + xis(2,4) + xis(2,5) + xis(3,4) + xis(3,5) + ...
                 xis(4,5)))/((x(k-2) - x(k-1))*(x(k-2) - x(k))*...
                             (x(k-2) - x(k+1))*(x(k-2) - x(k+2)));
        w2 = (12*xis(3,3) - 6*(x(k-2) + x(k) + x(k+1) + x(k+2))*x(k) + ...
              2*(xis(1,3) + xis(1,4) + xis(1,5) + xis(3,4) + xis(3,5) + ...
                 xis(4,5)))/((x(k-1) - x(k-2))*(x(k-1) - x(k))*...
                             (x(k-1) - x(k+1))*(x(k-1) - x(k+2)));
        w3 = (12*xis(3,3) - 6*(x(k-2) + x(k-1) + x(k+1) + x(k+2))*x(k) + ...
              2*(xis(1,2) + xis(1,4) + xis(1,5) + xis(2,4) + xis(2,5) + ...
                 xis(4,5)))/((x(k) - x(k-2))*(x(k) - x(k-1))*...
                             (x(k) - x(k+1))*(x(k) - x(k+2)));
        w4 = (12*xis(3,3) - 6*(x(k-2) + x(k-1) + x(k) + x(k+2))*x(k) + ...
              2*(xis(1,2) + xis(1,3) + xis(1,5) + xis(2,3) + xis(2,5) + ...
                 xis(3,5)))/((x(k+1) - x(k-2))*(x(k+1) - x(k-1))*...
                             (x(k+1) - x(k))*(x(k+1) - x(k+2)));
        w5 = (12*xis(3,3) - 6*(x(k-2) + x(k-1) + x(k) + x(k+1))*x(k) + ...
              2*(xis(1,2) + xis(1,3) + xis(1,4) + xis(2,3) + xis(2,4) + ...
                 xis(3,4)))/((x(k+2) - x(k-2))*(x(k+2) - x(k-1))*...
                             (x(k+2) - x(k))*(x(k+2) - x(k+1)));
        dd(k) = w1*y(k-2) + w2*y(k-1) + w3*y(k) + w4*y(k+1) + w5*y(k+2);
    end

    for i = 1:5
        for j = 1:5
            xis(i,j) = x(n-5+i)*x(n-5+j);
        end
    end

    w1 = (12*xis(4,4) - 6*(x(n-3) + x(n-2) + x(n-1) + x(n))*x(n-1) + ...
          2*(xis(2,3) + xis(2,4) + xis(2,5) + xis(3,4) + xis(3,5) + ...
             xis(4,5)))/((x(n-4) - x(n-3))*(x(n-4) - x(n-2))*...
                         (x(n-4) - x(n-1))*(x(n-4) - x(n)));
    w2 = (12*xis(4,4) - 6*(x(n-4) + x(n-2) + x(n-1) + x(n))*x(n-1) + ...
          2*(xis(1,3) + xis(1,4) + xis(1,5) + xis(3,4) + xis(3,5) + ...
             xis(4,5)))/((x(n-3) - x(n-4))*(x(n-3) - x(n-2))*...
                         (x(n-3) - x(n-1))*(x(n-3) - x(n)));
    w3 = (12*xis(4,4) - 6*(x(n-4) + x(n-3) + x(n-1) + x(n))*x(n-1) + ...
          2*(xis(1,2) + xis(1,4) + xis(1,5) + xis(2,4) + xis(2,5) + ...
             xis(4,5)))/((x(n-2) - x(n-4))*(x(n-2) - x(n-3))*...
                         (x(n-2) - x(n-1))*(x(n-2) - x(n)));
    w4 = (12*xis(4,4) - 6*(x(n-4) + x(n-3) + x(n-2) + x(n))*x(n-1) + ...
          2*(xis(1,2) + xis(1,3) + xis(1,5) + xis(2,3) + xis(2,5) + ...
             xis(3,5)))/((x(n-1) - x(n-4))*(x(n-1) - x(n-3))*...
                         (x(n-1) - x(n-2))*(x(n-1) - x(n)));
    w5 = (12*xis(4,4) - 6*(x(n-4) + x(n-3) + x(n-2) + x(n-1))*x(n-1) + ...
          2*(xis(1,2) + xis(1,3) + xis(1,4) + xis(2,3) + xis(2,4) + ...
             xis(3,4)))/((x(n) - x(n-4))*(x(n) - x(n-3))*...
                         (x(n) - x(n-2))*(x(n) - x(n-1)));
    dd(n-1) = w1*y(n-4) + w2*y(n-3) + w3*y(n-2) + w4*y(n-1) + w5*y(n);

    w1 = (12*xis(5,5) - 6*(x(n-3) + x(n-2) + x(n-1) + x(n))*x(n) + ...
          2*(xis(2,3) + xis(2,4) + xis(2,5) + xis(3,4) + xis(3,5) + ...
             xis(4,5)))/((x(n-4) - x(n-3))*(x(n-4) - x(n-2))*...
                         (x(n-4) - x(n-1))*(x(n-4) - x(n)));
    w2 = (12*xis(5,5) - 6*(x(n-4) + x(n-2) + x(n-1) + x(n))*x(n) + ...
          2*(xis(1,3) + xis(1,4) + xis(1,5) + xis(3,4) + xis(3,5) + ...
             xis(4,5)))/((x(n-3) - x(n-4))*(x(n-3) - x(n-2))*...
                         (x(n-3) - x(n-1))*(x(n-3) - x(n)));
    w3 = (12*xis(5,5) - 6*(x(n-4) + x(n-3) + x(n-1) + x(n))*x(n) + ...
          2*(xis(1,2) + xis(1,4) + xis(1,5) + xis(2,4) + xis(2,5) + ...
             xis(4,5)))/((x(n-2) - x(n-4))*(x(n-2) - x(n-3))*...
                         (x(n-2) - x(n-1))*(x(n-2) - x(n)));
    w4 = (12*xis(5,5) - 6*(x(n-4) + x(n-3) + x(n-2) + x(n))*x(n) + ...
          2*(xis(1,2) + xis(1,3) + xis(1,5) + xis(2,3) + xis(2,5) + ...
             xis(3,5)))/((x(n-1) - x(n-4))*(x(n-1) - x(n-3))*...
                         (x(n-1) - x(n-2))*(x(n-1) - x(n)));
    w5 = (12*xis(5,5) - 6*(x(n-4) + x(n-3) + x(n-2) + x(n-1))*x(n) + ...
          2*(xis(1,2) + xis(1,3) + xis(1,4) + xis(2,3) + xis(2,4) + ...
             xis(3,4)))/((x(n) - x(n-4))*(x(n) - x(n-3))*...
                         (x(n) - x(n-2))*(x(n) - x(n-1)));
    dd(n) = w1*y(n-4) + w2*y(n-3) + w3*y(n-2) + w4*y(n-1) + w5*y(n);

    otherwise % Catch errors
        error('MATLAB:badopt','unrecognised approximation type!');
end
