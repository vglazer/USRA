% function ext = bsplex(kord, grid, ngrid)

function ext = bsplex(kord, grid, ngrid)

ext = zeros(1, ngrid+2*kord-2);
ext(kord:kord+ngrid-1) = grid(1:ngrid);

ha = grid(2) - grid(1);
for i = kord-1:-1:1
    ext(i) = ext(i+1) - ha;
end

hb  = grid(ngrid) - grid(ngrid-1);
for i = ngrid+kord:ngrid+2*kord-2
    ext(i) = ext(i-1) + hb;
end
